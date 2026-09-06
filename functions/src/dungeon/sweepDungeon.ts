import { randomInt } from 'crypto';
import { CallableRequest, HttpsError, onCall } from 'firebase-functions/v2/https';
import { db } from '../common/admin';
import { requireAuth } from '../common/auth';
import { withIdempotency } from '../common/idempotency';
import { applyRewards, currencyPatchFrom } from '../common/rewards';
import { gameDateKey, gameDayWeekday, isBonusDay, nextGameDayResetMs } from '../schedule/gameDay';
import { AccountPatch, BaseRequest } from '../common/types';
import { aggregateRolls, RolledItem, rollDrops } from './dropRoll';
import { DAILY_RUN_LIMIT, DUNGEONS_BY_ID } from './dungeonData';

export interface SweepDungeonReq extends BaseRequest {
  dungeonId: string;
  difficulty: number;
  /** 1~6, 한 번의 호출로 최대 6회까지 일괄 소탕(§9 "1탭"). */
  times: number;
}

export interface SweepDungeonRes {
  rewards: RolledItem[];
  patch: AccountPatch;
}

function rand(): number {
  return randomInt(1_000_000) / 1_000_000;
}

/** 07_DUNGEON_EXCHANGE.md §4, 06_BACKEND.md §4.5. 드랍 추첨은 여기(서버)
 * 에서만 일어난다 — 클라이언트 코드 어디에도 드랍 RNG가 없다. */
export async function sweepDungeonHandler(request: CallableRequest<SweepDungeonReq>): Promise<SweepDungeonRes> {
  const uid = requireAuth(request);
  const { dungeonId, difficulty, times } = request.data;

  if (!Number.isInteger(times) || times < 1 || times > 6) {
    throw new HttpsError('invalid-argument', 'VALIDATION_FAILED');
  }
  const dungeon = DUNGEONS_BY_ID[dungeonId];
  const difficultyMeta = dungeon?.difficulties.find((d) => d.level === difficulty);
  if (!dungeon || !difficultyMeta) throw new HttpsError('not-found', 'VALIDATION_FAILED');

  return withIdempotency<SweepDungeonRes>(uid, request.data.idempotencyKey, 'sweepDungeon', async (tx) => {
    const userRef = db.doc(`users/${uid}`);
    const now = new Date();
    const dateKey = gameDateKey(now);
    const counterRef = db.doc(`users/${uid}/dailyCounters/${dateKey}`);

    const [userSnap, counterSnap] = await Promise.all([tx.get(userRef), tx.get(counterRef)]);

    // 소탕 자격: 이 난이도를 1회 이상 클리어한 기록이 있어야 한다.
    const clearedLevel = (userSnap.data()?.progress?.clearedDungeons?.[dungeonId] as number) ?? 0;
    if (clearedLevel < difficulty) {
      throw new HttpsError('failed-precondition', 'VALIDATION_FAILED');
    }

    const totalDungeonRuns = (counterSnap.data()?.totalDungeonRuns as number) ?? 0;
    if (totalDungeonRuns + times > DAILY_RUN_LIMIT) {
      throw new HttpsError('resource-exhausted', 'DAILY_LIMIT_REACHED');
    }

    const bonusDay = isBonusDay(gameDayWeekday(now), dungeon.bonusWeekdays);
    const rolls = Array.from({ length: times }, () => rollDrops(difficultyMeta.drops, bonusDay, rand));
    const rewards = aggregateRolls(rolls);

    // 차감(잔여 횟수)과 지급(아이템/골드)을 전부 같은 트랜잭션에서 커밋한다.
    const dungeonRuns = { ...(counterSnap.data()?.dungeonRuns ?? {}) };
    dungeonRuns[dungeonId] = (dungeonRuns[dungeonId] ?? 0) + times;
    tx.set(
      counterRef,
      { totalDungeonRuns: totalDungeonRuns + times, dungeonRuns, expireAt: nextGameDayResetMs(now) },
      { merge: true },
    );

    applyRewards(tx, uid, rewards);

    return { result: { rewards, patch: { currency: currencyPatchFrom(rewards) } } };
  });
}

export const sweepDungeon = onCall(sweepDungeonHandler);
