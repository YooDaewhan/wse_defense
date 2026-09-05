import '../constants.dart';
import '../event/battle_event.dart';
import '../system/pending_damage.dart';
import '../tag/tag_query.dart';
import 'battle_world.dart';

/// 03_BATTLE_ENGINE.md §11.1 간절한 기도.
///
/// 보스 감쇠(`e.isBoss ? 거리/2 : 거리`)는 문서의 pseudocode가 직접
/// 계산해 넣지만, 여기서는 하지 않는다 — `forcedKbDistance`가 이미
/// DamageSystem -> triggerForcedKnockback을 거치면서 보스 감쇠를
/// 적용하므로, 여기서 한 번 더 하면 보스가 두 번(1/4로) 깎인다.
///
/// `ultimateSealed`(필살기 봉인 기믹, StageDef.restrictions)는 아직 그
/// 필드가 없어(T-04 스코프 밖) 검사하지 않는다 — 어떤 완료 조건도
/// 요구하지 않는다.
void castUltimate(BattleWorld w) {
  if (w.ultimateStock <= 0) return;
  w.ultimateStock--;
  w.events.add(UltimateCastEvent(w.tick));

  for (final e in w.entities.ordered) {
    if (e.side != Side.enemy || !e.isTargetable) continue; // 넉백 중 무적 제외
    w.pendingDamage.add(
      PendingDamage(
        targetId: e.id,
        sourceId: ultimateSourceId,
        amount: ultDamage,
        causesForcedKb: true,
        forcedKbDistance: ultKnockbackDistance,
      ),
    );
  }
  // 적 둥지(enemyBase)는 entityId가 없는 별도 객체라 위 순회에 애초에
  // 포함되지 않는다 -> 자연히 제외.
}
