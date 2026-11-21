import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";
import { classifyOpenAIError, ProviderKeyUnavailable } from './ai_errors.ts';
import { runGeminiModels } from './gemini_runner.ts';
import { DiagnosisResult, PoolKey, runKeyPool } from './pool_runner.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const OPENAI_MODEL = Deno.env.get('OPENAI_MODEL') ?? 'gpt-4o';
const AI_TIMEOUT_MS = 45_000;

function parseDiagnosisJson(raw: string, cropName: string): DiagnosisResult {
  const parsed = JSON.parse(raw);
  return {
    disease_detected: parsed.disease_detected ?? 'Unidentified',
    confidence_score: Number(parsed.confidence_score ?? 0),
    common_crop: parsed.common_crop ?? cropName ?? 'Unknown',
    recommended_actions: Array.isArray(parsed.recommended_actions)
      ? parsed.recommended_actions
      : [],
  };
}

const SYSTEM_PROMPT =
  'You are an expert agricultural plant pathologist. Analyze the crop image and return JSON with keys: ' +
  'disease_detected (string), confidence_score (number 0-100), common_crop (string), recommended_actions (array of strings).';

async function downloadImage(imageUrl: string): Promise<{ base64: string; mimeType: string }> {
  const imageResponse = await fetch(imageUrl, { signal: AbortSignal.timeout(AI_TIMEOUT_MS) });
  if (!imageResponse.ok) {
    throw new Error(`image fetch failed: ${imageResponse.status}`);
  }
  const mimeType = imageResponse.headers.get('content-type') ?? 'image/jpeg';
  const buffer = await imageResponse.arrayBuffer();
  const bytes = new Uint8Array(buffer);
  let binary = '';
  const CHUNK = 0x8000;
  for (let i = 0; i < bytes.length; i += CHUNK) {
    binary += String.fromCharCode(...bytes.subarray(i, i + CHUNK));
  }
  return { base64: btoa(binary), mimeType };
}

async function callGeminiModel(
  apiKey: string,
  model: string,
  base64: string,
  mimeType: string,
  cropName: string,
): Promise<DiagnosisResult> {
  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`,
    {
      method: 'POST',
      signal: AbortSignal.timeout(AI_TIMEOUT_MS),
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{
          parts: [
            { text: `${SYSTEM_PROMPT}\nExpected crop type: ${cropName || 'Unknown'}` },
            { inline_data: { mime_type: mimeType, data: base64 } },
          ],
        }],
        generationConfig: { responseMimeType: 'application/json', temperature: 0.2 },
      }),
    },
  );
  if (!response.ok) {
    const body = await response.text();
    throw new Error(`gemini ${response.status}: ${body.slice(0, 200)}`);
  }
  const json = await response.json();
  const text = json?.candidates?.[0]?.content?.parts?.[0]?.text;
  if (!text) {
    throw new Error('gemini returned no text');
  }
  return parseDiagnosisJson(text, cropName);
}

async function recordGeminiAttempt(
  supabaseClient: any,
  userId: string,
  keyId: string,
  model: string,
  status: 'success' | 'error',
  error?: string,
): Promise<void> {
  const { error: insertError } = await supabaseClient
    .from('ai_model_attempts')
    .insert({
      user_id: userId,
      key_id: keyId,
      provider: 'Gemini',
      model,
      status,
      error: error ? error.slice(0, 500) : null,
    });
  if (insertError) {
    console.error(`Failed to record Gemini attempt for ${model}: ${insertError.message}`);
  }
}

async function diagnoseWithOpenAI(apiKey: string, imageUrl: string, cropName: string): Promise<DiagnosisResult> {
  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    signal: AbortSignal.timeout(AI_TIMEOUT_MS),
    headers: {
      'Authorization': `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: OPENAI_MODEL,
      messages: [
        { role: 'system', content: SYSTEM_PROMPT },
        {
          role: 'user',
          content: [
            { type: 'text', text: `Analyze this crop image. Expected crop type: ${cropName || 'Unknown'}` },
            { type: 'image_url', image_url: { url: imageUrl } },
          ],
        },
      ],
      response_format: { type: 'json_object' },
    }),
  });
  if (!response.ok) {
    const failure = classifyOpenAIError(response.status, await response.text());
    if (failure.shouldDeactivate) throw new ProviderKeyUnavailable(failure.message);
    throw new Error(failure.message);
  }
  const json = await response.json();
  const text = json?.choices?.[0]?.message?.content;
  if (!text) {
    throw new Error('openai returned no content');
  }
  return parseDiagnosisJson(text, cropName);
}

async function diagnoseWithKey(
  key: PoolKey,
  imageUrl: string,
  cropName: string,
  context: { userId: string; supabaseClient: any },
): Promise<DiagnosisResult> {
  const normalized = (key.provider ?? '').toLowerCase();
  if (normalized === 'gemini' || normalized === 'google') {
    return runGeminiModels({
      apiKey: key.api_key_encrypted,
      imageUrl,
      cropName,
      download: downloadImage,
      callModel: (model, base64, mimeType) =>
        callGeminiModel(key.api_key_encrypted, model, base64, mimeType, cropName),
      record: (model, status, error) =>
        recordGeminiAttempt(context.supabaseClient, context.userId, key.id, model, status, error),
    });
  }
  if (normalized === 'openai') {
    return diagnoseWithOpenAI(key.api_key_encrypted, imageUrl, cropName);
  }
  throw new Error(`unsupported provider: ${key.provider}`);
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    );

    const { imageUrl, userId, cropName } = await req.json();

    if (!imageUrl || !userId) {
      return new Response(
        JSON.stringify({ error: 'Missing required parameters: imageUrl or userId' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    // 1. Fetch all active keys; iterate under-quota ones, lowest usage first.
    const { data: allActiveKeys, error: fetchError } = await supabaseClient
      .from('ai_keys_pool')
      .select('*')
      .eq('is_active', true)
      .order('current_usage_count', { ascending: true });

    if (fetchError || !allActiveKeys || allActiveKeys.length === 0) {
      return new Response(
        JSON.stringify({ error: 'No active AI API keys available in pool' }),
        { status: 503, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    const availableKeys = allActiveKeys.filter(
      (k) => k.current_usage_count < k.daily_quota_limit,
    );
    if (availableKeys.length === 0) {
      return new Response(
        JSON.stringify({ error: 'All AI API keys have reached daily quota limits' }),
        { status: 429, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    // 2. Rotate through providers until one really diagnoses the image.
    const { result, usedKey, attempts } = await runKeyPool(
      supabaseClient,
      availableKeys as PoolKey[],
      (key) => diagnoseWithKey(key, imageUrl, cropName ?? '', { userId, supabaseClient }),
    );

    if (!result || !usedKey) {
      return new Response(
        JSON.stringify({ error: 'AI analysis failed on every configured key', detail: attempts }),
        { status: 502, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    // 3. Increment usage for the key that actually worked.
    await supabaseClient
      .from('ai_keys_pool')
      .update({ current_usage_count: usedKey.current_usage_count + 1, updated_at: new Date().toISOString() })
      .eq('id', usedKey.id);

    // 4. Save to scan_history
    const { data: scanRecord, error: scanError } = await supabaseClient
      .from('scan_history')
      .insert({
        user_id: userId,
        image_url: imageUrl,
        disease_detected: result.disease_detected,
        confidence_score: result.confidence_score,
        common_crop: result.common_crop,
        recommended_actions: result.recommended_actions,
      })
      .select()
      .single();

    if (scanError) {
      throw new Error(`Failed to save scan history: ${scanError.message}`);
    }

    // 5. Create notification for the user
    await supabaseClient
      .from('notifications')
      .insert({
        user_id: userId,
        title: `Scan Result: ${result.disease_detected}`,
        message: `Confidence: ${result.confidence_score}%. Tap to view recommended actions for ${result.common_crop}.`,
        scan_id: scanRecord.id,
        is_read: false,
      });

    return new Response(
      JSON.stringify({ success: true, data: scanRecord }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : String(error) }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  }
});
