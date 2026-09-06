import { CallableRequest, HttpsError, onCall } from 'firebase-functions/v2/https';
import { admin, db } from '../common/admin';
import { requireAuth } from '../common/auth';
import { withIdempotency } from '../common/idempotency';
import { AccountPatch, BaseRequest } from '../common/types';
import { BOND_GOLD_COST, BOND_MAX_LEVEL, CAMP_GOLD_COST, costForLevelUp, FOCUS_GOLD_COST } from './growthConfig';

export type GrowthTarget = 'FOCUS' | 'CAMP' | 'BOND';

export interface LevelUpReq extends BaseRequest {
  target: GrowthTarget;
}

export interface LevelUpRes {
  newLevel: number;
  goldSpent: number;
  patch: AccountPatch;
}

const GROWTH_DOC_FIELD: Record<GrowthTarget, string> = {
  FOCUS: 'growth.focusLevel',
  CAMP: 'growth.campDefenseLevel',
  BOND: 'growth.bondLevel',
};

const PATCH_GROWTH_KEY: Record<GrowthTarget, keyof NonNullable<AccountPatch['growth']>> = {
  FOCUS: 'focusLevel',
  CAMP: 'campDefenseLevel',
  BOND: 'bondLevel',
};

function currentLevelOf(target: GrowthTarget, growth: { focusLevel?: number; campDefenseLevel?: number; bondLevel?: number }): number {
  if (target === 'FOCUS') return growth.focusLevel ?? 1;
  if (target === 'CAMP') return growth.campDefenseLevel ?? 1;
  return growth.bondLevel ?? 1;
}

function costFormulaOf(target: GrowthTarget) {
  if (target === 'FOCUS') return FOCUS_GOLD_COST;
  if (target === 'CAMP') return CAMP_GOLD_COST;
  return BOND_GOLD_COST;
}

/** 04_DATA_SCHEMA.md §9 / T-39: 캐릭터의 소녀 집중력·캠프 방어·동행
 * 레벨업. "재화 차감과 상태 변경이 한 트랜잭션" — withIdempotency의
 * db.runTransaction 안에서 gold 차감과 레벨 증가를 같이 커밋한다. */
export async function levelUpHandler(request: CallableRequest<LevelUpReq>): Promise<LevelUpRes> {
  const uid = requireAuth(request);
  const { target } = request.data;

  return withIdempotency<LevelUpRes>(uid, request.data.idempotencyKey, 'levelUp', async (tx) => {
    const userRef = db.doc(`users/${uid}`);
    const userSnap = await tx.get(userRef);
    const growth = userSnap.data()?.growth ?? {};
    const gold = (userSnap.data()?.currency?.gold as number) ?? 0;

    const currentLevel = currentLevelOf(target, growth);
    if (target === 'BOND' && currentLevel >= BOND_MAX_LEVEL) {
      throw new HttpsError('failed-precondition', 'VALIDATION_FAILED');
    }
    const cost = costForLevelUp(costFormulaOf(target), currentLevel);
    if (gold < cost) throw new HttpsError('failed-precondition', 'NOT_ENOUGH_CURRENCY');

    const newLevel = currentLevel + 1;
    tx.update(userRef, {
      [GROWTH_DOC_FIELD[target]]: newLevel,
      'currency.gold': admin.firestore.FieldValue.increment(-cost),
    });

    return {
      result: {
        newLevel,
        goldSpent: cost,
        patch: { currency: { gold: gold - cost }, growth: { [PATCH_GROWTH_KEY[target]]: newLevel } },
      },
    };
  });
}

export const levelUp = onCall(levelUpHandler);
