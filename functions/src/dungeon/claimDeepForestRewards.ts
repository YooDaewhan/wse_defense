import { CallableRequest, HttpsError, onCall } from 'firebase-functions/v2/https';
import { db } from '../common/admin';
import { requireAuth } from '../common/auth';
import { withIdempotency } from '../common/idempotency';
import { applyRewards, currencyPatchFrom } from '../common/rewards';
import { AccountPatch, BaseRequest, Delta } from '../common/types';
import { gameWeekKey } from '../schedule/gameDay';
import { DEEP_FOREST_FLOORS_BY_NUMBER } from './deepForestData';

export interface ClaimDeepForestRewardsReq extends BaseRequest {
  /** 이 층까지 일괄 수령(§8 "일괄 보상 수령"). progress.deepForestBestFloor
   * 를 넘을 수 없다. */
  upToFloor: number;
}

export interface ClaimDeepForestRewardsRes {
  rewards: Delta[];
  patch: AccountPatch;
}

/**
 * 07_DUNGEON_EXCHANGE.md §8. 09_MILESTONES.md T-52 완료조건 "최고 층 기록
 * 유지, 주간 보상 상태만 초기화" -- 클리어 기록(progress.deepForestBestFloor)
 * 은 영구 문서에, 수령 상태(weeklyCounters/{yyyy-Www}.deepForestClaimedFloor)
 * 는 주 단위 문서에 둬서 매주 새 문서가 되는 것만으로 수령 상태가
 * 자연히 초기화된다(클리어 기록은 건드리지 않음).
 */
export async function claimDeepForestRewardsHandler(
  request: CallableRequest<ClaimDeepForestRewardsReq>,
): Promise<ClaimDeepForestRewardsRes> {
  const uid = requireAuth(request);
  const { upToFloor } = request.data;
  if (!Number.isInteger(upToFloor) || upToFloor < 1) throw new HttpsError('invalid-argument', 'VALIDATION_FAILED');

  return withIdempotency<ClaimDeepForestRewardsRes>(
    uid,
    request.data.idempotencyKey,
    'claimDeepForestRewards',
    async (tx) => {
      const userRef = db.doc(`users/${uid}`);
      const weekRef = db.doc(`users/${uid}/weeklyCounters/${gameWeekKey(new Date())}`);
      const [userSnap, weekSnap] = await Promise.all([tx.get(userRef), tx.get(weekRef)]);

      const bestFloor = (userSnap.data()?.progress?.deepForestBestFloor as number) ?? 0;
      if (upToFloor > bestFloor) throw new HttpsError('failed-precondition', 'VALIDATION_FAILED');

      const claimedFloor = (weekSnap.data()?.deepForestClaimedFloor as number) ?? 0;
      if (upToFloor <= claimedFloor) throw new HttpsError('failed-precondition', 'ALREADY_APPLIED');

      const rewards: Delta[] = [];
      for (let floor = claimedFloor + 1; floor <= upToFloor; floor++) {
        const floorMeta = DEEP_FOREST_FLOORS_BY_NUMBER[floor];
        if (floorMeta) rewards.push(...floorMeta.rewards);
      }

      tx.set(weekRef, { deepForestClaimedFloor: upToFloor }, { merge: true });
      applyRewards(tx, uid, rewards);

      return { result: { rewards, patch: { currency: currencyPatchFrom(rewards) } } };
    },
  );
}

export const claimDeepForestRewards = onCall(claimDeepForestRewardsHandler);
