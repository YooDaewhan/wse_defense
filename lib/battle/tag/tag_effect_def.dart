import '../stat/modifier.dart';
import '../stat/stat_key.dart';
import '../world/weather_state.dart';
import 'tag_query.dart';
import 'tag_registry.dart';

/// 02_TAG_SYSTEM.md §2.
enum TagScope { unit, formation, field }

/// §3.5.
enum TagEffectMode { perLevel, tier }

/// §3.5 tierMode.
enum TierMode { highest, cumulative }

TagScope _scopeFromJson(String raw) => switch (raw) {
  'UNIT' => TagScope.unit,
  'FORMATION' => TagScope.formation,
  'FIELD' => TagScope.field,
  _ => throw FormatException('알 수 없는 TagScope: $raw'),
};

TagEffectMode _modeFromJson(String raw) => switch (raw) {
  'PER_LEVEL' => TagEffectMode.perLevel,
  'TIER' => TagEffectMode.tier,
  _ => throw FormatException('알 수 없는 TagEffectMode: $raw'),
};

TierMode _tierModeFromJson(String raw) => switch (raw) {
  'HIGHEST' => TierMode.highest,
  'CUMULATIVE' => TierMode.cumulative,
  _ => throw FormatException('알 수 없는 TierMode: $raw'),
};

StatKey _statKeyFromJson(String raw) => switch (raw) {
  'MAX_HP' => StatKey.maxHp,
  'ATK' => StatKey.atk,
  'DEF' => StatKey.def,
  'ATTACK_PERIOD' => StatKey.attackPeriod,
  'ATTACK_WINDUP' => StatKey.attackWindup,
  'ATTACK_RANGE' => StatKey.attackRange,
  'MOVE_SPEED' => StatKey.moveSpeed,
  'HP_SEGMENTS' => StatKey.hpSegments,
  'KNOCKBACK_RESIST' => StatKey.knockbackResist,
  'KNOCKBACK_DISTANCE' => StatKey.knockbackDistance,
  'SUMMON_COST' => StatKey.summonCost,
  'RESUMMON_COOLDOWN' => StatKey.resummonCooldown,
  'HEAL_POWER' => StatKey.healPower,
  'HEAL_RECEIVED' => StatKey.healReceived,
  'DMG_DEALT_VS' => StatKey.dmgDealtVs,
  'DMG_TAKEN_FROM' => StatKey.dmgTakenFrom,
  'AOE_MAX_TARGETS' => StatKey.aoeMaxTargets,
  'PRAYER_GAIN_ON_KILL' => StatKey.prayerGainOnKill,
  _ => throw FormatException('알 수 없는 StatKey: $raw'),
};

WeatherState _weatherStateFromJson(String raw) => switch (raw) {
  'CLEAR' => WeatherState.clear,
  'DUSK' => WeatherState.dusk,
  'NIGHT' => WeatherState.night,
  _ => throw FormatException('알 수 없는 WeatherState: $raw'),
};

ModOp _modOpFromJson(String raw) => switch (raw) {
  'FLAT_ADD' => ModOp.flatAdd,
  'PCT_ADD' => ModOp.pctAdd,
  'MULT' => ModOp.mult,
  'SET_MIN' => ModOp.setMin,
  'SET_MAX' => ModOp.setMax,
  _ => throw FormatException('알 수 없는 ModOp: $raw'),
};

/// §3.6. 런타임 [StatModifier]와 달리 출처(source)가 없는 데이터 정의.
/// `vs`(조건부 대상, DMG_DEALT_VS/DMG_TAKEN_FROM 전용)는 상성 시스템이
/// 아직 없어(T-15 스코프 밖) 파싱하지 않는다.
class StatModDef {
  const StatModDef({
    required this.stat,
    required this.op,
    required this.value,
    this.exclusiveGroup,
  });

  final StatKey stat;
  final ModOp op;
  final int value;
  final String? exclusiveGroup;

  factory StatModDef.fromJson(Map<String, Object?> json) => StatModDef(
    stat: _statKeyFromJson(json['stat'] as String),
    op: _modOpFromJson(json['op'] as String),
    value: json['value'] as int,
    exclusiveGroup: json['exclusiveGroup'] as String?,
  );
}

class TagEffectTier {
  const TagEffectTier({required this.minLevel, required this.mods});

  final int minLevel;
  final List<StatModDef> mods;

  factory TagEffectTier.fromJson(Map<String, Object?> json) => TagEffectTier(
    minLevel: json['minLevel'] as int,
    mods: [
      for (final m in json['mods'] as List<Object?>)
        StatModDef.fromJson(m as Map<String, Object?>),
    ],
  );
}

/// §3.5.
class TagEffectDef {
  const TagEffectDef({
    required this.id,
    required this.tagIndex,
    required this.scope,
    required this.mode,
    this.tierMode,
    this.target, // null이면 SELF
    this.perLevel = const [],
    this.tiers = const [],
    this.levelCapForEffect = 1 << 30,
    this.requireWeather, // null이면 날씨 무관(항상 조건 통과)
  });

  final String id;
  final int tagIndex;
  final TagScope scope;
  final TagEffectMode mode;
  final TierMode? tierMode;
  final TagQuery? target;
  final List<StatModDef> perLevel;
  final List<TagEffectTier> tiers;
  final int levelCapForEffect;

  /// 04_DATA_SCHEMA.md §3 `requireWeather` (M2): 이 목록에 현재 날씨가
  /// 없으면 이 효과는 (레벨/타겟 조건과 무관하게) 통째로 비활성.
  final List<WeatherState>? requireWeather;

  /// [registry]로 `tag` 문자열을 인덱스로, `target`의 태그 참조들을 해석한다.
  factory TagEffectDef.fromJson(
    Map<String, Object?> json,
    TagRegistry registry,
  ) {
    final tierModeRaw = json['tierMode'] as String?;
    return TagEffectDef(
      id: json['id'] as String,
      tagIndex: registry.indexOf(json['tag'] as String),
      scope: _scopeFromJson(json['scope'] as String),
      mode: _modeFromJson(json['mode'] as String),
      tierMode: tierModeRaw == null ? null : _tierModeFromJson(tierModeRaw),
      target: _targetFromJson(json['target'], registry),
      perLevel: [
        for (final m in (json['perLevel'] as List<Object?>? ?? const []))
          StatModDef.fromJson(m as Map<String, Object?>),
      ],
      tiers: [
        for (final t in (json['tiers'] as List<Object?>? ?? const []))
          TagEffectTier.fromJson(t as Map<String, Object?>),
      ],
      levelCapForEffect: json['levelCapForEffect'] as int? ?? 1 << 30,
      requireWeather: (json['requireWeather'] as List<Object?>?)
          ?.map((w) => _weatherStateFromJson(w as String))
          .toList(),
    );
  }

  static TagQuery? _targetFromJson(Object? raw, TagRegistry registry) {
    if (raw == null || raw == 'SELF') return null;
    return TagQuery.fromJson(raw as Map<String, Object?>, registry);
  }
}
