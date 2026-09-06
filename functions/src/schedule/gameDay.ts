/**
 * lib/domain/dungeon/dungeon_bonus.dart의 gameDayWeekdayOf/isBonusDay 서버
 * 사본 — 클라와 서버가 "오늘"의 경계(요일 보너스, 일일 카운터 문서 ID)를
 * 똑같이 계산해야 한다. `serverState/schedule.dailyResetHourUtc`를 아직
 * 시드하지 않았으므로(운영 설정, T-40류 동기화 대상) 문서 예시 값(20,
 * KST 05:00)을 상수로 둔다.
 */
export const DAILY_RESET_HOUR_UTC = 20;

export function gameDayShifted(now: Date): Date {
  return new Date(now.getTime() - DAILY_RESET_HOUR_UTC * 3600 * 1000);
}

/** 다음 "게임 하루" 리셋 시각(ms) — dailyCounters 문서의 TTL(`expireAt`)용. */
export function nextGameDayResetMs(now: Date): number {
  const shifted = gameDayShifted(now);
  const nextShiftedMidnightUtc = Date.UTC(
    shifted.getUTCFullYear(),
    shifted.getUTCMonth(),
    shifted.getUTCDate() + 1,
    0,
    0,
    0,
  );
  return nextShiftedMidnightUtc + DAILY_RESET_HOUR_UTC * 3600 * 1000;
}

/** ISO 요일: 1=월 ... 7=일. */
export function gameDayWeekday(now: Date): number {
  const d = gameDayShifted(now);
  const jsDay = d.getUTCDay(); // 0=일 ... 6=토
  return jsDay === 0 ? 7 : jsDay;
}

/** `dailyCounters/{yyyy-MM-dd}` 문서 ID. */
export function gameDateKey(now: Date): string {
  const d = gameDayShifted(now);
  const y = d.getUTCFullYear();
  const m = String(d.getUTCMonth() + 1).padStart(2, '0');
  const day = String(d.getUTCDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

/** "일요일은 3종 모두 보너스 적용"이 공통 규칙이라 던전별 목록에는 넣지
 * 않는다 — dungeon_bonus.dart의 isBonusDay와 동일. */
export function isBonusDay(weekday: number, bonusWeekdays: number[]): boolean {
  return weekday === 7 || bonusWeekdays.includes(weekday);
}
