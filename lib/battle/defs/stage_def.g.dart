// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stage_def.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BossTriggerDef _$BossTriggerDefFromJson(Map<String, dynamic> json) =>
    _BossTriggerDef(
      id: json['id'] as String,
      enemyId: json['enemyId'] as String,
      conditionKind: json['conditionKind'] as String,
      warningTicks: (json['warningTicks'] as num?)?.toInt() ?? 0,
      spawnX: (json['spawnX'] as num).toInt(),
    );

Map<String, dynamic> _$BossTriggerDefToJson(_BossTriggerDef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'enemyId': instance.enemyId,
      'conditionKind': instance.conditionKind,
      'warningTicks': instance.warningTicks,
      'spawnX': instance.spawnX,
    };

_StageDef _$StageDefFromJson(Map<String, dynamic> json) => _StageDef(
  id: json['id'] as String,
  index: (json['index'] as num).toInt(),
  nameKey: json['nameKey'] as String? ?? '',
  fieldLength: (json['fieldLength'] as num).toInt(),
  allyBaseX: (json['allyBaseX'] as num).toInt(),
  enemyBaseX: (json['enemyBaseX'] as num).toInt(),
  enemyBaseHp: (json['enemyBaseHp'] as num).toInt(),
  timeLimitSec: (json['timeLimitSec'] as num).toInt(),
  minClearSec: (json['minClearSec'] as num?)?.toInt() ?? 0,
  targetClearSec:
      (json['targetClearSec'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const <int>[0, 0],
  waves:
      (json['waves'] as List<dynamic>?)
          ?.map((e) => WaveDef.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <WaveDef>[],
  bossTriggers:
      (json['bossTriggers'] as List<dynamic>?)
          ?.map((e) => BossTriggerDef.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <BossTriggerDef>[],
);

Map<String, dynamic> _$StageDefToJson(_StageDef instance) => <String, dynamic>{
  'id': instance.id,
  'index': instance.index,
  'nameKey': instance.nameKey,
  'fieldLength': instance.fieldLength,
  'allyBaseX': instance.allyBaseX,
  'enemyBaseX': instance.enemyBaseX,
  'enemyBaseHp': instance.enemyBaseHp,
  'timeLimitSec': instance.timeLimitSec,
  'minClearSec': instance.minClearSec,
  'targetClearSec': instance.targetClearSec,
  'waves': instance.waves,
  'bossTriggers': instance.bossTriggers,
};
