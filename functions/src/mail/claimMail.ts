import { CallableRequest, HttpsError, onCall } from 'firebase-functions/v2/https';
import { admin, db } from '../common/admin';
import { requireAuth } from '../common/auth';
import { withIdempotency } from '../common/idempotency';
import { applyRewards, currencyPatchFrom } from '../common/rewards';
import { AccountPatch, BaseRequest, Delta } from '../common/types';

export interface ClaimMailReq extends BaseRequest {
  mailId: string;
}

export interface ClaimMailRes {
  rewards: Delta[];
  patch: AccountPatch;
}

/** 06_BACKEND.md §2 `users/{uid}/mail/{mailId}`: { titleKey, bodyKey,
 * attachments, claimedAt|null, expireAt }. 우편 문서 자체는 운영 도구가
 * 만든다(§4.9 근처 표) -- 이 함수는 유저가 첨부(attachments)를 수령하는
 * 쪽만 담당한다. */
export async function claimMailHandler(request: CallableRequest<ClaimMailReq>): Promise<ClaimMailRes> {
  const uid = requireAuth(request);
  const { mailId } = request.data;

  return withIdempotency<ClaimMailRes>(uid, request.data.idempotencyKey, 'claimMail', async (tx) => {
    const mailRef = db.doc(`users/${uid}/mail/${mailId}`);
    const mailSnap = await tx.get(mailRef);
    if (!mailSnap.exists) throw new HttpsError('not-found', 'VALIDATION_FAILED');

    const mail = mailSnap.data()!;
    if (mail.claimedAt) throw new HttpsError('failed-precondition', 'ALREADY_APPLIED');
    if (typeof mail.expireAt === 'number' && Date.now() > mail.expireAt) {
      throw new HttpsError('failed-precondition', 'VALIDATION_FAILED');
    }

    const rewards = (mail.attachments ?? []) as Delta[];
    tx.update(mailRef, { claimedAt: admin.firestore.FieldValue.serverTimestamp() });
    applyRewards(tx, uid, rewards);

    return { result: { rewards, patch: { currency: currencyPatchFrom(rewards) } } };
  });
}

export const claimMail = onCall(claimMailHandler);
