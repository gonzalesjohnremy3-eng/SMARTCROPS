export type ScanAuthorization =
  | { ok: true; userId: string }
  | { ok: false; status: 400 | 401 | 403; error: string };

export function authorizeScanRequest(
  authenticatedUserId: string | null | undefined,
  requestedUserId: unknown,
): ScanAuthorization {
  if (!authenticatedUserId) {
    return { ok: false, status: 401, error: 'Authentication required' };
  }
  if (typeof requestedUserId !== 'string' || requestedUserId.trim().length === 0) {
    return { ok: false, status: 400, error: 'Missing required parameters: imageUrl or userId' };
  }
  if (requestedUserId !== authenticatedUserId) {
    return { ok: false, status: 403, error: 'userId does not match the authenticated farmer' };
  }
  return { ok: true, userId: authenticatedUserId };
}

export function buildCorsHeaders(
  origin: string | null | undefined,
  allowedOrigins: readonly string[],
): Record<string, string> {
  const headers: Record<string, string> = {
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    Vary: 'Origin',
  };
  if (origin && allowedOrigins.includes(origin)) {
    headers['Access-Control-Allow-Origin'] = origin;
  }
  return headers;
}
