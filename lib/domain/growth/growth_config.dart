import 'package:freezed_annotation/freezed_annotation.dart';

part 'growth_config.freezed.dart';
part 'growth_config.g.dart';

/// 04_DATA_SCHEMA.md §9 `growth.json`의 `goldCostFormula`. 레벨업 1회
/// (currentLevel -> currentLevel+1) 비용 = `base * growth^(currentLevel-1)`.
@freezed
abstract class GoldCostFormula with _$GoldCostFormula {
  const factory GoldCostFormula({required int base, required double growth}) = _GoldCostFormula;

  const GoldCostFormula._();

  factory GoldCostFormula.fromJson(Map<String, Object?> json) => _$GoldCostFormulaFromJson(json);

  int costForLevelUp(int currentLevel) {
    final cost = base * _pow(growth, currentLevel - 1);
    return cost.round();
  }
}

double _pow(double base, int exponent) {
  var result = 1.0;
  for (var i = 0; i < exponent; i++) {
    result *= base;
  }
  return result;
}

@freezed
abstract class FocusKeyframe with _$FocusKeyframe {
  const factory FocusKeyframe({
    required int level,
    required int regenPerSec,
    required int cap,
    required int startAmount,
  }) = _FocusKeyframe;

  factory FocusKeyframe.fromJson(Map<String, Object?> json) => _$FocusKeyframeFromJson(json);
}

@freezed
abstract class CampKeyframe with _$CampKeyframe {
  const factory CampKeyframe({required int level, required int hp}) = _CampKeyframe;

  factory CampKeyframe.fromJson(Map<String, Object?> json) => _$CampKeyframeFromJson(json);
}

@freezed
abstract class FocusBoostStage with _$FocusBoostStage {
  const factory FocusBoostStage({
    required int stage,
    required int regenBonus,
    required int capBonus,
    required int cost,
  }) = _FocusBoostStage;

  factory FocusBoostStage.fromJson(Map<String, Object?> json) => _$FocusBoostStageFromJson(json);
}

@freezed
abstract class GrowthConfig with _$GrowthConfig {
  const factory GrowthConfig({
    required List<FocusKeyframe> focusKeyframes,
    required GoldCostFormula focusGoldCost,
    required List<CampKeyframe> campKeyframes,
    required GoldCostFormula campGoldCost,
    required List<FocusBoostStage> focusBoost,
    required int bondMaxLevel,
    required GoldCostFormula bondGoldCost,
  }) = _GrowthConfig;

  factory GrowthConfig.fromJson(Map<String, Object?> json) {
    final focus = json['focus'] as Map<String, Object?>;
    final camp = json['camp'] as Map<String, Object?>;
    final bond = json['bond'] as Map<String, Object?>;
    return GrowthConfig(
      focusKeyframes: [
        for (final k in focus['keyframes'] as List<Object?>)
          FocusKeyframe.fromJson(k as Map<String, Object?>),
      ],
      focusGoldCost: GoldCostFormula.fromJson(focus['goldCostFormula'] as Map<String, Object?>),
      campKeyframes: [
        for (final k in camp['keyframes'] as List<Object?>) CampKeyframe.fromJson(k as Map<String, Object?>),
      ],
      campGoldCost: GoldCostFormula.fromJson(camp['goldCostFormula'] as Map<String, Object?>),
      focusBoost: [
        for (final s in json['focusBoost'] as List<Object?>)
          FocusBoostStage.fromJson(s as Map<String, Object?>),
      ],
      bondMaxLevel: bond['maxLevel'] as int,
      bondGoldCost: GoldCostFormula.fromJson(bond['goldCostFormula'] as Map<String, Object?>),
    );
  }
}
