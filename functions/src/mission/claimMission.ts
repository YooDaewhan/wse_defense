import { CallableRequest, HttpsError, onCall } from 'firebase-functions/v2/https';
import { admin, db } from '../common/admin';
import { requireAuth } from '../common/auth';
import { withIdempotency } from '../common/idempotency';
import { applyRewards, currencyPatchFrom } from '../common/rewards';
import { AccountPatch, BaseRequest, Delta } from '../common/types';
import { gameDateKey, nextGameDayResetMs } from '../schedule/gameDay';
import { MISSIONS_BY_ID } from './missionData';

export interface ClaimMissionReq extends BaseRequest {
  missionId: string;
}

export interface ClaimMissionRes {
  rewards: Delta[];
  patch: AccountPatch;
}

/** 06_BACKEND.md `claimMission`. 미션별 오늘 진행도(dailyCounters.
 * missionProgress)가 요구치를 채웠고 아직 안 받았으면(dailyCounters.
 * missionClaimed에 없으면) 지급한다. */
export async function claimMissionHandler(request: CallableRequest<ClaimMissionReq>): Promise<ClaimMissionRes> {
  const uid = requireAuth(request);
  const { missionId } = request.data;

  const mission = MISSIONS_BY_ID[missionId];
  if (!mission) throw new HttpsError('not-found', 'VALIDATION_FAILED');

  return withIdempotency<ClaimMissionRes>(uid, request.data.idempotencyKey, 'claimMission', async (tx) => {
    const now = new Date();
    const counterRef = db.doc(`users/${uid}/dailyCounters/${gameDateKey(now)}`);
    const counterSnap = await tx.get(counterRef);

    const progress = (counterSnap.data()?.missionProgress?.[missionId] as number) ?? 0;
    if (progress < mission.requiredCount) throw new HttpsError('failed-precondition', 'VALIDATION_FAILED');

    const claimed = (counterSnap.data()?.missionClaimed as string[]) ?? [];
    if (claimed.includes(missionId)) throw new HttpsError('failed-precondition', 'ALREADY_APPLIED');

    tx.set(
      counterRef,
      { missionClaimed: admin.firestore.FieldValue.arrayUnion(missionId), expireAt: nextGameDayResetMs(now) },
      { merge: true },
    );
    applyRewards(tx, uid, mission.rewards);

    return { result: { rewards: mission.rewards, patch: { currency: currencyPatchFrom(mission.rewards) } } };
  });
}

export const claimMission = onCall(claimMissionHandler);
