// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dungeon_def.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DropEntryDef _$DropEntryDefFromJson(Map<String, dynamic> json) =>
    _DropEntryDef(
      item: json['item'] as String,
      min: (json['min'] as num).toInt(),
      max: (json['max'] as num).toInt(),
      chancePct: (json['chancePct'] as num?)?.toInt() ?? 100000,
      bonusDayOnly: json['bonusDayOnly'] as bool? ?? false,
    );

Map<String, dynamic> _$DropEntryDefToJson(_DropEntryDef instance) =>
    <String, dynamic>{
      'item': instance.item,
      'min': instance.min,
      'max': instance.max,
      'chancePct': instance.chancePct,
      'bonusDayOnly': instance.bonusDayOnly,
    };

_DungeonGimmickDef _$DungeonGimmickDefFromJson(Map<String, dynamic> json) =>
    _DungeonGimmickDef(
      kind: json['kind'] as String,
      biasPerSample: (json['biasPerSample'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DungeonGimmickDefToJson(_DungeonGimmickDef instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'biasPerSample': instance.biasPerSample,
    };

_DungeonUnlockDef _$DungeonUnlockDefFromJson(Map<String, dynamic> json) =>
    _DungeonUnlockDef(
      stageCleared: json['stageCleared'] as String?,
      difficultyCleared: (json['difficultyCleared'] as num?)?.toInt(),
      chapterCleared: json['chapterCleared'] as String?,
    );

Map<String, dynamic> _$DungeonUnlockDefToJson(_DungeonUnlockDef instance) =>
    <String, dynamic>{
      'stageCleared': instance.stageCleared,
      'difficultyCleared': instance.difficultyCleared,
      'chapterCleared': instance.chapterCleared,
    };

_DungeonDifficultyDef _$DungeonDifficultyDefFromJson(
  Map<String, dynamic> json,
) => _DungeonDifficultyDef(
  level: (json['level'] as num).toInt(),
  stageId: json['stageId'] as String,
  unlock: json['unlock'] == null
      ? null
      : DungeonUnlockDef.fromJson(json['unlock'] as Map<String, dynamic>),
  recommendedBondLevel: (json['recommendedBondLevel'] as num?)?.toInt() ?? 0,
  gimmick: json['gimmick'] == null
      ? null
      : DungeonGimmickDef.fromJson(json['gimmick'] as Map<String, dynamic>),
  hasMiniBoss: json['hasMiniBoss'] as bool? ?? false,
  drops:
      (json['drops'] as List<dynamic>?)
          ?.map((e) => DropEntryDef.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <DropEntryDef>[],
);

Map<String, dynamic> _$DungeonDifficultyDefToJson(
  _DungeonDifficultyDef instance,
) => <String, dynamic>{
  'level': instance.level,
  'stageId': instance.stageId,
  'unlock': instance.unlock,
  'recommendedBondLevel': instance.recommendedBondLevel,
  'gimmick': instance.gimmick,
  'hasMiniBoss': instance.hasMiniBoss,
  'drops': instance.drops,
};

_DungeonDef _$DungeonDefFromJson(Map<String, dynamic> json) => _DungeonDef(
  id: json['id'] as String,
  nameKey: json['nameKey'] as String,
  themeKey: json['themeKey'] as String,
  bonusWeekdays:
      (json['bonusWeekdays'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const <int>[],
  shardFamily: json['shardFamily'] as String,
  difficulties:
      (json['difficulties'] as List<dynamic>?)
          ?.map((e) => DungeonDifficultyDef.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <DungeonDifficultyDef>[],
);

Map<String, dynamic> _$DungeonDefToJson(_DungeonDef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameKey': instance.nameKey,
      'themeKey': instance.themeKey,
      'bonusWeekdays': instance.bonusWeekdays,
      'shardFamily': instance.shardFamily,
      'difficulties': instance.difficulties,
    };

_DungeonConfig _$DungeonConfigFromJson(Map<String, dynamic> json) =>
    _DungeonConfig(
      dailyRunLimit: (json['dailyRunLimit'] as num).toInt(),
      sweepConsumesRun: json['sweepConsumesRun'] as bool? ?? true,
      sweepRequiresClear: json['sweepRequiresClear'] as bool? ?? true,
      dungeons:
          (json['dungeons'] as List<dynamic>?)
              ?.map((e) => DungeonDef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <DungeonDef>[],
    );

Map<String, dynamic> _$DungeonConfigToJson(_DungeonConfig instance) =>
    <String, dynamic>{
      'dailyRunLimit': instance.dailyRunLimit,
      'sweepConsumesRun': instance.sweepConsumesRun,
      'sweepRequiresClear': instance.sweepRequiresClear,
      'dungeons': instance.dungeons,
    };
