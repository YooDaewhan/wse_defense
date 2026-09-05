// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GoldCostFormula _$GoldCostFormulaFromJson(Map<String, dynamic> json) =>
    _GoldCostFormula(
      base: (json['base'] as num).toInt(),
      growth: (json['growth'] as num).toDouble(),
    );

Map<String, dynamic> _$GoldCostFormulaToJson(_GoldCostFormula instance) =>
    <String, dynamic>{'base': instance.base, 'growth': instance.growth};

_FocusKeyframe _$FocusKeyframeFromJson(Map<String, dynamic> json) =>
    _FocusKeyframe(
      level: (json['level'] as num).toInt(),
      regenPerSec: (json['regenPerSec'] as num).toInt(),
      cap: (json['cap'] as num).toInt(),
      startAmount: (json['startAmount'] as num).toInt(),
    );

Map<String, dynamic> _$FocusKeyframeToJson(_FocusKeyframe instance) =>
    <String, dynamic>{
      'level': instance.level,
      'regenPerSec': instance.regenPerSec,
      'cap': instance.cap,
      'startAmount': instance.startAmount,
    };

_CampKeyframe _$CampKeyframeFromJson(Map<String, dynamic> json) =>
    _CampKeyframe(
      level: (json['level'] as num).toInt(),
      hp: (json['hp'] as num).toInt(),
    );

Map<String, dynamic> _$CampKeyframeToJson(_CampKeyframe instance) =>
    <String, dynamic>{'level': instance.level, 'hp': instance.hp};

_FocusBoostStage _$FocusBoostStageFromJson(Map<String, dynamic> json) =>
    _FocusBoostStage(
      stage: (json['stage'] as num).toInt(),
      regenBonus: (json['regenBonus'] as num).toInt(),
      capBonus: (json['capBonus'] as num).toInt(),
      cost: (json['cost'] as num).toInt(),
    );

Map<String, dynamic> _$FocusBoostStageToJson(_FocusBoostStage instance) =>
    <String, dynamic>{
      'stage': instance.stage,
      'regenBonus': instance.regenBonus,
      'capBonus': instance.capBonus,
      'cost': instance.cost,
    };
