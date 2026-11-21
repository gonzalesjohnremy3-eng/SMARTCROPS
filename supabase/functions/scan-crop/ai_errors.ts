export interface ProviderFailure {
  shouldDeactivate: boolean;
  message: string;
}

export class ProviderKeyUnavailable extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ProviderKeyUnavailable';
  }
}

export function classifyOpenAIError(status: number, body: string): ProviderFailure {
  let type = '';
  let detail = '';
  try {
    const parsed = JSON.parse(body);
    type = parsed?.error?.type ?? parsed?.error?.code ?? '';
    detail = parsed?.error?.message ?? '';
  } catch {
    detail = body;
  }

  if (status === 429 && type === 'insufficient_quota') {
    return { shouldDeactivate: true, message: 'OpenAI account out of credits' };
  }

  return {
    shouldDeactivate: false,
    message: `openai ${status}: ${(detail || body).slice(0, 200)}`,
  };
}
