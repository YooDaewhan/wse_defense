import { gameDateKey, gameDayWeekday, isBonusDay } from './gameDay';

test('gameDayWeekday shifts by DAILY_RESET_HOUR_UTC before taking the weekday (mirrors dungeon_bonus.dart)', () => {
  const beforeReset = new Date(Date.UTC(2026, 0, 5, 5, 0)); // 2026-01-05 월요일 UTC 05:00, 리셋 전
  expect(gameDayWeekday(beforeReset)).toBe(7); // 전날(일요일) 취급

  const afterReset = new Date(Date.UTC(2026, 0, 5, 20, 0));
  expect(gameDayWeekday(afterReset)).toBe(1);
});

test('gameDateKey follows the same shifted day boundary', () => {
  const beforeReset = new Date(Date.UTC(2026, 0, 5, 5, 0));
  expect(gameDateKey(beforeReset)).toBe('2026-01-04');

  const afterReset = new Date(Date.UTC(2026, 0, 5, 20, 0));
  expect(gameDateKey(afterReset)).toBe('2026-01-05');
});

test('isBonusDay: Sunday is universal, other days need to be listed', () => {
  expect(isBonusDay(7, [1, 4])).toBe(true);
  expect(isBonusDay(1, [1, 4])).toBe(true);
  expect(isBonusDay(2, [1, 4])).toBe(false);
});
