// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_def.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UnitBaseStats _$UnitBaseStatsFromJson(Map<String, dynamic> json) =>
    _UnitBaseStats(
      summonCost: (json['summonCost'] as num?)?.toInt() ?? 0,
      maxHp: (json['maxHp'] as num).toInt(),
      atk: (json['atk'] as num).toInt(),
      attackPeriod: (json['attackPeriod'] as num).toInt(),
      attackWindup: (json['attackWindup'] as num).toInt(),
      attackRecover: (json['attackRecover'] as num).toInt(),
      attackRange: (json['attackRange'] as num).toInt(),
      moveSpeed: (json['moveSpeed'] as num).toInt(),
      hpSegments: (json['hpSegments'] as num?)?.toInt() ?? 1,
      resummonCooldownSec: (json['resummonCooldownSec'] as num?)?.toInt() ?? 0,
      collisionRadius: (json['collisionRadius'] as num?)?.toInt() ?? 24,
      knockbackDistance: (json['knockbackDistance'] as num?)?.toInt() ?? 0,
      knockbackResist: (json['knockbackResist'] as num?)?.toInt() ?? 0,
      def: (json['def'] as num?)?.toInt() ?? 0,
      attackMode: json['attackMode'] as String? ?? 'SINGLE',
      aoeMaxTargets: (json['aoeMaxTargets'] as num?)?.toInt() ?? 1,
      damageType: json['damageType'] as String? ?? 'PHYSICAL',
      attackReach: json['attackReach'] as String? ?? 'MELEE',
    );

Map<String, dynamic> _$UnitBaseStatsToJson(_UnitBaseStats instance) =>
    <String, dynamic>{
      'summonCost': instance.summonCost,
      'maxHp': instance.maxHp,
      'atk': instance.atk,
      'attackPeriod': instance.attackPeriod,
      'attackWindup': instance.attackWindup,
      'attackRecover': instance.attackRecover,
      'attackRange': instance.attackRange,
      'moveSpeed': instance.moveSpeed,
      'hpSegments': instance.hpSegments,
      'resummonCooldownSec': instance.resummonCooldownSec,
      'collisionRadius': instance.collisionRadius,
      'knockbackDistance': instance.knockbackDistance,
      'knockbackResist': instance.knockbackResist,
      'def': instance.def,
      'attackMode': instance.attackMode,
      'aoeMaxTargets': instance.aoeMaxTargets,
      'damageType': instance.damageType,
      'attackReach': instance.attackReach,
    };

_UnitDef _$UnitDefFromJson(Map<String, dynamic> json) => _UnitDef(
  id: json['id'] as String,
  nameKey: json['nameKey'] as String? ?? '',
  intrinsicTags:
      (json['intrinsicTags'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
  base: UnitBaseStats.fromJson(json['base'] as Map<String, dynamic>),
  skills:
      (json['skills'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  isBoss: json['isBoss'] as bool? ?? false,
  killPrayerReward: (json['killPrayerReward'] as num?)?.toInt() ?? 0,
  damageCapPerHit: (json['damageCapPerHit'] as num?)?.toInt(),
);

Map<String, dynamic> _$UnitDefToJson(_UnitDef instance) => <String, dynamic>{
  'id': instance.id,
  'nameKey': instance.nameKey,
  'intrinsicTags': instance.intrinsicTags,
  'base': instance.base,
  'skills': instance.skills,
  'isBoss': instance.isBoss,
  'killPrayerReward': instance.killPrayerReward,
  'damageCapPerHit': instance.damageCapPerHit,
};
