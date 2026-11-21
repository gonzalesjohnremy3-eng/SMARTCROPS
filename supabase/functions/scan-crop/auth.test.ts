import { authorizeScanRequest, buildCorsHeaders } from './auth.ts';

Deno.test('authorizeScanRequest rejects an unauthenticated caller', () => {
  const result = authorizeScanRequest(null, 'farmer-1');
  if (result.ok) throw new Error('expected rejection');
  if (result.status !== 401) throw new Error(`expected 401, got ${result.status}`);
});

Deno.test('authorizeScanRequest rejects a missing requested userId', () => {
  const result = authorizeScanRequest('farmer-1', '');
  if (result.ok) throw new Error('expected rejection');
  if (result.status !== 400) throw new Error(`expected 400, got ${result.status}`);
});

Deno.test('authorizeScanRequest rejects a non-string requested userId', () => {
  const result = authorizeScanRequest('farmer-1', 42);
  if (result.ok) throw new Error('expected rejection');
  if (result.status !== 400) throw new Error(`expected 400, got ${result.status}`);
});

Deno.test('authorizeScanRequest rejects a userId belonging to another farmer', () => {
  const result = authorizeScanRequest('farmer-1', 'farmer-2');
  if (result.ok) throw new Error('expected rejection');
  if (result.status !== 403) throw new Error(`expected 403, got ${result.status}`);
});

Deno.test('authorizeScanRequest accepts the authenticated farmer', () => {
  const result = authorizeScanRequest('farmer-1', 'farmer-1');
  if (!result.ok) throw new Error('expected acceptance');
  if (result.userId !== 'farmer-1') throw new Error('expected the authenticated userId');
});

Deno.test('buildCorsHeaders omits allow-origin for non-browser callers', () => {
  const headers = buildCorsHeaders(null, ['https://app.smartcrops.ph']);
  if ('Access-Control-Allow-Origin' in headers) {
    throw new Error('non-browser callers must not receive a wildcard origin');
  }
  if (headers['Vary'] !== 'Origin') throw new Error('expected Vary: Origin');
});

Deno.test('buildCorsHeaders reflects an allowed browser origin', () => {
  const headers = buildCorsHeaders('https://app.smartcrops.ph', ['https://app.smartcrops.ph']);
  if (headers['Access-Control-Allow-Origin'] !== 'https://app.smartcrops.ph') {
    throw new Error('expected the allowed origin to be reflected');
  }
});

Deno.test('buildCorsHeaders does not allow an unknown browser origin', () => {
  const headers = buildCorsHeaders('https://evil.example', ['https://app.smartcrops.ph']);
  if ('Access-Control-Allow-Origin' in headers) {
    throw new Error('unknown origins must not be granted CORS access');
  }
});
