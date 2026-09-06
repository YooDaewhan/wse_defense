import { db } from '../common/admin';
import { gameDateKey } from '../schedule/gameDay';
import { PUZZLE_STAGE_ID } from './puzzleData';
import { startBattleHandler } from './startBattle';
import { StartBattleReq } from './types';
import {
  fakeAuthedRequest,
  seedDeepForestStageMeta,
  seedDungeonStageMeta,
  seedOwnedAnimalFormation,
  seedOwnedFormation,
  seedPuzzleStageMeta,
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

/** 09_MILESTONES.md T-52 완료조건: "층별 태그 편성 제한". STG_DEEPFOREST_1
 * 은 제한이 없고, STG_DEEPFOREST_3은 TAG_RACE_ANIMAL 합 2 이상을 요구한다
 * (deepForestData.ts). */
test('T-52: starts a DEEP_FOREST battle for a floor with no tag restriction', async () => {
  await seedDeepForestStageMeta('STG_DEEPFOREST_1');
  const uid = 'start-user-9';
  await seedOwnedFormation(uid);

  const res = await startBattleHandler(
    fakeAuthedRequest(uid, req({ mode: 'DEEP_FOREST', stageId: 'STG_DEEPFOREST_1' })),
  );

  expect(res.battleId).toBeTruthy();
});

test('T-52: rejects a DEEP_FOREST floor when the formation does not meet the required tag total', async () => {
  await seedDeepForestStageMeta('STG_DEEPFOREST_3');
  const uid = 'start-user-10';
  await seedOwnedFormation(uid); // CHR_ACORN/CHR_DROPLET -- TAG_RACE_ANIMAL 없음

  await expect(
    startBattleHandler(fakeAuthedRequest(uid, req({ mode: 'DEEP_FOREST', stageId: 'STG_DEEPFOREST_3' }))),
  ).rejects.toThrow(/VALIDATION_FAILED/);
});

test('T-52: starts a DEEP_FOREST battle once the formation meets the required tag total', async () => {
  await seedDeepForestStageMeta('STG_DEEPFOREST_3');
  const uid = 'start-user-11';
  await seedOwnedAnimalFormation(uid); // CHR_BIRD+CHR_BEAR -- TAG_RACE_ANIMAL 합 2

  const res = await startBattleHandler(
    fakeAuthedRequest(uid, req({ mode: 'DEEP_FOREST', stageId: 'STG_DEEPFOREST_3' })),
  );

  expect(res.battleId).toBeTruthy();
});

/** 09_MILESTONES.md T-53 완료조건: "지정 편성" -- 소유 여부·저장된 편성
 * 프리셋과 무관하게 puzzleData.ts의 고정 덱이 그대로 스냅샷이 된다. */
test('T-53: starts a PUZZLE battle with the designated deck, ignoring ownership and saved presets', async () => {
  await seedPuzzleStageMeta();
  const uid = 'start-user-12'; // 계정도 캐릭터도 편성 프리셋도 전혀 없음

  const res = await startBattleHandler(
    fakeAuthedRequest(uid, req({ mode: 'PUZZLE', stageId: PUZZLE_STAGE_ID })),
  );

  expect(res.formationSnapshot.slots).toEqual([
    { characterId: 'CHR_ACORN', equipmentInstanceId: null },
    { characterId: 'CHR_DROPLET', equipmentInstanceId: null },
  ]);
});

test('T-53: rejects a PUZZLE battle for any stageId other than the designated weekly puzzle', async () => {
  await seedStageMeta();
  const uid = 'start-user-13';

  await expect(
    startBattleHandler(fakeAuthedRequest(uid, req({ mode: 'PUZZLE', stageId: TEST_STAGE_ID }))),
  ).rejects.toThrow(/VALIDATION_FAILED/);
});
