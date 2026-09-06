import { CallableRequest } from 'firebase-functions/v2/https';
import { db } from '../common/admin';
import { bootstrapAccountHandler, BootstrapAccountReq } from './bootstrapAccount';

function fakeRequest(uid: string): CallableRequest<BootstrapAccountReq> {
  return {
    data: { appVersion: '1.0.0', dataVersion: '1.0.0' },
    auth: { uid, token: {} },
  } as unknown as CallableRequest<BootstrapAccountReq>;
}

test('creates a new account with 5 starter characters and 3 formation presets', async () => {
  const uid = 'boot-user-1';
  const res = await bootstrapAccountHandler(fakeRequest(uid));
  expect(res.ok).toBe(true);

  const chars = await db.collection(`users/${uid}/characters`).get();
  expect(chars.docs.map((d) => d.id).sort()).toEqual(['CHR_ACORN', 'CHR_BEAR', 'CHR_BIRD', 'CHR_DROPLET', 'CHR_MUSHROOM']);

  const formations = await db.collection(`users/${uid}/formations`).get();
  expect(formations.size).toBe(3);
  for (const doc of formations.docs) {
    expect(doc.data().slots).toHaveLength(10);
  }
});

test('09_MILESTONES.md T-36 완료조건: bootstrapAccount 멱등 (2회 호출 시 상태 동일)', async () => {
  const uid = 'boot-user-2';
  await bootstrapAccountHandler(fakeRequest(uid));
  const afterFirst = (await db.doc(`users/${uid}`).get()).data();

  const second = await bootstrapAccountHandler(fakeRequest(uid));
  expect(second.data).toEqual(afterFirst);

  const chars = await db.collection(`users/${uid}/characters`).get();
  expect(chars.size).toBe(5); // 두 번째 호출이 중복 생성하지 않았다
});

test('rejects unauthenticated calls', async () => {
  const req = { data: { appVersion: '1.0.0', dataVersion: '1.0.0' } } as unknown as CallableRequest<BootstrapAccountReq>;
  await expect(bootstrapAccountHandler(req)).rejects.toThrow();
});
