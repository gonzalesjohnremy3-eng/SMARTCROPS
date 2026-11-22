export const CAMPAIGN_BATCH_SIZE = 500;

export const SAFE_PATH_PREFIXES = [
  '/home',
  '/crops',
  '/calendar',
  '/advisories',
  '/health-log',
  '/care-plan',
  '/shop',
  '/pro',
] as const;

export type CampaignInput = {
  title: unknown;
  body: unknown;
  path?: unknown;
  target?: unknown;
  recordId?: unknown;
};

export type FcmMessage = {
  token: string;
  notification: { title: string; body: string };
  data: Record<string, string>;
};

export type CampaignAuthorization =
  | { ok: true; role: string }
  | { ok: false; status: 401 | 403; error: string };

function isSafePath(path: string): boolean {
  return SAFE_PATH_PREFIXES.some(
    (prefix) => path === prefix || path.startsWith(`${prefix}/`),
  );
}

function resolvePath(input: CampaignInput): string {
  if (typeof input.path === 'string') {
    if (!isSafePath(input.path)) throw new Error('Unsafe campaign path');
    return input.path;
  }

  const target = typeof input.target === 'string' ? input.target : '';
  const recordId = typeof input.recordId === 'string' ? input.recordId : '';
  const encodedId = encodeURIComponent(recordId);

  switch (target) {
    case 'task':
      return recordId ? `/calendar/events/${encodedId}` : '/advisories';
    case 'crop':
      return recordId ? `/crops/${encodedId}` : '/advisories';
    case 'scan':
      return '/health-log';
    default:
      return '/advisories';
  }
}

export function buildFcmMessageBatches(
  tokens: readonly unknown[],
  input: CampaignInput,
): FcmMessage[][] {
  if (typeof input.title !== 'string' || input.title.trim().length === 0) {
    throw new Error('Campaign title is required');
  }
  if (typeof input.body !== 'string' || input.body.trim().length === 0) {
    throw new Error('Campaign body is required');
  }

  const path = resolvePath(input);
  const uniqueTokens = [
    ...new Set(
      tokens.filter(
        (token): token is string =>
          typeof token === 'string' && token.trim().length > 0,
      ),
    ),
  ];
  if (uniqueTokens.length === 0) throw new Error('No device tokens');

  const messages: FcmMessage[] = uniqueTokens.map((token) => ({
    token,
    notification: { title: input.title as string, body: input.body as string },
    data: { path },
  }));

  const batches: FcmMessage[][] = [];
  for (let index = 0; index < messages.length; index += CAMPAIGN_BATCH_SIZE) {
    batches.push(messages.slice(index, index + CAMPAIGN_BATCH_SIZE));
  }
  return batches;
}

export function authorizeCampaignSender(
  appMetadata: unknown,
): CampaignAuthorization {
  if (appMetadata === null || typeof appMetadata !== 'object') {
    return { ok: false, status: 401, error: 'Authentication required' };
  }

  const role = (appMetadata as Record<string, unknown>)['cooperative_role'];
  if (role !== 'admin' && role !== 'extension_officer') {
    return { ok: false, status: 403, error: 'Cooperative sender role required' };
  }
  return { ok: true, role };
}
