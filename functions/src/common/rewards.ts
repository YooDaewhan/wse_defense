import { Transaction } from 'firebase-admin/firestore';
import { admin, db } from './admin';
import { Delta } from './types';

/** items.json의 `type: CURRENCY` 항목 -> users/{uid}.currency 필드 매핑.
 * 06_BACKEND.md §2 스키마의 `currency { gold, recruitTicket, collectFragment,
 * exchangePoint }`는 평범한 필드명이지만, 보상/드랍표는 전부 아이템 카탈로그
 * ID(`ITM_GOLD` 등)로 표현되므로 여기서 한 번만 변환한다. */
const CURRENCY_ITEM_FIELD: Record<string, string> = {
  ITM_GOLD: 'gold',
  ITM_RECRUIT_TICKET: 'recruitTicket',
  ITM_COLLECT_FRAGMENT: 'collectFragment',
  ITM_EXCHANGE_POINT: 'exchangePoint',
};

/** 통화류(ITM_GOLD 등)는 `users/{uid}.currency.*`로, 그 외(조각 등)는
 * `users/{uid}/items/{itemId}` 서브컬렉션으로 적립한다. write만 하므로
 * (read 없음) 트랜잭션의 read 구간이 끝난 뒤 어디서든 안전하게 호출된다. */
export function applyReward(tx: Transaction, uid: string, reward: Delta): void {
  const currencyField = CURRENCY_ITEM_FIELD[reward.item];
  if (currencyField) {
    tx.update(db.doc(`users/${uid}`), {
      [`currency.${currencyField}`]: admin.firestore.FieldValue.increment(reward.amount),
    });
  } else {
    tx.set(
      db.doc(`users/${uid}/items/${reward.item}`),
      { amount: admin.firestore.FieldValue.increment(reward.amount), updatedAt: admin.firestore.FieldValue.serverTimestamp() },
      { merge: true },
    );
  }
}

export function applyRewards(tx: Transaction, uid: string, rewards: Delta[]): void {
  for (const r of rewards) applyReward(tx, uid, r);
}

/** `AccountPatch.currency` 힌트 — 통화류 보상만 클라 로컬 미러 갱신용으로 뽑는다. */
export function currencyPatchFrom(rewards: Delta[]): Record<string, number> {
  const patch: Record<string, number> = {};
  for (const r of rewards) {
    const field = CURRENCY_ITEM_FIELD[r.item];
    if (field) patch[field] = (patch[field] ?? 0) + r.amount;
  }
  return patch;
}
