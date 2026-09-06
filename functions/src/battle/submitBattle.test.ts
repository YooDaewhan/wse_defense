import { randomUUID } from 'crypto';
import { db } from '../common/admin';
import { gameDateKey } from '../schedule/gameDay';
import { TICKS_PER_SEC } from './constants';
import { encodeInputLog } from './inputLog';
import { PUZZLE_STAGE_ID } from './puzzleData';
import { startBattleHandler } from './startBattle';
import { submitBattleHandler } from './submitBattle';
import {
  fakeAuthedRequest,
  seedDeepForestStageMeta,
  seedDungeonStageMeta,
  seedOwnedFormation,
  seedPuzzleStageMeta,
  seedStageMeta,
  TEST_DATA_VERSION,
  TEST_DUNGEON_ID,
  TEST_DUNGEON_STAGE_ID,
  TEST_STAGE_ID,
} from './testSupport';
import { StartBattleRes, SubmitBattleReq } from './types';
import { computeV12Checksum } from './validators';

async function startFreshBattle(uid: string): Promise<StartBattleRes> {
  await seedStageMeta();
  await seedOwnedFormation(uid);
  return startBattleHandler(
    fakeAuthedRequest(uid, {
      idempotencyKey: 'unused',
      appVersion: '1.0.0',
      dataVersion: TEST_DATA_VERSION,
      mode: 'STORY',
      stageId: TEST_STAGE_ID,
      presetIndex: 0,
    }),
  );
}

async function startFreshDeepForestBattle(uid: string, stageId: string): Promise<StartBattleRes> {
  await seedDeepForestStageMeta(stageId);
  await seedOwnedFormation(uid);
  return startBattleHandler(
    fakeAuthedRequest(uid, {
      idempotencyKey: 'unused',
      appVersion: '1.0.0',
      dataVersion: TEST_DATA_VERSION,
      mode: 'DEEP_FOREST',
      stageId,
      presetIndex: 0,
    }),
  );
}

async function startFreshPuzzleBattle(uid: string): Promise<StartBattleRes> {
  await seedPuzzleStageMeta();
  // PUZZLE은 소유 검증을 건너뛰지만(지정 편성), 실제 플레이어는 이미
  // bootstrapAccount로 계정 문서가 있는 상태다 -- 보상 지급(currency
  // 필드 update)이 그 문서의 존재를 전제하므로 여기서도 만들어 둔다.
  await db.doc(`users/${uid}`).set({ currency: { gold: 0 } });
  return startBattleHandler(
    fakeAuthedRequest(uid, {
      idempotencyKey: 'unused',
      appVersion: '1.0.0',
      dataVersion: TEST_DATA_VERSION,
      mode: 'PUZZLE',
      stageId: PUZZLE_STAGE_ID,
      presetIndex: 0,
    }),
  );
}

async function startFreshTrialBattle(uid: string): Promise<StartBattleRes> {
  await seedStageMeta();
  return startBattleHandler(
    fakeAuthedRequest(uid, {
      idempotencyKey: 'unused',
      appVersion: '1.0.0',
      dataVersion: TEST_DATA_VERSION,
      mode: 'TRIAL',
      stageId: TEST_STAGE_ID,
      presetIndex: 0,
      trialCharacterId: 'CHR_BEAR',
    }),
  );
}

/** 체험전 편성은 슬롯 0(CHR_BEAR) 하나뿐이라 소환도 그 슬롯 하나만. */
function buildTrialHappyPathSubmission(battle: StartBattleRes, overrides: Partial<SubmitBattleReq> = {}): SubmitBattleReq {
  const endTick = 60 * TICKS_PER_SEC;
  const inputLog = encodeInputLog({
    seed: battle.seed,
    dataVersion: TEST_DATA_VERSION,
    stageId: TEST_STAGE_ID,
    formationHash: battle.formationSnapshot.formationHash,
    inputs: [{ type: 'SUMMON', tick: 0, slotIndex: 0 }],
  }).toString('base64');

  const summary: SubmitBattleReq['summary'] = {
    endTick,
    totalSummons: 1,
    totalPrayerSpent: 100,
    ultimateUsed: 0,
    focusBoostStage: 0,
    enemiesKilled: 5,
    enemyBaseHpLeft: 0,
    allyBaseHpLeft: 5000,
    maxFrontlineX: 2000,
    checksum: computeV12Checksum(inputLog, battle.seed, battle.formationSnapshot.formationHash),
  };

  return {
    idempotencyKey: randomUUID(),
    appVersion: '1.0.0',
    dataVersion: TEST_DATA_VERSION,
    battleId: battle.battleId,
    outcome: 'ALLY_WIN',
    summary,
    inputLog,
    formationHash: battle.formationSnapshot.formationHash,
    ...overrides,
  };
}

async function startFreshDungeonBattle(uid: string): Promise<StartBattleRes> {
  await seedDungeonStageMeta();
  await seedOwnedFormation(uid);
  return startBattleHandler(
    fakeAuthedRequest(uid, {
      idempotencyKey: 'unused',
      appVersion: '1.0.0',
      dataVersion: TEST_DATA_VERSION,
      mode: 'DUNGEON',
      stageId: TEST_DUNGEON_STAGE_ID,
      presetIndex: 0,
    }),
  );
}

/** 두 슬롯 모두 딱 한 번씩 소환하고, 필살기 1회 쓰는 "정상 클리어" 제출을
 * 만든다. 예산(V4~V9)은 testStageMeta 기준으로 넉넉히 통과하도록 잡았다. */
function buildHappyPathSubmission(battle: StartBattleRes, overrides: Partial<SubmitBattleReq> = {}): SubmitBattleReq {
  const endTick = 60 * TICKS_PER_SEC;
  const inputLog = encodeInputLog({
    seed: battle.seed,
    dataVersion: TEST_DATA_VERSION,
    stageId: TEST_STAGE_ID,
    formationHash: battle.formationSnapshot.formationHash,
    inputs: [
      { type: 'SUMMON', tick: 0, slotIndex: 0 },
      { type: 'SUMMON', tick: 0, slotIndex: 1 },
      { type: 'ULTIMATE', tick: 1000 },
    ],
  }).toString('base64');

  const summary: SubmitBattleReq['summary'] = {
    endTick,
    totalSummons: 2,
    totalPrayerSpent: 500,
    ultimateUsed: 1,
    focusBoostStage: 0,
    enemiesKilled: 5,
    enemyBaseHpLeft: 0,
    allyBaseHpLeft: 5000,
    maxFrontlineX: 2000,
    checksum: computeV12Checksum(inputLog, battle.seed, battle.formationSnapshot.formationHash),
  };

  return {
    idempotencyKey: randomUUID(),
    appVersion: '1.0.0',
    dataVersion: TEST_DATA_VERSION,
    battleId: battle.battleId,
    outcome: 'ALLY_WIN',
    summary,
    inputLog,
    formationHash: battle.formationSnapshot.formationHash,
    ...overrides,
  };
}

test('accepts a valid clear, grants first-clear rewards, and records progress', async () => {
  const uid = 'submit-user-1';
  const battle = await startFreshBattle(uid);
  const req = buildHappyPathSubmission(battle);

  const res = await submitBattleHandler(fakeAuthedRequest(uid, req));

  expect(res.accepted).toBe(true);
  expect(res.firstClear).toBe(true);
  expect(res.rewards).toEqual([{ item: 'ITM_GOLD', amount: 100 }]);
  expect(res.patch.currency?.gold).toBe(100);

  const userDoc = await db.doc(`users/${uid}`).get();
  expect(userDoc.data()?.progress.clearedStages[TEST_STAGE_ID].bestClearSec).toBe(60);
  expect(userDoc.data()?.currency.gold).toBe(100);
});

test('a second clear of the same stage grants repeat rewards, not first-clear rewards', async () => {
  const uid = 'submit-user-2';
  const battle1 = await startFreshBattle(uid);
  await submitBattleHandler(fakeAuthedRequest(uid, buildHappyPathSubmission(battle1)));

  const battle2 = await startFreshBattle(uid);
  const res2 = await submitBattleHandler(fakeAuthedRequest(uid, buildHappyPathSubmission(battle2)));

  expect(res2.firstClear).toBe(false);
  expect(res2.rewards).toEqual([{ item: 'ITM_GOLD', amount: 20 }]);
});

test('V0: resubmitting an already-submitted battle is rejected without exposing the reason', async () => {
  const uid = 'submit-user-3';
  const battle = await startFreshBattle(uid);
  const first = buildHappyPathSubmission(battle);
  await submitBattleHandler(fakeAuthedRequest(uid, first));

  const secondAttempt = { ...first, idempotencyKey: randomUUID() };
  await expect(submitBattleHandler(fakeAuthedRequest(uid, secondAttempt))).rejects.toThrow(/VALIDATION_FAILED/);

  const battleDoc = await db.doc(`users/${uid}/battles/${battle.battleId}`).get();
  expect(battleDoc.data()?.result.reason).toBe('V0');
});

test('V1: a tampered formationHash is rejected, and the internal reason (not shown to the client) is V1', async () => {
  const uid = 'submit-user-4';
  const battle = await startFreshBattle(uid);
  const req = buildHappyPathSubmission(battle, { formationHash: 'tampered-hash' });

  let clientError: Error | undefined;
  try {
    await submitBattleHandler(fakeAuthedRequest(uid, req));
  } catch (e) {
    clientError = e as Error;
  }
  expect(clientError?.message).toMatch(/VALIDATION_FAILED/);
  expect(clientError?.message).not.toMatch(/V1/);

  const battleDoc = await db.doc(`users/${uid}/battles/${battle.battleId}`).get();
  expect(battleDoc.data()?.result.reason).toBe('V1');
});

test('V2: a stale dataVersion is rejected', async () => {
  const uid = 'submit-user-5';
  const battle = await startFreshBattle(uid);
  const req = buildHappyPathSubmission(battle, { dataVersion: 'old-version' });

  await expect(submitBattleHandler(fakeAuthedRequest(uid, req))).rejects.toThrow(/VALIDATION_FAILED/);
  const battleDoc = await db.doc(`users/${uid}/battles/${battle.battleId}`).get();
  expect(battleDoc.data()?.result.reason).toBe('V2');
});

test('V7 end-to-end: a resubmitted battle with an impossible summon cadence is rejected as V7', async () => {
  const uid = 'submit-user-6';
  const battle = await startFreshBattle(uid);
  // 슬롯0(CHR_ACORN, 쿨다운 4초=120틱)을 0틱과 1틱에 연속 소환 -> 물리적으로 불가능.
  const inputLog = encodeInputLog({
    seed: battle.seed,
    dataVersion: TEST_DATA_VERSION,
    stageId: TEST_STAGE_ID,
    formationHash: battle.formationSnapshot.formationHash,
    inputs: [
      { type: 'SUMMON', tick: 0, slotIndex: 0 },
      { type: 'SUMMON', tick: 1, slotIndex: 0 },
    ],
  }).toString('base64');
  const req = buildHappyPathSubmission(battle, {
    inputLog,
    summary: {
      ...buildHappyPathSubmission(battle).summary,
      totalSummons: 2,
      checksum: computeV12Checksum(inputLog, battle.seed, battle.formationSnapshot.formationHash),
    },
  });

  await expect(submitBattleHandler(fakeAuthedRequest(uid, req))).rejects.toThrow(/VALIDATION_FAILED/);
  const battleDoc = await db.doc(`users/${uid}/battles/${battle.battleId}`).get();
  expect(battleDoc.data()?.result.reason).toBe('V7');
});

test('idempotency: resubmitting with the same idempotencyKey does not grant rewards twice', async () => {
  const uid = 'submit-user-7';
  const battle = await startFreshBattle(uid);
  const req = buildHappyPathSubmission(battle);

  const first = await submitBattleHandler(fakeAuthedRequest(uid, req));
  const second = await submitBattleHandler(fakeAuthedRequest(uid, req)); // 같은 idempotencyKey로 재시도

  expect(second).toEqual(first);
  const userDoc = await db.doc(`users/${uid}`).get();
  expect(userDoc.data()?.currency.gold).toBe(100); // 200이 아니라 100 -- 한 번만 지급
});

test('T-42: a DUNGEON-mode clear rolls the dungeon drop table, deducts the shared daily counter, and records clearedDungeons', async () => {
  const uid = 'submit-user-8';
  const battle = await startFreshDungeonBattle(uid);
  const req = buildHappyPathSubmission(battle);

  const res = await submitBattleHandler(fakeAuthedRequest(uid, req));

  expect(res.accepted).toBe(true);
  // stagesMeta의 firstRewards/repeatRewards가 아니라 dungeonData.ts의 드랍표에서 왔다
  // (테스트 지원 함수가 그 stagesMeta 값을 일부러 빈 배열로 세팅해뒀다).
  expect(res.rewards.some((r) => r.item === 'ITM_GOLD')).toBe(true);
  expect(res.rewards.some((r) => r.item === 'ITM_SHARD_SUN_T1')).toBe(true);

  const userDoc = await db.doc(`users/${uid}`).get();
  expect(userDoc.data()?.progress.clearedDungeons[TEST_DUNGEON_ID]).toBe(1);

  const counters = await db.collection(`users/${uid}/dailyCounters`).get();
  expect(counters.size).toBe(1);
  expect(counters.docs[0].data().totalDungeonRuns).toBe(1);
  expect(counters.docs[0].data().dungeonRuns[TEST_DUNGEON_ID]).toBe(1);
});

test('T-42: a second DUNGEON clear the same day accumulates the shared counter', async () => {
  const uid = 'submit-user-9';
  const battle1 = await startFreshDungeonBattle(uid);
  await submitBattleHandler(fakeAuthedRequest(uid, buildHappyPathSubmission(battle1)));

  const battle2 = await startFreshDungeonBattle(uid);
  await submitBattleHandler(fakeAuthedRequest(uid, buildHappyPathSubmission(battle2)));

  const counters = await db.collection(`users/${uid}/dailyCounters`).get();
  expect(counters.docs[0].data().totalDungeonRuns).toBe(2);
});

/** 09_MILESTONES.md T-51 완료조건: "보상 없음, 진행도 영향 없음". */
test('T-51: a TRIAL clear grants no rewards and leaves progress untouched', async () => {
  const uid = 'submit-user-10'; // 계정 문서도 미리 만들지 않음(진행도 영향이 정말 없는지 확인)
  const battle = await startFreshTrialBattle(uid);

  const res = await submitBattleHandler(fakeAuthedRequest(uid, buildTrialHappyPathSubmission(battle)));

  expect(res.accepted).toBe(true);
  expect(res.rewards).toEqual([]);
  expect(res.firstClear).toBe(false);

  const userDoc = await db.doc(`users/${uid}`).get();
  expect(userDoc.data()?.progress?.clearedStages?.[TEST_STAGE_ID]).toBeUndefined();
});

/** 09_MILESTONES.md T-52 완료조건: "최고 층 기록 유지". 보상은 여기서
 * 주지 않는다(claimDeepForestRewards가 주간 일괄 수령을 맡는다). */
test('T-52: a DEEP_FOREST clear records the floor and grants no direct reward', async () => {
  const uid = 'submit-user-11';
  const battle = await startFreshDeepForestBattle(uid, 'STG_DEEPFOREST_2');

  const res = await submitBattleHandler(fakeAuthedRequest(uid, buildHappyPathSubmission(battle)));

  expect(res.rewards).toEqual([]);
  const userDoc = await db.doc(`users/${uid}`).get();
  expect(userDoc.data()?.progress.deepForestBestFloor).toBe(2);
});

test('T-52: the best floor record never decreases on a later, lower-floor clear', async () => {
  const uid = 'submit-user-12';
  const battle1 = await startFreshDeepForestBattle(uid, 'STG_DEEPFOREST_2');
  await submitBattleHandler(fakeAuthedRequest(uid, buildHappyPathSubmission(battle1)));

  const battle2 = await startFreshDeepForestBattle(uid, 'STG_DEEPFOREST_1');
  await submitBattleHandler(fakeAuthedRequest(uid, buildHappyPathSubmission(battle2)));

  const userDoc = await db.doc(`users/${uid}`).get();
  expect(userDoc.data()?.progress.deepForestBestFloor).toBe(2);
});

/** 09_MILESTONES.md T-53 완료조건: "주간 1회 보상". */
test('T-53: the first PUZZLE clear this week grants the reward', async () => {
  const uid = 'submit-user-13';
  const battle = await startFreshPuzzleBattle(uid);

  const res = await submitBattleHandler(fakeAuthedRequest(uid, buildHappyPathSubmission(battle)));

  expect(res.rewards).toEqual([{ item: 'ITM_GOLD', amount: 500 }]);
});

test('T-53: a second PUZZLE clear the same week grants no further reward', async () => {
  const uid = 'submit-user-14';
  const battle1 = await startFreshPuzzleBattle(uid);
  await submitBattleHandler(fakeAuthedRequest(uid, buildHappyPathSubmission(battle1)));

  const battle2 = await startFreshPuzzleBattle(uid);
  const res2 = await submitBattleHandler(fakeAuthedRequest(uid, buildHappyPathSubmission(battle2)));

  expect(res2.rewards).toEqual([]);
});

/** 09_MILESTONES.md T-54 MSN_BATTLE -- 어느 모드든 승리만 하면 대체
 * 조건을 만족한다(TRIAL만 예외, 위 "진행도 영향 없음" 테스트로 확인). */
test('T-54: a STORY win counts as the battle-mission trigger', async () => {
  const uid = 'submit-user-15';
  const battle = await startFreshBattle(uid);

  await submitBattleHandler(fakeAuthedRequest(uid, buildHappyPathSubmission(battle)));

  const counter = await db.doc(`users/${uid}/dailyCounters/${gameDateKey(new Date())}`).get();
  expect(counter.data()?.missionProgress.MSN_BATTLE).toBe(1);
});

test('T-54: a TRIAL win does not count toward the battle mission', async () => {
  const uid = 'submit-user-16';
  const battle = await startFreshTrialBattle(uid);

  await submitBattleHandler(fakeAuthedRequest(uid, buildTrialHappyPathSubmission(battle)));

  const counter = await db.doc(`users/${uid}/dailyCounters/${gameDateKey(new Date())}`).get();
  expect(counter.data()?.missionProgress?.MSN_BATTLE).toBeUndefined();
});
