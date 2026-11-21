import { ProviderKeyUnavailable } from './ai_errors.ts';
import { runKeyPool } from './pool_runner.ts';

function assertEqual(actual: unknown, expected: unknown, label: string) {
  if (actual !== expected) {
    throw new Error(`${label}: expected ${expected}, got ${actual}`);
  }
}

function fakePoolClient() {
  const calls: { table: string; values: Record<string, unknown>; id: unknown }[] = [];
  const client = {
    from(table: string) {
      let values: Record<string, unknown> = {};
      return {
        update(next: Record<string, unknown>) {
          values = next;
          return this;
        },
        eq(_column: string, value: unknown) {
          calls.push({ table, values, id: value });
          return Promise.resolve({ error: null });
        },
      };
    },
  };
  return { client, calls };
}

const deadOpenAIKey = {
  id: 'dead-openai',
  provider: 'OpenAI',
  api_key_encrypted: 'sk-test',
  current_usage_count: 1,
  daily_quota_limit: 100,
};

const busyGeminiKey = {
  id: 'busy-gemini',
  provider: 'Gemini',
  api_key_encrypted: 'aq-test',
  current_usage_count: 0,
  daily_quota_limit: 250,
};

Deno.test('out-of-credits key is deactivated while transient failures are not', async () => {
  const { client, calls } = fakePoolClient();

  const outcome = await runKeyPool(client, [deadOpenAIKey, busyGeminiKey], async (key) => {
    if (key.provider === 'OpenAI') {
      throw new ProviderKeyUnavailable('OpenAI account out of credits');
    }
    throw new Error('gemini 503: high demand');
  });

  assertEqual(outcome.result, null, 'result');
  assertEqual(outcome.usedKey, null, 'usedKey');
  assertEqual(outcome.attempts.length, 2, 'attempt count');
  assertEqual(outcome.attempts[0], 'OpenAI: OpenAI account out of credits', 'first attempt');
  assertEqual(outcome.attempts[1], 'Gemini: gemini 503: high demand', 'second attempt');
  assertEqual(calls.length, 1, 'deactivation count');
  assertEqual(calls[0].table, 'ai_keys_pool', 'table');
  assertEqual(calls[0].values.is_active, false, 'is_active');
  assertEqual(calls[0].id, 'dead-openai', 'deactivated key id');
});

Deno.test('a successful key is used and no key is deactivated', async () => {
  const { client, calls } = fakePoolClient();
  const diagnosis = {
    disease_detected: 'Leaf spot',
    confidence_score: 91,
    common_crop: 'Pechay',
    recommended_actions: ['Spray neem oil'],
  };

  const outcome = await runKeyPool(client, [deadOpenAIKey, busyGeminiKey], async (key) => {
    if (key.provider === 'Gemini') return diagnosis;
    throw new ProviderKeyUnavailable('OpenAI account out of credits');
  });

  assertEqual(outcome.result, diagnosis, 'result');
  assertEqual(outcome.usedKey?.id, 'busy-gemini', 'used key');
  assertEqual(calls.length, 1, 'deactivation count');
  assertEqual(calls[0].id, 'dead-openai', 'deactivated key id');
});
