import { classifyOpenAIError } from './ai_errors.ts';

function assertEqual(actual: unknown, expected: unknown, label: string) {
  if (actual !== expected) {
    throw new Error(`${label}: expected ${expected}, got ${actual}`);
  }
}

Deno.test('insufficient quota marks the key dead with a clean message', () => {
  const body = JSON.stringify({
    error: {
      message: 'You have no credits remaining. Add credits to continue using the API.',
      type: 'insufficient_quota',
    },
  });

  const failure = classifyOpenAIError(429, body);

  assertEqual(failure.shouldDeactivate, true, 'shouldDeactivate');
  assertEqual(failure.message, 'OpenAI account out of credits', 'message');
});

Deno.test('transient rate limit does not deactivate the key', () => {
  const body = JSON.stringify({
    error: { message: 'Rate limit reached', type: 'rate_limit_exceeded' },
  });

  const failure = classifyOpenAIError(429, body);

  assertEqual(failure.shouldDeactivate, false, 'shouldDeactivate');
  assertEqual(failure.message, 'openai 429: Rate limit reached', 'message');
});

Deno.test('non-JSON error body stays visible and does not deactivate', () => {
  const failure = classifyOpenAIError(500, 'upstream exploded');

  assertEqual(failure.shouldDeactivate, false, 'shouldDeactivate');
  assertEqual(failure.message, 'openai 500: upstream exploded', 'message');
});
