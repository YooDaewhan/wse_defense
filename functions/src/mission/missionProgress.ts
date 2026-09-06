import { db } from '../common/admin';
import { gameDateKey, nextGameDayResetMs } from '../schedule/gameDay';
import { MISSIONS } from './missionData';

/**
 * 대체 조건(triggerKinds) 중 하나가 발생했을 때 그 조건을 가진 모든
 * 미션의 오늘 진행도를 1 올린다(요구치 이상은 더 안 올림 -- 클레임 전에
 * 계속 반복해도 진행도가 무의미하게 쌓이지 않는다).
 *
 * ponytail: 트리거를 발생시킨 행동(전투 제출·레벨업·강화·로그인)의
 * 트랜잭션과는 별개의 트랜잭션이다 -- 그 행동이 커밋된 직후에 호출되므로
 * 극히 드문 크래시 타이밍에 미션 진행도 반영이 누락될 수 있다. 미션은
 * 재화·소유권 같은 경제 크리티컬 데이터가 아니라 참여 유도용 부가
 * 기능이라 완전한 원자성 대신 단순함(호출부 트랜잭션에 손대지 않음)을
 * 택했다. 문제가 되면 그때 호출부 트랜잭션에 합친다.
 */
export async function bumpMissionProgress(uid: string, triggerKind: string): Promise<void> {
  const relevant = MISSIONS.filter((m) => m.triggerKinds.includes(triggerKind));
  if (relevant.length === 0) return;

  const now = new Date();
  const counterRef = db.doc(`users/${uid}/dailyCounters/${gameDateKey(now)}`);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(counterRef);
    const progress = { ...(snap.data()?.missionProgress ?? {}) } as Record<string, number>;
    let changed = false;
    for (const mission of relevant) {
      const current = progress[mission.id] ?? 0;
      if (current >= mission.requiredCount) continue;
      progress[mission.id] = current + 1;
      changed = true;
    }
    if (!changed) return;
    tx.set(counterRef, { missionProgress: progress, expireAt: nextGameDayResetMs(now) }, { merge: true });
  });
}
