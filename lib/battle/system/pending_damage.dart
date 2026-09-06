/// 03_BATTLE_ENGINE.md §6. `selfCost`(§10.1 기운내기/RALLY의 자기 HP
/// 소비)는 HP는 깎지만 자연 넉백도, 날씨 "활약"도 만들지 않는다 —
/// DamageSystem이 이 kind만 따로 취급한다.
enum DamageKind { direct, dot, reflect, selfCost }

class PendingDamage {
  const PendingDamage({
    required this.targetId,
    required this.sourceId,
    required this.amount,
    this.kind = DamageKind.direct,
    this.causesForcedKb = false,
    this.forcedKbDistance = 0,
  });

  final int targetId;
  final int sourceId;
  final int amount; // 최종 계산 완료된 값
  final DamageKind kind;

  /// 강제 넉백 트리거 여부/거리. 실제 판정·적용은 KnockbackSystem(T-11)의 몫.
  final bool causesForcedKb;
  final int forcedKbDistance;
}
