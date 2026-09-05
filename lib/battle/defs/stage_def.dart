import 'package:freezed_annotation/freezed_annotation.dart';

import 'wave_def.dart';

part 'stage_def.freezed.dart';
part 'stage_def.g.dart';

/// 04_DATA_SCHEMA.md §8.1 `bossTriggers[]` 항목.
@freezed
abstract class BossTriggerDef with _$BossTriggerDef {
  const factory BossTriggerDef({
    required String id,
    required String enemyId,
    required String conditionKind, // TIME | NEST_FIRST_HIT | ... (§8.1)
    @Default(0) int warningTicks,
    required int spawnX,
  }) = _BossTriggerDef;

  factory BossTriggerDef.fromJson(Map<String, Object?> json) =>
      _$BossTriggerDefFromJson(json);
}

/// 04_DATA_SCHEMA.md §8 `stages/chapter_N.json`의 스테이지 1개.
/// 전투 시뮬레이션(스폰/보스/시간 제한)에 필요한 필드만 담는다. 배경/BGM/
/// 보상/스토리 등 화면·메타 필드는 이후 티켓(UI, 결과 화면)에서 별도로 다룬다.
@freezed
abstract class StageDef with _$StageDef {
  const factory StageDef({
    required String id,
    required int index,
    @Default('') String nameKey,
    required int fieldLength,
    required int allyBaseX,
    required int enemyBaseX,
    required int enemyBaseHp,
    required int timeLimitSec,
    @Default(0) int minClearSec,
    @Default(<int>[0, 0]) List<int> targetClearSec,
    @Default(<WaveDef>[]) List<WaveDef> waves,
    @Default(<BossTriggerDef>[]) List<BossTriggerDef> bossTriggers,
  }) = _StageDef;

  factory StageDef.fromJson(Map<String, Object?> json) =>
      _$StageDefFromJson(json);
}
