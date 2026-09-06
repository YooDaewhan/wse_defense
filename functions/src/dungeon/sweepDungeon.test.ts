import { randomUUID } from 'crypto';
import { db } from '../common/admin';
import { fakeAuthedRequest } from '../battle/testSupport';
import { sweepDungeonHandler } from './sweepDungeon';

async function seedClearedDungeon(uid: string, dungeonId: string, level: number): Promise<void> {
  await db.doc(`users/${uid}`).set({ progress: { clearedDungeons: { [dungeonId]: level } } }, { merge: true });
}

function req(uid: string, dungeonId: string, difficulty: number, times: number) {
  return fakeAuthedRequest(uid, {
    idempotencyKey: randomUUID(),
    appVersion: '1.0.0',
    dataVersion: '1',
    dungeonId,
    difficulty,
    times,
  });
}

/** 09_MILESTONES.md T-42 완료조건: "소탕 자격(클리어 기록) 확인, 차감+지급
 * 원자적", "6회 일괄 소탕 1탭". 드랍 추첨이 서버에서만 발생한다는 것은
 * 아키텍처로 보장된다 — 클라이언트 코드에는 드랍 RNG가 아예 없다
 * (dropRoll.ts는 functions/에만 존재). */
test('sweeping a cleared difficulty grants rewards and deducts the shared daily counter atomically', async () => {
  const uid = 'sweep-user-1';
  await seedClearedDungeon(uid, 'DGN_SUN', 1);

  const res = await sweepDungeonHandler(req(uid, 'DGN_SUN', 1, 6));

  expect(res.rewards.length).toBeGreaterThan(0);
  const gold = res.rewards.find((r) => r.item === 'ITM_GOLD');
  expect(gold).toBeDefined();
  expect(gold!.amount).toBeGreaterThanOrEqual(800 * 6); // 6회분 최소치
  expect(gold!.amount).toBeLessThanOrEqual(1200 * 6 * 1.5); // 보너스 요일까지 감안한 상한

  const counters = await db.collection(`users/${uid}/dailyCounters`).get();
  expect(counters.size).toBe(1);
  expect(counters.docs[0].data().totalDungeonRuns).toBe(6);
  expect(counters.docs[0].data().dungeonRuns.DGN_SUN).toBe(6);
});

test('rejects sweeping a difficulty that has never been cleared', async () => {
  const uid = 'sweep-user-2';
  await expect(sweepDungeonHandler(req(uid, 'DGN_SUN', 3, 1))).rejects.toThrow(/VALIDATION_FAILED/);
});

test('rejects times outside 1..6', async () => {
  const uid = 'sweep-user-3';
  await seedClearedDungeon(uid, 'DGN_SUN', 1);
  await expect(sweepDungeonHandler(req(uid, 'DGN_SUN', 1, 0))).rejects.toThrow();
  await expect(sweepDungeonHandler(req(uid, 'DGN_SUN', 1, 7))).rejects.toThrow();
});

test('rejects sweeping past the shared daily limit of 6', async () => {
  const uid = 'sweep-user-4';
  await seedClearedDungeon(uid, 'DGN_SUN', 1);
  await sweepDungeonHandler(req(uid, 'DGN_SUN', 1, 6));

  await expect(sweepDungeonHandler(req(uid, 'DGN_SUN', 1, 1))).rejects.toThrow(/DAILY_LIMIT_REACHED/);
});

test('the daily counter is shared across all 3 dungeons', async () => {
  const uid = 'sweep-user-5';
  await seedClearedDungeon(uid, 'DGN_SUN', 1);
  await seedClearedDungeon(uid, 'DGN_MOON', 1);

  await sweepDungeonHandler(req(uid, 'DGN_SUN', 1, 4));
  await expect(sweepDungeonHandler(req(uid, 'DGN_MOON', 1, 3))).rejects.toThrow(/DAILY_LIMIT_REACHED/);
  await sweepDungeonHandler(req(uid, 'DGN_MOON', 1, 2)); // 4+2=6, 딱 맞음

  const counters = await db.collection(`users/${uid}/dailyCounters`).get();
  expect(counters.docs[0].data().totalDungeonRuns).toBe(6);
});

test('idempotent: retrying with the same idempotencyKey does not grant rewards twice', async () => {
  const uid = 'sweep-user-6';
  await seedClearedDungeon(uid, 'DGN_SUN', 1);
  const request = req(uid, 'DGN_SUN', 1, 1);

  const first = await sweepDungeonHandler(request);
  const second = await sweepDungeonHandler(request);

  expect(second).toEqual(first);
  const counters = await db.collection(`users/${uid}/dailyCounters`).get();
  expect(counters.docs[0].data().totalDungeonRuns).toBe(1); // 2가 아니라 1
});
