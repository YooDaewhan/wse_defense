import { db } from './admin';
import { withIdempotency } from './idempotency';

/** 09_MILESTONES.md T-37 완료조건: "같은 idempotencyKey로 10회 동시 호출 시
 * 1회만 적용, 결과 동일". `work` 자체는 트랜잭션 충돌로 여러 번 재시도될 수
 * 있으므로, JS 메모리 카운터가 아니라 Firestore 문서 값으로 "실제 적용
 *횟수"를 검증한다. */
test('same idempotencyKey called 10 times concurrently applies once with identical results', async () => {
  const uid = 'idem-user';
  const counterRef = db.doc(`users/${uid}/testCounters/c1`);
  await counterRef.set({ value: 0 });

  const key = 'idem-key-1';
  const calls = Array.from({ length: 10 }, () =>
    withIdempotency(uid, key, 'increment', async (tx) => {
      const snap = await tx.get(counterRef);
      const current = (snap.data()?.value as number) ?? 0;
      tx.update(counterRef, { value: current + 1 });
      return { result: { appliedValue: current + 1 } };
    }),
  );
  const results = await Promise.all(calls);

  const finalSnap = await counterRef.get();
  expect(finalSnap.data()!.value).toBe(1);
  for (const r of results) expect(r).toEqual(results[0]);
});

test('different idempotencyKeys both apply', async () => {
  const uid = 'idem-user-2';
  const counterRef = db.doc(`users/${uid}/testCounters/c1`);
  await counterRef.set({ value: 0 });

  const bump = (key: string) =>
    withIdempotency(uid, key, 'increment', async (tx) => {
      const snap = await tx.get(counterRef);
      const current = (snap.data()?.value as number) ?? 0;
      tx.update(counterRef, { value: current + 1 });
      return { result: current + 1 };
    });

  await bump('key-a');
  await bump('key-b');

  const finalSnap = await counterRef.get();
  expect(finalSnap.data()!.value).toBe(2);
});
