import { DiagnosisResult } from './pool_runner.ts';

export const GEMINI_MODELS = ['gemini-3.8-flash', 'gemini-3.6-flash'];

export interface GeminiRunDeps {
  apiKey: string;
  imageUrl: string;
  cropName: string;
  download: (url: string) => Promise<{ base64: string; mimeType: string }>;
  callModel: (model: string, base64: string, mimeType: string) => Promise<DiagnosisResult>;
  record: (model: string, status: 'success' | 'error', error?: string) => Promise<void>;
  models?: string[];
}

export async function runGeminiModels(deps: GeminiRunDeps): Promise<DiagnosisResult> {
  const { base64, mimeType } = await deps.download(deps.imageUrl);
  const attempts: string[] = [];
  for (const model of deps.models ?? GEMINI_MODELS) {
    try {
      const result = await deps.callModel(model, base64, mimeType);
      await deps.record(model, 'success');
      return result;
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      attempts.push(`${model}: ${message}`);
      await deps.record(model, 'error', message);
    }
  }
  throw new Error(attempts.join('; '));
}
