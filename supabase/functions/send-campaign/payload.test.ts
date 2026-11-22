import {
  authorizeCampaignSender,
  buildFcmMessageBatches,
} from './payload.ts';

Deno.test('buildFcmMessageBatches rejects an empty title', () => {
  try {
    buildFcmMessageBatches(['token-1'], { title: '', body: 'Body' });
    throw new Error('expected rejection');
  } catch (error) {
    if (error instanceof Error && error.message === 'expected rejection') throw error;
  }
});

Deno.test('buildFcmMessageBatches rejects an empty body', () => {
  try {
    buildFcmMessageBatches(['token-1'], { title: 'Title', body: '' });
    throw new Error('expected rejection');
  } catch (error) {
    if (error instanceof Error && error.message === 'expected rejection') throw error;
  }
});

Deno.test('buildFcmMessageBatches rejects an unsafe path', () => {
  try {
    buildFcmMessageBatches(['token-1'], {
      title: 'Title',
      body: 'Body',
      path: '/admin',
    });
    throw new Error('expected rejection');
  } catch (error) {
    if (error instanceof Error && error.message === 'expected rejection') throw error;
  }
});

Deno.test('buildFcmMessageBatches encodes a task target into a safe path', () => {
  const batches = buildFcmMessageBatches(['token-1'], {
    title: 'Title',
    body: 'Body',
    target: 'task',
    recordId: 'task/42',
  });

  const data = batches[0]![0]!.data;
  if (data['path'] !== '/calendar/events/task%2F42') {
    throw new Error(`unexpected path: ${data['path']}`);
  }
  if (Object.values(data).some((value) => typeof value !== 'string')) {
    throw new Error('FCM data values must all be strings');
  }
});

Deno.test('buildFcmMessageBatches dedupes tokens and chunks at 500', () => {
  const tokens = Array.from({ length: 700 }, (_, index) =>
    index < 2 ? 'token-duplicate' : `token-${index}`
  );

  const batches = buildFcmMessageBatches(tokens, {
    title: 'Title',
    body: 'Body',
    path: '/advisories',
  });

  if (batches.length !== 2) throw new Error(`expected 2 batches, got ${batches.length}`);
  if (batches[0]!.length !== 500) throw new Error('first batch must cap at 500');
  const total = batches.flat().length;
  if (total !== 699) throw new Error(`expected 699 unique tokens, got ${total}`);
});

Deno.test('authorizeCampaignSender rejects a caller without app_metadata', () => {
  const result = authorizeCampaignSender(null);
  if (result.ok) throw new Error('expected rejection');
  if (result.status !== 401) throw new Error(`expected 401, got ${result.status}`);
});

Deno.test('authorizeCampaignSender rejects a farmer role', () => {
  const result = authorizeCampaignSender({ cooperative_role: 'farmer' });
  if (result.ok) throw new Error('expected rejection');
  if (result.status !== 403) throw new Error(`expected 403, got ${result.status}`);
});

Deno.test('authorizeCampaignSender allows admin and extension officer roles', () => {
  for (const role of ['admin', 'extension_officer']) {
    const result = authorizeCampaignSender({ cooperative_role: role });
    if (!result.ok) throw new Error(`expected ${role} to be allowed`);
    if (result.role !== role) throw new Error(`expected role ${role}`);
  }
});
