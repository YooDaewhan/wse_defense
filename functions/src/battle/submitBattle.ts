import { randomInt } from 'crypto';
import { CallableRequest, HttpsError, onCall } from 'firebase-functions/v2/https';
import { admin, db } from '../common/admin';
import { requireAuth } from '../common/auth';
import { withIdempotency } from '../common/idempotency';
import { applyRewards, currencyPatchFrom } from '../common/rewards';
import { AccountPatch, Delta } from '../common/types';
import { CHARACTER_RESUMMON_COOLDOWN_SEC } from './characterData';
import { TICKS_PER_SEC } from './constants';
import { DEEP_FOREST_FLOORS_BY_STAGE } from '../dungeon/deepForestData';
import { aggregateRolls, rollDrops } from '../dungeon/dropRoll';
import { DUNGEONS_BY_ID, STAGE_ID_TO_DUNGEON } from '../dungeon/dungeonData';
import { gameDateKey, gameDayWeekday, gameWeekKey, isBonusDay, nextGameDayResetMs } from '../schedule/gameDay';
import { decodeInputLog } from './inputLog';
import { PUZZLE_REWARDS } from './puzzleData';
import { BattleDoc, StageMeta, SubmitBattleReq, SubmitBattleRes } from './types';
import {
  isOutlierResult,
  validateV10FormationOnlySummons,
  validateV12Checksum,
  validateV3Outcome,
  validateV4MinClearTime,
  validateV5MaxClearTime,
  validateV6PrayerBudget,
  validateV7SummonCadence,
  validateV8UltimateBudget,
  validateV9KillCount,
} from './validators';

interface InternalResult {
  accepted: boolean;
  /** V0~V13 중 어느 항목에서 반려됐는지 — 원장/로그 전용, 클라이언트에는 절대
   * 노출하지 않는다(06_BACKEND.md §4.4 "어떤 검증에 걸렸는지 노출 금지"). */
  rejectedAt?: string;
  rewards: Delta[];
  firstClear: boolean;
  patch: AccountPatch;
}

/** V0~V12 순서대로 검사하고, 첫 실패 지점을 반환한다(순수 함수 — 이미 읽어온
 * battle/meta/req만 본다). null이면 전부 통과. */
function findFirstFailedValidation(battle: BattleDoc, meta: StageMeta, req: SubmitBattleReq, now: number): string | null {
  if (battle.state !== 'issued' || now >= battle.expireAt) return 'V0';
  if (req.formationHash !== battle.formationHash) return 'V1';
  if (req.dataVersion !== battle.dataVersion) return 'V2';
  if (!validateV3Outcome(req.outcome)) return 'V3';
  if (!validateV4MinClearTime(req.summary.endTick, meta)) return 'V4';
  if (!validateV5MaxClearTime(req.summary.endTick, meta)) return 'V5';
  if (!validateV6PrayerBudget(req.summary, meta)) return 'V6';

  let decodedInputs;
  try {
    decodedInputs = decodeInputLog(req.inputLog, req.summary.endTick).inputs;
  } catch {
    return 'V11';
  }

  if (!validateV7SummonCadence(decodedInputs, req.summary.totalSummons, battle.formationSnapshot, CHARACTER_RESUMMON_COOLDOWN_SEC)) {
    return 'V7';
  }
  if (!validateV8UltimateBudget(req.summary)) return 'V8';
  if (!validateV9KillCount(req.summary, meta)) return 'V9';
  if (!validateV10FormationOnlySummons(decodedInputs, battle.formationSnapshot)) return 'V10';
  if (!validateV12Checksum(req.inputLog, battle.seed, req.formationHash, req.summary.checksum)) return 'V12';
  return null;
}

export async function submitBattleHandler(request: CallableRequest<SubmitBattleReq>): Promise<SubmitBattleRes> {
  const uid = requireAuth(request);
  const req = request.data;

  const internal = await withIdempotency<InternalResult>(uid, req.idempotencyKey, 'submitBattle', async (tx) => {
    const battleRef = db.doc(`users/${uid}/battles/${req.battleId}`);
    const userRef = db.doc(`users/${uid}`);

    // Firestore 트랜잭션은 모든 read가 write보다 먼저 끝나야 하므로 필요한
    // 문서를 전부 먼저 읽는다.
    const battleSnap = await tx.get(battleRef);
    if (!battleSnap.exists) {
      return { result: { accepted: false, rejectedAt: 'V0', rewards: [], firstClear: false, patch: {} } };
    }
    const battle = battleSnap.data() as BattleDoc;
    // DUNGEON 모드 배틀이면 stageId로 어느 던전 몇 난이도인지 알아낸다 —
    // 드랍표 선택과 dailyCounters 차감에 쓴다(07_DUNGEON_EXCHANGE.md §4).
    const dungeonRef = STAGE_ID_TO_DUNGEON[battle.stageId];
    const deepForestFloor = DEEP_FOREST_FLOORS_BY_STAGE[battle.stageId];
    const now = new Date();
    const counterRef = dungeonRef ? db.doc(`users/${uid}/dailyCounters/${gameDateKey(now)}`) : null;
    // PUZZLE 모드면 "주간 1회 보상"(puzzleCleared) 확인에 쓴다.
    const weekRef = battle.mode === 'PUZZLE' ? db.doc(`users/${uid}/weeklyCounters/${gameWeekKey(now)}`) : null;

    const [metaSnap, userSnap, counterSnap, weekSnap] = await Promise.all([
      tx.get(db.doc(`stagesMeta/${battle.stageId}`)),
      tx.get(userRef),
      counterRef ? tx.get(counterRef) : Promise.resolve(undefined),
      weekRef ? tx.get(weekRef) : Promise.resolve(undefined),
    ]);
    const meta = metaSnap.data() as StageMeta;

    const failedAt = findFirstFailedValidation(battle, meta, req, Date.now());
    if (failedAt !== null) {
      tx.update(battleRef, { state: 'submitted', result: { accepted: false, reason: failedAt } });
      return { result: { accepted: false, rejectedAt: failedAt, rewards: [], firstClear: false, patch: {} } };
    }

    if (isOutlierResult(req.summary, meta)) {
      tx.set(
        db.doc(`antiCheat/${uid}`),
        {
          flags: admin.firestore.FieldValue.increment(1),
          lastFlagAt: admin.firestore.FieldValue.serverTimestamp(),
          samples: admin.firestore.FieldValue.arrayUnion({ battleId: req.battleId, reason: 'outlier', at: Date.now() }),
        },
        { merge: true },
      );
    }

    let rewards: Delta[] = [];
    let firstClear = false;

    // 09_MILESTONES.md T-51 완료조건 "보상 없음, 진행도 영향 없음" --
    // 체험전은 outcome/dungeonRef와 무관하게 아래 두 분기를 전부 건너뛴다.
    if (battle.mode === 'TRIAL') {
      // no-op
    } else if (req.outcome === 'ALLY_WIN' && dungeonRef) {
      const dungeon = DUNGEONS_BY_ID[dungeonRef.dungeonId]!;
      const difficultyMeta = dungeon.difficulties.find((d) => d.level === dungeonRef.level)!;
      const bonusDay = isBonusDay(gameDayWeekday(now), dungeon.bonusWeekdays);
      rewards = rollDrops(difficultyMeta.drops, bonusDay, () => randomInt(1_000_000) / 1_000_000);

      const clearedDungeons = (userSnap.data()?.progress?.clearedDungeons ?? {}) as Record<string, number>;
      const prevLevel = clearedDungeons[dungeonRef.dungeonId] ?? 0;
      tx.update(userRef, {
        [`progress.clearedDungeons.${dungeonRef.dungeonId}`]: Math.max(prevLevel, dungeonRef.level),
      });

      const totalDungeonRuns = (counterSnap?.data()?.totalDungeonRuns as number) ?? 0;
      const dungeonRuns = { ...(counterSnap?.data()?.dungeonRuns ?? {}) };
      dungeonRuns[dungeonRef.dungeonId] = (dungeonRuns[dungeonRef.dungeonId] ?? 0) + 1;
      tx.set(
        counterRef!,
        { totalDungeonRuns: totalDungeonRuns + 1, dungeonRuns, expireAt: nextGameDayResetMs(now) },
        { merge: true },
      );
    } else if (req.outcome === 'ALLY_WIN' && deepForestFloor) {
      // 07_DUNGEON_EXCHANGE.md §8 "최고 층 기록 유지" -- 보상은 여기서
      // 주지 않는다. 실제 지급은 claimDeepForestRewards(주간 일괄 수령)의
      // 몫이라 클리어만으로 이중 지급되지 않게 한다.
      const prevBestFloor = (userSnap.data()?.progress?.deepForestBestFloor as number) ?? 0;
      tx.update(userRef, { 'progress.deepForestBestFloor': Math.max(prevBestFloor, deepForestFloor.floor) });
    } else if (req.outcome === 'ALLY_WIN' && battle.mode === 'PUZZLE') {
      // 09_MILESTONES.md T-53 완료조건 "주간 1회 보상" -- 이번 주에 이미
      // 받았으면 재도전은 보상 없이 통과만 시킨다.
      if (weekSnap?.data()?.puzzleCleared !== true) {
        rewards = PUZZLE_REWARDS;
        tx.set(weekRef!, { puzzleCleared: true }, { merge: true });
      }
    } else if (req.outcome === 'ALLY_WIN') {
      const clearedStages = (userSnap.data()?.progress?.clearedStages ?? {}) as Record<string, { bestClearSec: number }>;
      firstClear = !clearedStages[battle.stageId];
      rewards = firstClear ? meta.firstRewards : meta.repeatRewards;

      const clearSec = req.summary.endTick / TICKS_PER_SEC;
      const prevBest = clearedStages[battle.stageId]?.bestClearSec;
      tx.update(userRef, {
        [`progress.clearedStages.${battle.stageId}`]: {
          stars: 1,
          bestClearSec: prevBest === undefined ? clearSec : Math.min(prevBest, clearSec),
        },
      });
    }

    applyRewards(tx, uid, rewards);

    tx.update(battleRef, {
      state: 'submitted',
      result: { accepted: true, outcome: req.outcome, rewards, firstClear },
    });

    const patch: AccountPatch = { currency: currencyPatchFrom(rewards) };
    return { result: { accepted: true, rewards, firstClear, patch } };
  });

  if (!internal.accepted) {
    throw new HttpsError('failed-precondition', 'VALIDATION_FAILED');
  }
  return { accepted: true, rewards: internal.rewards, firstClear: internal.firstClear, patch: internal.patch };
}

export const submitBattle = onCall(submitBattleHandler);
