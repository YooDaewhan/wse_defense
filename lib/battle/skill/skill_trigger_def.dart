import '../effect/effect_params.dart';
import '../tag/tag_query.dart';

/// 03_BATTLE_ENGINE.md §11. `ON_WEATHER_STATE`(M2)는 이 티켓 스코프 밖.
enum TriggerKind {
  passive,
  onNthAttack,
  onChance,
  onHpThreshold,
  onSpawn,
  onDeath,
  onWeatherState,
  onTagLevel,
}

enum ChanceUnit { perAttack, perTarget }

class SkillActionDef {
  const SkillActionDef({required this.type, required this.params});

  /// EffectRegistry의 type과 동일한 문자열("STUN", "SLOW", ...).
  final String type;
  final EffectParams params;
}

/// 04_DATA_SCHEMA.md §6 skills.json을 이 티켓이 실제로 소비하는 만큼만
/// 옮긴 것 — nameKey/vfxKey/sfxKey 같은 프레젠테이션 필드는 스코프 밖.
class SkillTriggerDef {
  const SkillTriggerDef({
    required this.id,
    required this.triggerKind,
    this.n = 1, // ON_NTH_ATTACK
    this.chance = 0, // ON_CHANCE, 밀리퍼센트
    this.chanceUnit = ChanceUnit.perAttack,
    this.hpThresholdPct = 0, // ON_HP_THRESHOLD, 밀리퍼센트
    this.tagIndex = -1, // ON_TAG_LEVEL (UNIT 스코프 한정)
    this.minLevel = 1, // ON_TAG_LEVEL
    this.target, // null이면 SELF
    this.actions = const [],
  });

  final String id;
  final TriggerKind triggerKind;
  final int n;
  final int chance;
  final ChanceUnit chanceUnit;
  final int hpThresholdPct;
  final int tagIndex;
  final int minLevel;
  final TagQuery? target;
  final List<SkillActionDef> actions;
}
