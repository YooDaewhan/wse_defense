/// 03_BATTLE_ENGINE.md §6.
enum DamageKind { direct, dot, reflect }

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
