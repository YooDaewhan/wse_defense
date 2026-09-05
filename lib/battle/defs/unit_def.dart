import 'package:freezed_annotation/freezed_annotation.dart';

part 'unit_def.freezed.dart';
part 'unit_def.g.dart';

/// 04_DATA_SCHEMA.md §5 `characters.json` / §7 `enemies.json`의 `base` 객체.
/// 전투 코어가 필요로 하는 수치만 담는다. rarity/art/story 등 프레젠테이션
/// 메타데이터는 domain/data 레이어의 몫이라 여기 들어오지 않는다.
@freezed
abstract class UnitBaseStats with _$UnitBaseStats {
  const factory UnitBaseStats({
    @Default(0) int summonCost,
    required int maxHp,
    required int atk,
    required int attackPeriod,
    required int attackWindup,
    required int attackRecover,
    required int attackRange,
    required int moveSpeed,
    @Default(1) int hpSegments,
    @Default(0) int resummonCooldownSec,
    @Default(24) int collisionRadius,
    @Default(0) int knockbackDistance,
    @Default(0) int knockbackResist,
    @Default(0) int def,
    @Default('SINGLE') String attackMode, // SINGLE | AOE | PIERCE
    @Default(1) int aoeMaxTargets,
    @Default('PHYSICAL') String damageType, // PHYSICAL | MAGICAL
    @Default('MELEE') String attackReach, // MELEE | RANGED
  }) = _UnitBaseStats;

  factory UnitBaseStats.fromJson(Map<String, Object?> json) =>
      _$UnitBaseStatsFromJson(json);
}

/// 캐릭터(characters.json)와 적(enemies.json)이 공유하는 전투 정의.
/// `isBoss`/`killPrayerReward`/`damageCapPerHit`는 적 전용, 캐릭터는 기본값을 쓴다.
@freezed
abstract class UnitDef with _$UnitDef {
  const factory UnitDef({
    required String id,
    @Default('') String nameKey,
    @Default(<String, int>{}) Map<String, int> intrinsicTags,
    required UnitBaseStats base,
    @Default(<String>[]) List<String> skills,
    @Default(false) bool isBoss,
    @Default(0) int killPrayerReward,
    int? damageCapPerHit,
  }) = _UnitDef;

  factory UnitDef.fromJson(Map<String, Object?> json) =>
      _$UnitDefFromJson(json);
}
