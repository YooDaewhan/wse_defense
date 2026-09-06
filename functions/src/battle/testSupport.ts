import { CallableRequest } from 'firebase-functions/v2/https';
import { db } from '../common/admin';
import { PUZZLE_STAGE_ID } from './puzzleData';
import { StageMeta } from './types';

export function fakeAuthedRequest<T>(uid: string, data: T): CallableRequest<T> {
  return { data, auth: { uid, token: {} } } as unknown as CallableRequest<T>;
}

export const TEST_STAGE_ID = 'STG_TEST';
export const TEST_DATA_VERSION = '1.0.0-test';

export const testStageMeta: StageMeta = {
  timeLimitSec: 300,
  minClearSec: 30,
  maxWaveEnemies: 40,
  maxKillPrayer: 500,
  enemyBaseHp: 5000,
  startingPrayerPower: 200,
  focusBaseRegen: 18,
  maxWeatherBonus: 1,
  firstRewards: [{ item: 'ITM_GOLD', amount: 100 }],
  repeatRewards: [{ item: 'ITM_GOLD', amount: 20 }],
};

export async function seedStageMeta(): Promise<void> {
  await db.doc(`stagesMeta/${TEST_STAGE_ID}`).set(testStageMeta);
}

/** DUNGEON 모드 배틀도 STORY와 똑같이 stagesMeta에서 시간/기도력/처치 상한을
 * 읽는다(V4~V9) — 드랍표만 dungeonData.ts(STAGE_ID_TO_DUNGEON)에서 온다.
 * `STG_DGN_SUN_1`은 실제 dungeonData.ts의 매핑과 일치해야 한다. */
export const TEST_DUNGEON_STAGE_ID = 'STG_DGN_SUN_1';
export const TEST_DUNGEON_ID = 'DGN_SUN';

export async function seedDungeonStageMeta(): Promise<void> {
  await db.doc(`stagesMeta/${TEST_DUNGEON_STAGE_ID}`).set({ ...testStageMeta, firstRewards: [], repeatRewards: [] });
}

/** puzzleData.ts의 PUZZLE_STAGE_ID와 짝을 맞춘 stagesMeta. */
export async function seedPuzzleStageMeta(): Promise<void> {
  await db.doc(`stagesMeta/${PUZZLE_STAGE_ID}`).set({ ...testStageMeta, firstRewards: [], repeatRewards: [] });
}

/** deepForestData.ts의 STG_DEEPFOREST_1(제한 없음)/STG_DEEPFOREST_3
 * (TAG_RACE_ANIMAL 2 이상)와 짝을 맞춘 stagesMeta. */
export async function seedDeepForestStageMeta(stageId: string): Promise<void> {
  await db.doc(`stagesMeta/${stageId}`).set({ ...testStageMeta, firstRewards: [], repeatRewards: [] });
}

/** CHR_BIRD(슬롯0)+CHR_BEAR(슬롯1) -- 이 저장소에서 TAG_RACE_ANIMAL을 가진
 * 유일한 두 캐릭터(각 1레벨, 합 2)라 깊은 숲 3층 제한을 충족한다. */
export async function seedOwnedAnimalFormation(uid: string, presetIndex = 0): Promise<void> {
  const userRef = db.doc(`users/${uid}`);
  if (!(await userRef.get()).exists) {
    await userRef.set({ progress: { clearedStages: {} }, currency: { gold: 0 } });
  }
  await db.doc(`users/${uid}/characters/CHR_BIRD`).set({ dupCount: 0 });
  await db.doc(`users/${uid}/characters/CHR_BEAR`).set({ dupCount: 0 });

  const slots: Array<{ characterId: string | null; equipmentInstanceId: string | null }> = Array.from(
    { length: 10 },
    () => ({ characterId: null, equipmentInstanceId: null }),
  );
  slots[0] = { characterId: 'CHR_BIRD', equipmentInstanceId: null };
  slots[1] = { characterId: 'CHR_BEAR', equipmentInstanceId: null };
  await db.doc(`users/${uid}/formations/${presetIndex}`).set({ slots, updatedAt: Date.now() });
}

/** users/{uid}에 CHR_ACORN(슬롯0), CHR_DROPLET(슬롯1)을 보유+편성한 상태를 만든다.
 * 계정 문서가 이미 있으면(같은 uid로 두 번째 전투를 시작하는 테스트) progress/
 * currency를 덮어쓰지 않는다 — set({merge:true})라도 중첩 객체 리터럴을
 * 통째로 주면 그 하위 필드(clearedStages 등)가 빈 값으로 리셋돼 버린다. */
export async function seedOwnedFormation(uid: string, presetIndex = 0): Promise<void> {
  const userRef = db.doc(`users/${uid}`);
  if (!(await userRef.get()).exists) {
    await userRef.set({ progress: { clearedStages: {} }, currency: { gold: 0 } });
  }
  await db.doc(`users/${uid}/characters/CHR_ACORN`).set({ dupCount: 0 });
  await db.doc(`users/${uid}/characters/CHR_DROPLET`).set({ dupCount: 0 });

  const slots: Array<{ characterId: string | null; equipmentInstanceId: string | null }> = Array.from(
    { length: 10 },
    () => ({ characterId: null, equipmentInstanceId: null }),
  );
  slots[0] = { characterId: 'CHR_ACORN', equipmentInstanceId: null };
  slots[1] = { characterId: 'CHR_DROPLET', equipmentInstanceId: null };
  await db.doc(`users/${uid}/formations/${presetIndex}`).set({ slots, updatedAt: Date.now() });
}
