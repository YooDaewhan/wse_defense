// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wave_def.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WaveDef _$WaveDefFromJson(Map<String, dynamic> json) => _WaveDef(
  enemyId: json['enemyId'] as String,
  startSec: (json['startSec'] as num).toInt(),
  intervalSec: (json['intervalSec'] as num).toInt(),
  count: (json['count'] as num?)?.toInt() ?? -1,
  stopSec: (json['stopSec'] as num).toInt(),
  spawnX: (json['spawnX'] as num).toInt(),
);

Map<String, dynamic> _$WaveDefToJson(_WaveDef instance) => <String, dynamic>{
  'enemyId': instance.enemyId,
  'startSec': instance.startSec,
  'intervalSec': instance.intervalSec,
  'count': instance.count,
  'stopSec': instance.stopSec,
  'spawnX': instance.spawnX,
};
