import { GEMINI_MODELS, runGeminiModels } from './gemini_runner.ts';

function assertEqual(actual: unknown, expected: unknown, label: string) {
  if (actual !== expected) {
    throw new Error(`${label}: expected ${expected}, got ${actual}`);
  }
}

const diagnosis = {
  disease_detected: 'Leaf spot',
  confidence_score: 88,
  common_crop: 'Pechay',
  recommended_actions: ['Remove affected leaves'],
};

Deno.test('high demand on 3.8 Flash falls back to 3.6 Flash and records both attempts', async () => {
  const recorded: { model: string; status: string; error?: string }[] = [];
  let downloads = 0;
  const calls: string[] = [];

  const result = await runGeminiModels({
    apiKey: 'test-key',
    imageUrl: 'https://example.com/scan.jpg',
    cropName: 'Pechay',
    download: async () => {
      downloads++;
      return { base64: 'aW1hZ2U=', mimeType: 'image/jpeg' };
    },
    callModel: async (model) => {
      calls.push(model);
      if (model === GEMINI_MODELS[0]) {
        throw new Error('gemini 503: High demand right now');
      }
      return diagnosis;
    },
    record: async (model, status, error) => {
      recorded.push({ model, status, error });
    },
  });

  assertEqual(result, diagnosis, 'result');
  assertEqual(downloads, 1, 'image downloads');
  assertEqual(calls.join(','), GEMINI_MODELS.join(','), 'models tried');
  assertEqual(recorded.length, 2, 'recorded attempts');
  assertEqual(recorded[0].model, GEMINI_MODELS[0], 'first model');
  assertEqual(recorded[0].status, 'error', 'first status');
  assertEqual(recorded[0].error, 'gemini 503: High demand right now', 'first error');
  assertEqual(recorded[1].model, GEMINI_MODELS[1], 'second model');
  assertEqual(recorded[1].status, 'success', 'second status');
});

Deno.test('a working 3.8 Flash stops the fallback chain with one success record', async () => {
  const recorded: string[] = [];
  const calls: string[] = [];

  const result = await runGeminiModels({
    apiKey: 'test-key',
    imageUrl: 'https://example.com/scan.jpg',
    cropName: 'Pechay',
    download: async () => ({ base64: 'aW1hZ2U=', mimeType: 'image/jpeg' }),
    callModel: async (model) => {
      calls.push(model);
      return diagnosis;
    },
    record: async (model, status) => {
      recorded.push(`${model}:${status}`);
    },
  });

  assertEqual(result, diagnosis, 'result');
  assertEqual(calls.length, 1, 'model calls');
  assertEqual(recorded.join(','), `${GEMINI_MODELS[0]}:success`, 'recorded attempts');
});
