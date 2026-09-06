import { db } from '../common/admin';
import { gameDateKey } from '../schedule/gameDay';
import { startBattleHandler } from './startBattle';
import { StartBattleReq } from './types';
import {
  fakeAuthedRequest,
  seedDungeonStageMeta,
  seedOwnedFormation,
  seedStageMeta,
  TEST_DATA_VERSION,
  TEST_DUNGEON_STAGE_ID,
  TEST_STAGE_ID,
} from './testSupport';

function req(overrides: Partial<StartBattleReq> = {}): StartBattleReq {
  return {
    idempotencyKey: 'unused-for-start',
    appVersion: '1.0.0',
    dataVersion: TEST_DATA_VERSION,
    mode: 'STORY',
    stageId: TEST_STAGE_ID,
    presetIndex: 0,
    ...overrides,
  };
}

test('starts a battle for an owned formation and returns a matching formationSnapshot', async () => {
  await seedStageMeta();
  const uid = 'start-user-1';
  await seedOwnedFormation(uid);

  const res = await startBattleHandler(fakeAuthedRequest(uid, req()));

  expect(res.battleId).toBeTruthy();
  expect(res.formationSnapshot.slots[0].characterId).toBe('CHR_ACORN');
  expect(res.formationSnapshot.slots[1].characterId).toBe('CHR_DROPLET');
  expect(res.expireAtMs).toBeGreaterThan(res.serverTimeMs);

  const battleDoc = await db.doc(`users/${uid}/battles/${res.battleId}`).get();
  expect(battleDoc.data()?.state).toBe('issued');
  expect(battleDoc.data()?.formationHash).toBe(res.formationSnapshot.formationHash);
});

test('rejects a formation containing a character the account does not own', async () => {
  await seedStageMeta();
  const uid = 'start-user-2';
  await db.doc(`users/${uid}`).set({ progress: { clearedStages: {} } }, { merge: true });
  await db.doc(`users/${uid}/characters/CHR_ACORN`).set({ dupCount: 0 });
  const slots = Array.from({ length: 10 }, () => ({ characterId: null as string | null, equipmentInstanceId: null }));
  slots[0] = { characterId: 'CHR_ACORN', equipmentInstanceId: null };
  slots[1] = { characterId: 'CHR_BEAR', equipmentInstanceId: null }; // 미보유
  await db.doc(`users/${uid}/formations/0`).set({ slots, updatedAt: Date.now() });

  await expect(startBattleHandler(fakeAuthedRequest(uid, req()))).rejects.toThrow();
});

test('rejects a duplicated character across slots', async () => {
  await seedStageMeta();
  const uid = 'start-user-3';
  await db.doc(`users/${uid}`).set({ progress: { clearedStages: {} } }, { merge: true });
  await db.doc(`users/${uid}/characters/CHR_ACORN`).set({ dupCount: 0 });
  const slots = Array.from({ length: 10 }, () => ({ characterId: null as string | null, equipmentInstanceId: null }));
  slots[0] = { characterId: 'CHR_ACORN', equipmentInstanceId: null };
  slots[1] = { characterId: 'CHR_ACORN', equipmentInstanceId: null };
  await db.doc(`users/${uid}/formations/0`).set({ slots, updatedAt: Date.now() });

  await expect(startBattleHandler(fakeAuthedRequest(uid, req()))).rejects.toThrow();
});

test('rejects when dataVersion does not match gameData/current', async () => {
  await seedStageMeta();
  await db.doc('gameData/current').set({ dataVersion: TEST_DATA_VERSION, minAppVersion: '1.0.0' });
  const uid = 'start-user-4';
  await seedOwnedFormation(uid);

  await expect(startBattleHandler(fakeAuthedRequest(uid, req({ dataVersion: 'stale-version' })))).rejects.toThrow();
});

test('T-42: rejects starting a DUNGEON battle once the shared daily limit (6) is already used', async () => {
  await seedDungeonStageMeta();
  const uid = 'start-user-5';
  await seedOwnedFormation(uid);
  const dateKey = gameDateKey(new Date());
  await db.doc(`users/${uid}/dailyCounters/${dateKey}`).set({ totalDungeonRuns: 6, dungeonRuns: { DGN_SUN: 6 } });

  await expect(
    startBattleHandler(fakeAuthedRequest(uid, req({ mode: 'DUNGEON', stageId: TEST_DUNGEON_STAGE_ID }))),
  ).rejects.toThrow(/DAILY_LIMIT_REACHED/);
});

test('T-42: allows starting a DUNGEON battle when runs remain', async () => {
  await seedDungeonStageMeta();
  const uid = 'start-user-6';
  await seedOwnedFormation(uid);
  const dateKey = gameDateKey(new Date());
  await db.doc(`users/${uid}/dailyCounters/${dateKey}`).set({ totalDungeonRuns: 5, dungeonRuns: { DGN_SUN: 5 } });

  const res = await startBattleHandler(
    fakeAuthedRequest(uid, req({ mode: 'DUNGEON', stageId: TEST_DUNGEON_STAGE_ID })),
  );
  expect(res.battleId).toBeTruthy();
});

/** 09_MILESTONES.md T-51 완료조건: "미보유 픽업 캐릭터를 지정 레벨로
 * 사용". CHR_BEAR는 assets/data/v1/banners.json의 상시(기간 무제한) 픽업
 * 캐릭터다. */
test('T-51: starts a TRIAL battle with an unowned pickup character, bypassing ownership', async () => {
  await seedStageMeta();
  const uid = 'start-user-7'; // 계정 문서도, CHR_BEAR 보유도 전혀 없음

  const res = await startBattleHandler(
    fakeAuthedRequest(uid, req({ mode: 'TRIAL', trialCharacterId: 'CHR_BEAR' })),
  );

  expect(res.formationSnapshot.slots).toEqual([{ characterId: 'CHR_BEAR', equipmentInstanceId: null }]);
});

test('T-51: rejects a TRIAL battle for a character that is not currently a pickup', async () => {
  await seedStageMeta();
  const uid = 'start-user-8';

  await expect(
    startBattleHandler(fakeAuthedRequest(uid, req({ mode: 'TRIAL', trialCharacterId: 'CHR_ACORN' }))),
  ).rejects.toThrow(/BANNER_CLOSED/);
});
