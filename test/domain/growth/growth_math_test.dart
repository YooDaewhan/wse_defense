import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/domain/growth/growth_config.dart';
import 'package:wse_defense/domain/growth/growth_math.dart';

// 04_DATA_SCHEMA.md §9 growth.json 예시 수치 그대로.
const _focusKeyframes = [
  FocusKeyframe(level: 1, regenPerSec: 18, cap: 1000, startAmount: 200),
  FocusKeyframe(level: 10, regenPerSec: 31, cap: 1600, startAmount: 250),
  FocusKeyframe(level: 20, regenPerSec: 45, cap: 2200, startAmount: 300),
];

const _campKeyframes = [
  CampKeyframe(level: 1, hp: 10000),
  CampKeyframe(level: 10, hp: 28000),
  CampKeyframe(level: 20, hp: 50000),
];

void main() {
  group('lerpInt', () {
    test('matches the endpoints exactly', () {
      expect(lerpInt(1, 18, 10, 31, 1), 18);
      expect(lerpInt(1, 18, 10, 31, 10), 31);
    });

    test('clamps outside the range', () {
      expect(lerpInt(1, 18, 10, 31, 0), 18);
      expect(lerpInt(1, 18, 10, 31, 99), 31);
    });

    test('integer-truncates mid-range like the doc formula', () {
      expect(lerpInt(1, 18, 10, 31, 5), 18 + (31 - 18) * (5 - 1) ~/ (10 - 1));
    });
  });

  group('focusStatsAtLevel', () {
    test('level exactly on a keyframe returns that keyframe verbatim', () {
      final s1 = focusStatsAtLevel(_focusKeyframes, 1);
      expect((s1.regenPerSec, s1.cap, s1.startAmount), (18, 1000, 200));

      final s20 = focusStatsAtLevel(_focusKeyframes, 20);
      expect((s20.regenPerSec, s20.cap, s20.startAmount), (45, 2200, 300));
    });

    test('interpolates within the first segment (1..10)', () {
      final s = focusStatsAtLevel(_focusKeyframes, 5);
      expect(s.regenPerSec, lerpInt(1, 18, 10, 31, 5));
      expect(s.cap, lerpInt(1, 1000, 10, 1600, 5));
      expect(s.startAmount, lerpInt(1, 200, 10, 250, 5));
    });

    test('interpolates within the second segment (10..20)', () {
      final s = focusStatsAtLevel(_focusKeyframes, 15);
      expect(s.regenPerSec, lerpInt(10, 31, 20, 45, 15));
      expect(s.cap, lerpInt(10, 1600, 20, 2200, 15));
      expect(s.startAmount, lerpInt(10, 250, 20, 300, 15));
    });

    test('clamps beyond the last keyframe', () {
      final s = focusStatsAtLevel(_focusKeyframes, 999);
      expect((s.regenPerSec, s.cap, s.startAmount), (45, 2200, 300));
    });
  });

  group('campHpAtLevel', () {
    test('matches keyframes exactly and interpolates between them', () {
      expect(campHpAtLevel(_campKeyframes, 1), 10000);
      expect(campHpAtLevel(_campKeyframes, 20), 50000);
      expect(campHpAtLevel(_campKeyframes, 5), lerpInt(1, 10000, 10, 28000, 5));
      expect(campHpAtLevel(_campKeyframes, 15), lerpInt(10, 28000, 20, 50000, 15));
    });
  });

  group('GoldCostFormula', () {
    test('the very first level-up costs exactly base', () {
      const formula = GoldCostFormula(base: 500, growth: 1.18);
      expect(formula.costForLevelUp(1), 500);
    });

    test('cost strictly increases with level', () {
      const formula = GoldCostFormula(base: 500, growth: 1.18);
      var prev = 0;
      for (var level = 1; level < 20; level++) {
        final cost = formula.costForLevelUp(level);
        expect(cost, greaterThan(prev));
        prev = cost;
      }
    });
  });
}
