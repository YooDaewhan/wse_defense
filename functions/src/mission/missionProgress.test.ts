import { db } from '../common/admin';
import { gameDateKey } from '../schedule/gameDay';
import { bumpMissionProgress } from './missionProgress';

async function todayCounter(uid: string) {
  const doc = await db.doc(`users/${uid}/dailyCounters/${gameDateKey(new Date())}`).get();
  return doc.data();
}

/** 09_MILESTONES.md T-54 완료조건: "대체 조건 제공" -- missionData.ts의
 * MSN_BATTLE은 트리거 'BATTLE_WIN' 하나, MSN_GROWTH는 'LEVEL_UP'/
 * 'ENHANCE_EQUIPMENT' 둘 다 같은 진행도를 올린다. */
test('bumps progress for every mission whose triggerKinds includes the fired trigger', async () => {
  const uid = 'missionprogress-user-1';

  await bumpMissionProgress(uid, 'LEVEL_UP');

  const counter = await todayCounter(uid);
  expect(counter?.missionProgress.MSN_GROWTH).toBe(1);
  expect(counter?.missionProgress.MSN_LOGIN).toBeUndefined();
});

test('either alternative trigger alone satisfies the same mission\'s progress', async () => {
  const uid = 'missionprogress-user-2';

  await bumpMissionProgress(uid, 'ENHANCE_EQUIPMENT'); // LEVEL_UP을 한 번도 안 불렀지만

  const counter = await todayCounter(uid);
  expect(counter?.missionProgress.MSN_GROWTH).toBe(1); // 그래도 같은 미션 진행도가 오른다
});

test('does not exceed the mission\'s requiredCount', async () => {
  const uid = 'missionprogress-user-3';

  await bumpMissionProgress(uid, 'BATTLE_WIN');
  await bumpMissionProgress(uid, 'BATTLE_WIN');
  await bumpMissionProgress(uid, 'BATTLE_WIN');

  const counter = await todayCounter(uid);
  expect(counter?.missionProgress.MSN_BATTLE).toBe(1); // requiredCount=1이라 더 안 올라감
});

test('an unrecognized trigger kind is a no-op', async () => {
  const uid = 'missionprogress-user-4';

  await bumpMissionProgress(uid, 'SOMETHING_UNRELATED');

  const counter = await todayCounter(uid);
  expect(counter).toBeUndefined();
});
