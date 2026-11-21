import { ProviderKeyUnavailable } from './ai_errors.ts';

export interface DiagnosisResult {
  disease_detected: string;
  confidence_score: number;
  common_crop: string;
  recommended_actions: string[];
}

export interface PoolKey {
  id: string;
  provider: string;
  api_key_encrypted: string;
  current_usage_count: number;
  daily_quota_limit: number;
}

interface PoolClient {
  from(table: string): any;
}

export interface PoolOutcome {
  result: DiagnosisResult | null;
  usedKey: PoolKey | null;
  attempts: string[];
}

export async function runKeyPool(
  client: PoolClient,
  keys: PoolKey[],
  diagnose: (key: PoolKey) => Promise<DiagnosisResult>,
): Promise<PoolOutcome> {
  const attempts: string[] = [];
  for (const key of keys) {
    try {
      const result = await diagnose(key);
      return { result, usedKey: key, attempts };
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      attempts.push(`${key.provider}: ${message}`);
      if (err instanceof ProviderKeyUnavailable) {
        const { error } = await client
          .from('ai_keys_pool')
          .update({ is_active: false, updated_at: new Date().toISOString() })
          .eq('id', key.id);
        if (error) {
          attempts.push(`${key.provider}: could not disable key ${key.id}: ${error.message}`);
        }
      }
    }
  }
  return { result: null, usedKey: null, attempts };
}
