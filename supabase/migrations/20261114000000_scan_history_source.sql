alter table public.scan_history
  add column if not exists source text not null default 'ai';

comment on column public.scan_history.source is
  'Origin of the diagnosis: ai (edge function with Gemini/OpenAI) or demo_offline (bundled offline sample shown when the AI service cannot answer).';
