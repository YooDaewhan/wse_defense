import { randomUUID } from 'crypto';
import { db } from '../common/admin';
import { fakeAuthedRequest } from '../battle/testSupport';
import { gameWeekKey } from '../schedule/gameDay';
import { claimDeepForestRewardsHandler } from './claimDeepForestRewards';

async function seedBestFloor(uid: string, bestFloor: number): Promise<void> {
  await db.doc(`users/${uid}`).set({ currency: { gold: 0 }, progress: { deepForestBestFloor: bestFloor } });
}

function req(uid: string, upToFloor: number) {
  return fakeAuthedRequest(uid, { idempotencyKey: randomUUID(), appVersion: '1.0.0', dataVersion: '1', upToFloor });
}

/** 07_DUNGEON_EXCHANGE.md §8 "이미 정복한 층: 일괄 보상 수령".
 * 09_MILESTONES.md T-52 완료조건: "주간 보상 상태만 초기화". */
test('rejects claiming a floor beyond the recorded best floor', async () => {
  const uid = 'claimdf-user-1';
  await seedBestFloor(uid, 1);

  await expect(claimDeepForestRewardsHandler(req(uid, 2))).rejects.toThrow(/VALIDATION_FAILED/);
});

test('claims combined rewards for every floor up to the requested floor', async () => {
  const uid = 'claimdf-user-2';
  await seedBestFloor(uid, 2);

  const res = await claimDeepForestRewardsHandler(req(uid, 2));

  // deepForestData.ts: 층1 ITM_SHARD_SUN_T2×5, 층2 ITM_SHARD_MOON_T2×5.
  expect(res.rewards).toEqual([
    { item: 'ITM_SHARD_SUN_T2', amount: 5 },
    { item: 'ITM_SHARD_MOON_T2', amount: 5 },
  ]);

  const weekDoc = await db.doc(`users/${uid}/weeklyCounters/${gameWeekKey(new Date())}`).get();
  expect(weekDoc.data()?.deepForestClaimedFloor).toBe(2);
});

test('rejects re-claiming a floor already claimed this week', async () => {
  const uid = 'claimdf-user-3';
  await seedBestFloor(uid, 2);
  await claimDeepForestRewardsHandler(req(uid, 2));

  await expect(claimDeepForestRewardsHandler(req(uid, 2))).rejects.toThrow(/ALREADY_APPLIED/);
});

test('allows claiming further floors after progressing, granting only the newly reachable rewards', async () => {
  const uid = 'claimdf-user-4';
  await seedBestFloor(uid, 2);
  await claimDeepForestRewardsHandler(req(uid, 2));

  await db.doc(`users/${uid}`).set({ progress: { deepForestBestFloor: 3 } }, { merge: true });
  const res = await claimDeepForestRewardsHandler(req(uid, 3));

  expect(res.rewards).toEqual([{ item: 'ITM_SHARD_FIELD_T3', amount: 3 }]); // 층3만
});

test('idempotent: retrying with the same idempotencyKey does not grant twice', async () => {
  const uid = 'claimdf-user-5';
  await seedBestFloor(uid, 1);
  const request = req(uid, 1);

  const first = await claimDeepForestRewardsHandler(request);
  const second = await claimDeepForestRewardsHandler(request);

  expect(second).toEqual(first);
  const shard = await db.doc(`users/${uid}/items/ITM_SHARD_SUN_T2`).get();
  expect(shard.data()?.amount).toBe(5); // 두 번 지급됐다면 10이었을 것
});
