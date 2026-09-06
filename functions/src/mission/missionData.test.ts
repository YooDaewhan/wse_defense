import { MISSIONS } from './missionData';

/** 09_MILESTONES.md T-54 완료조건: "미션 3개, 대체 조건 제공, 구매를
 * 완료 조건으로 요구하지 않음". */
test('there are exactly 3 daily missions', () => {
  expect(MISSIONS).toHaveLength(3);
});

test('every mission accepts at least one trigger, and none of them require a purchase', () => {
  for (const mission of MISSIONS) {
    expect(mission.triggerKinds.length).toBeGreaterThan(0);
    expect(mission.triggerKinds.some((t) => t.toUpperCase().includes('PURCHASE'))).toBe(false);
  }
});

test('the growth mission provides an alternative condition (more than one trigger kind)', () => {
  const growth = MISSIONS.find((m) => m.id === 'MSN_GROWTH')!;
  expect(growth.triggerKinds.length).toBeGreaterThan(1);
});
