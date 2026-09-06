import '../tag/tag_effect_def.dart' show StatModDef;

/// 04_DATA_SCHEMA.md §6.1 action 타입별 파라미터를 한데 모은 것. 각
/// 핸들러는 자신에게 필요한 필드만 읽는다.
class EffectParams {
  const EffectParams({
    this.durationTicks = 0, // 0 = STAT_BUFF 한정 "조건부 상시"(자동 만료 안 함)
    this.movePct = 0, // SLOW
    this.attackPeriodMult = 100000, // SLOW (100000 = 배율 없음)
    this.distance = 0, // PUSH
    this.amount = 0, // HEAL
    this.pctOfMaxHp = 0, // HEAL
    this.intervalTicks = 1, // HEAL
    this.mods = const [], // STAT_BUFF, RALLY(자기 강화 모디파이어)
    this.exclusiveGroup, // HEAL(토닥임 중첩 방지)
    this.tagIndex = -1, // GRANT_TAG
    this.tagAmount = 0, // GRANT_TAG
    this.atkPct = 0, // ATK_DOWN (밀리퍼센트, 보통 음수)
    this.selfCostPct = 0, // RALLY (밀리퍼센트, 최대HP 기준 자기비용)
  });

  final int durationTicks;
  final int movePct;
  final int attackPeriodMult;
  final int distance;
  final int amount;
  final int pctOfMaxHp;
  final int intervalTicks;
  final List<StatModDef> mods;
  final String? exclusiveGroup;
  final int tagIndex;
  final int tagAmount;
  final int atkPct;
  final int selfCostPct;
}
