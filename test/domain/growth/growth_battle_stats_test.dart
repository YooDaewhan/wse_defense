import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/domain/growth/growth_battle_stats.dart';
import 'package:wse_defense/domain/growth/growth_config.dart';

const _growth = GrowthConfig(
  focusKeyframes: [
    FocusKeyframe(level: 1, regenPerSec: 18, cap: 1000, startAmount: 200),
    FocusKeyframe(level: 10, regenPerSec: 31, cap: 1600, startAmount: 250),
  ],
  focusGoldCost: GoldCostFormula(base: 500, growth: 1.18),
  campKeyframes: [CampKeyframe(level: 1, hp: 10000), CampKeyframe(level: 10, hp: 28000)],
  campGoldCost: GoldCostFormula(base: 400, growth: 1.20),
  focusBoost: [],
  bondMaxLevel: 3,
  bondGoldCost: GoldCostFormula(base: 200, growth: 1.12),
);

/// 10_WIRING_PLAN.md T-60.
void main() {
  test('uses the level-1 keyframe for a fresh account', () {
    expect(focusStatsForLevel(_growth, 1).regenPerSec, 18);
    expect(campStatsForLevel(_growth, 1).hp, 10000);
  });

  test('steps up to the highest keyframe at or below the current level', () {
    expect(focusStatsForLevel(_growth, 5).regenPerSec, 18); // 아직 Lv10 미만
    expect(focusStatsForLevel(_growth, 10).regenPerSec, 31);
    expect(focusStatsForLevel(_growth, 999).regenPerSec, 31); // 최고 keyframe 그대로 유지
  });

  test('falls back to the first keyframe below the lowest defined level', () {
    expect(focusStatsForLevel(_growth, 0).regenPerSec, 18);
  });
}
