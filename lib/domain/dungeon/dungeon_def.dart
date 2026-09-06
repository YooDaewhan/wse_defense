import 'package:freezed_annotation/freezed_annotation.dart';

part 'dungeon_def.freezed.dart';
part 'dungeon_def.g.dart';

/// 07_DUNGEON_EXCHANGE.md §3.1 `dungeons.json`의 드랍 항목.
/// `chancePct`는 100000 = 100% 스케일(십만분율) — 확정 드랍은 기본값 그대로 둔다.
@freezed
abstract class DropEntryDef with _$DropEntryDef {
  const factory DropEntryDef({
    required String item,
    required int min,
    required int max,
    @Default(100000) int chancePct,
    @Default(false) bool bonusDayOnly,
  }) = _DropEntryDef;

  factory DropEntryDef.fromJson(Map<String, Object?> json) => _$DropEntryDefFromJson(json);
}

/// 표시 전용 데이터 — 실제 기믹 동작(날씨 편향/편성 제한/필살기 봉인)은
/// 전투 엔진에 아직 없다(§3 "난이도 3부터 기믹 1개" 문서화만 됨).
@freezed
abstract class DungeonGimmickDef with _$DungeonGimmickDef {
  const factory DungeonGimmickDef({required String kind, @Default(0) int biasPerSample}) = _DungeonGimmickDef;

  factory DungeonGimmickDef.fromJson(Map<String, Object?> json) => _$DungeonGimmickDefFromJson(json);
}

/// 이 난이도 하나의 해금 조건 — 셋 다 있을 수도, 일부만 있을 수도 있다
/// (전부 AND). `difficultyCleared`는 **같은 던전의** 이전 난이도를 가리킨다.
@freezed
abstract class DungeonUnlockDef with _$DungeonUnlockDef {
  const factory DungeonUnlockDef({String? stageCleared, int? difficultyCleared, String? chapterCleared}) =
      _DungeonUnlockDef;

  factory DungeonUnlockDef.fromJson(Map<String, Object?> json) => _$DungeonUnlockDefFromJson(json);
}

@freezed
abstract class DungeonDifficultyDef with _$DungeonDifficultyDef {
  const factory DungeonDifficultyDef({
    required int level,
    required String stageId,
    DungeonUnlockDef? unlock,
    @Default(0) int recommendedBondLevel,
    DungeonGimmickDef? gimmick,
    @Default(false) bool hasMiniBoss,
    @Default(<DropEntryDef>[]) List<DropEntryDef> drops,
  }) = _DungeonDifficultyDef;

  factory DungeonDifficultyDef.fromJson(Map<String, Object?> json) => _$DungeonDifficultyDefFromJson(json);
}

@freezed
abstract class DungeonDef with _$DungeonDef {
  const factory DungeonDef({
    required String id,
    required String nameKey,
    required String themeKey,
    @Default(<int>[]) List<int> bonusWeekdays, // ISO: 1=월 ... 7=일
    required String shardFamily,
    @Default(<DungeonDifficultyDef>[]) List<DungeonDifficultyDef> difficulties,
  }) = _DungeonDef;

  factory DungeonDef.fromJson(Map<String, Object?> json) => _$DungeonDefFromJson(json);
}

@freezed
abstract class DungeonConfig with _$DungeonConfig {
  const factory DungeonConfig({
    required int dailyRunLimit,
    @Default(true) bool sweepConsumesRun,
    @Default(true) bool sweepRequiresClear,
    @Default(<DungeonDef>[]) List<DungeonDef> dungeons,
  }) = _DungeonConfig;

  factory DungeonConfig.fromJson(Map<String, Object?> json) => _$DungeonConfigFromJson(json);
}
