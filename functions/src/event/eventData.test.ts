import { EVENTS, isEventOpen } from './eventData';

/** 09_MILESTONES.md T-55 완료조건: "10스테이지 + 교환소 + 기간 종료
 * 처리를 데이터만으로 구성". */
test('every event template has exactly 10 stages and an exchange shop', () => {
  for (const event of EVENTS) {
    expect(event.stageIds).toHaveLength(10);
    expect(event.shopId).toBeTruthy();
  }
});

test('an unbounded (null window) event is always open', () => {
  expect(isEventOpen({ id: 'X', startAtUtc: null, endAtUtc: null, stageIds: [], shopId: 'S' }, Date.now())).toBe(true);
});

test('closes once the end date has passed', () => {
  const event = { id: 'X', startAtUtc: '2020-01-01T00:00:00Z', endAtUtc: '2020-01-31T00:00:00Z', stageIds: [], shopId: 'S' };
  expect(isEventOpen(event, Date.parse('2020-02-01T00:00:00Z'))).toBe(false);
  expect(isEventOpen(event, Date.parse('2020-01-15T00:00:00Z'))).toBe(true);
});
