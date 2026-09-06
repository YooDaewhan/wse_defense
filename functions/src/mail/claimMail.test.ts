import { randomUUID } from 'crypto';
import { db } from '../common/admin';
import { fakeAuthedRequest } from '../battle/testSupport';
import { claimMailHandler } from './claimMail';

async function seedMail(
  uid: string,
  mailId: string,
  overrides: { claimedAt?: number | null; expireAt?: number; attachments?: Array<{ item: string; amount: number }> } = {},
): Promise<void> {
  await db.doc(`users/${uid}`).set({ currency: { gold: 0 } });
  await db.doc(`users/${uid}/mail/${mailId}`).set({
    titleKey: 'mail.test',
    bodyKey: 'mail.test.body',
    attachments: [{ item: 'ITM_GOLD', amount: 150 }],
    claimedAt: null,
    ...overrides,
  });
}

function req(uid: string, mailId: string) {
  return fakeAuthedRequest(uid, { idempotencyKey: randomUUID(), appVersion: '1.0.0', dataVersion: '1', mailId });
}

/** 06_BACKEND.md §2 users/{uid}/mail/{mailId}. 09_MILESTONES.md T-54 "우편". */
test('grants the attachments and marks the mail claimed', async () => {
  const uid = 'claimmail-user-1';
  await seedMail(uid, 'MAIL_1');

  const res = await claimMailHandler(req(uid, 'MAIL_1'));

  expect(res.rewards).toEqual([{ item: 'ITM_GOLD', amount: 150 }]);
  const account = await db.doc(`users/${uid}`).get();
  expect(account.data()?.currency.gold).toBe(150);
  const mail = await db.doc(`users/${uid}/mail/MAIL_1`).get();
  expect(mail.data()?.claimedAt).not.toBeNull();
});

test('rejects a mail that was already claimed', async () => {
  const uid = 'claimmail-user-2';
  await seedMail(uid, 'MAIL_1', { claimedAt: Date.now() });

  await expect(claimMailHandler(req(uid, 'MAIL_1'))).rejects.toThrow(/ALREADY_APPLIED/);
});

test('rejects an expired mail', async () => {
  const uid = 'claimmail-user-3';
  await seedMail(uid, 'MAIL_1', { expireAt: Date.now() - 1000 });

  await expect(claimMailHandler(req(uid, 'MAIL_1'))).rejects.toThrow(/VALIDATION_FAILED/);
});

test('rejects an unknown mailId', async () => {
  const uid = 'claimmail-user-4';

  await expect(claimMailHandler(req(uid, 'MAIL_NOT_REAL'))).rejects.toThrow(/VALIDATION_FAILED/);
});

test('idempotent: retrying with the same idempotencyKey does not grant twice', async () => {
  const uid = 'claimmail-user-5';
  await seedMail(uid, 'MAIL_1');
  const request = req(uid, 'MAIL_1');

  const first = await claimMailHandler(request);
  const second = await claimMailHandler(request);

  expect(second).toEqual(first);
  const account = await db.doc(`users/${uid}`).get();
  expect(account.data()?.currency.gold).toBe(150);
});
