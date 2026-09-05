/// 03_BATTLE_ENGINE.md §13. 이벤트는 **전투 로직에 영향을 주지 않는다**
/// (순수 알림) — 어떤 시스템도 `BattleWorld.events`를 읽지 않고 쓰기만
/// 한다. 렌더가 구독(drain)을 끊어도 시뮬 결과는 완전히 동일하다.
///
/// 지금 구현된 것만 담는다 — 아직 없는 기능(크리티컬, 태그 레벨 변화,
/// 관계 발동, 날씨, 보스 예고 등)의 이벤트는 그 기능이 생길 때 추가한다.
sealed class BattleEvent {
  const BattleEvent(this.tick);
  final int tick;
}

/// AttackSystem 판정 순간 — 몇 명을 맞혔든(AOE 포함) 1회.
class AttackFiredEvent extends BattleEvent {
  const AttackFiredEvent(super.tick, this.entityId, this.targetIds);
  final int entityId;
  final List<int> targetIds;
}

/// DamageSystem이 실제로 hp를 깎은 순간(방어막으로 전부 흡수됐으면 발생 안 함).
class DamageDealtEvent extends BattleEvent {
  const DamageDealtEvent(super.tick, this.targetId, this.amount);
  final int targetId;
  final int amount;
}

class DeathEvent extends BattleEvent {
  const DeathEvent(super.tick, this.entityId);
  final int entityId;
}

class UltimateCastEvent extends BattleEvent {
  const UltimateCastEvent(super.tick);
}
