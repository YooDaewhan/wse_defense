import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/domain/dungeon/dungeon_bonus.dart';

/// 09_MILESTONES.md T-41 완료조건: "요일 보너스 표시(서버 시각 기준)".
void main() {
  test('a weekday listed in bonusWeekdays is a bonus day', () {
    expect(isBonusDay(1, [1, 4]), isTrue);
    expect(isBonusDay(4, [1, 4]), isTrue);
    expect(isBonusDay(2, [1, 4]), isFalse);
  });

  test('Sunday (7) is always a bonus day for every dungeon, even if not listed', () {
    expect(isBonusDay(7, [1, 4]), isTrue);
    expect(isBonusDay(7, [2, 5]), isTrue);
    expect(isBonusDay(7, []), isTrue);
  });

  test('gameDayWeekdayOf shifts by dailyResetHourUtc before taking the weekday', () {
    // 월요일 UTC 05:00, dailyResetHourUtc=20(KST 05:00)이면 아직 리셋 전
    // (하루가 안 넘어감) -> 전날인 일요일(7) 취급.
    final beforeReset = DateTime.utc(2026, 1, 5, 5, 0); // 2026-01-05는 월요일
    expect(gameDayWeekdayOf(beforeReset, 20), 7);

    // 리셋 시각(UTC 20:00) 이후엔 실제로 그날로 취급.
    final afterReset = DateTime.utc(2026, 1, 5, 20, 0);
    expect(gameDayWeekdayOf(afterReset, 20), 1);
  });
}
