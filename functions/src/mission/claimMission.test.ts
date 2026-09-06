import { randomUUID } from 'crypto';
import { db } from '../common/admin';
import { fakeAuthedRequest } from '../battle/testSupport';
import { gameDateKey } from '../schedule/gameDay';
import { claimMissionHandler } from './claimMission';

async function seedProgress(uid: string, missionId: string, progress: number): Promise<void> {
  await db.doc(`users/${uid}`).set({ currency: { gold: 0 } });
  await db.doc(`users/${uid}/dailyCounters/${gameDateKey(new Date())}`).set({ missionProgress: { [missionId]: progress } });
}

function req(uid: string, missionId: string) {
  return fakeAuthedRequest(uid, { idempotencyKey: randomUUID(), appVersion: '1.0.0', dataVersion: '1', missionId });
}

/** 09_MILESTONES.md T-54. */
test('rejects claiming a mission whose progress has not yet reached its requirement', async () => {
  const uid = 'claimmsn-user-1';
  await seedProgress(uid, 'MSN_BATTLE', 0);

  await expect(claimMissionHandler(req(uid, 'MSN_BATTLE'))).rejects.toThrow(/VALIDATION_FAILED/);
});

test('grants the reward once progress meets the requirement', async () => {
  const uid = 'claimmsn-user-2';
  await seedProgress(uid, 'MSN_BATTLE', 1);

  const res = await claimMissionHandler(req(uid, 'MSN_BATTLE'));

  expect(res.rewards).toEqual([{ item: 'ITM_GOLD', amount: 300 }]);
  const account = await db.doc(`users/${uid}`).get();
  expect(account.data()?.currency.gold).toBe(300);
});

test('rejects claiming the same mission twice the same day', async () => {
  const uid = 'claimmsn-user-3';
  await seedProgress(uid, 'MSN_LOGIN', 1);
  await claimMissionHandler(req(uid, 'MSN_LOGIN'));

  await expect(claimMissionHandler(req(uid, 'MSN_LOGIN'))).rejects.toThrow(/ALREADY_APPLIED/);
});

test('idempotent: retrying with the same idempotencyKey does not grant twice', async () => {
  const uid = 'claimmsn-user-4';
  await seedProgress(uid, 'MSN_GROWTH', 1);
  const request = req(uid, 'MSN_GROWTH');

  const first = await claimMissionHandler(request);
  const second = await claimMissionHandler(request);

  expect(second).toEqual(first);
  const account = await db.doc(`users/${uid}`).get();
  expect(account.data()?.currency.gold).toBe(300); // 두 번 안 지급됨
});
