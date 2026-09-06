/// 07_DUNGEON_EXCHANGE.md §2/§3.2, 구현 체크리스트: "요일 계산은 서버 시각
/// 기준 — 클라이언트 로컬 시각으로 요일 보너스를 판단하지 않는다."
/// [gameDayWeekday]는 반드시 서버가 알려준 시각(및 `dailyResetHourUtc`로
/// 보정한 "게임 하루" 경계)에서 구한 ISO 요일(1=월..7=일)이어야 하고,
/// 이 함수 자체는 그 값을 어디서 구했는지 모르는 순수 함수다.
///
/// "일요일은 3종 모두 보너스 적용"이 일반 규칙이라 던전별 `bonusWeekdays`
/// 목록에는 일요일을 넣지 않는다(모든 던전에 중복되므로) — 여기서 한 번만
/// 처리한다.
/// functions/src/schedule/gameDay.ts의 `DAILY_RESET_HOUR_UTC` 사본 --
/// 운영 설정(`serverState/schedule.dailyResetHourUtc`)을 아직 시드하지
/// 않아 서버도 이 상수를 그대로 쓴다. 서버가 그 문서를 실제로 읽기
/// 시작하면 이 값도 같이 서버에서 받아오도록 바꿔야 한다.
const dailyResetHourUtc = 20;

bool isBonusDay(int gameDayWeekday, List<int> bonusWeekdays) {
  return gameDayWeekday == 7 || bonusWeekdays.contains(gameDayWeekday);
}

/// `serverState/schedule.dailyResetHourUtc`(예: 20 = KST 05:00)를 반영해
/// "게임 하루" 경계 기준 ISO 요일을 구한다. 자정이 아니라 그 시각에 하루가
/// 넘어가므로, 리셋 시각 이전엔 전날 취급이 되도록 그만큼 시각을 당긴다.
int gameDayWeekdayOf(DateTime utcNow, int dailyResetHourUtc) {
  final shifted = utcNow.subtract(Duration(hours: dailyResetHourUtc));
  return shifted.weekday;
}
