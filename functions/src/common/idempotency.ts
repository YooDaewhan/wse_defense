import { Transaction } from 'firebase-admin/firestore';
import { admin, db } from './admin';
import { Delta } from './types';

export interface IdempotentWork<T> {
  result: T;
  deltas?: Delta[];
}

/**
 * 06_BACKEND.md §4.2 멱등성 구현. 멱등키를 트랜잭션 문서 ID로 써서
 * 동시 호출이 겹쳐도(Firestore 트랜잭션 재시도) 정확히 한 번만 `work`가
 * 적용되고, 나머지 호출은 먼저 커밋된 결과를 그대로 돌려받는다.
 */
export async function withIdempotency<T>(
  uid: string,
  key: string,
  kind: string,
  work: (tx: Transaction) => Promise<IdempotentWork<T>>,
): Promise<T> {
  const txRef = db.doc(`users/${uid}/transactions/${key}`);
  return db.runTransaction(async (tx) => {
    const existing = await tx.get(txRef);
    if (existing.exists) {
      return existing.data()!.result as T;
    }
    const { result, deltas } = await work(tx);
    tx.set(txRef, {
      idempotencyKey: key,
      kind,
      deltas: deltas ?? [],
      result,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return result;
  });
}
