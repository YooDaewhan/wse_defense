import '../constants.dart';
import '../entity/entity_state.dart';
import '../world/battle_world.dart';
import 'battle_system.dart';

/// 03_BATTLE_ENGINE.md §6.2: 넉백 중인 유닛을 이동시키고 종료를 처리한다.
///
/// 넉백 트리거(자연 임계 통과/강제 밀치기)는 DamageSystem이 맡는다 — 실행
/// 순서상 KnockbackSystem(§3 #9)이 DamageSystem(#13)보다 먼저 돌기 때문에,
/// "이번 틱에 새로 발생한" 넉백은 다음 틱부터 여기서 진행된다.
class KnockbackSystem implements BattleSystem {
  @override
  void execute(BattleWorld w) {
    for (final e in w.entities.ordered) {
      if (e.knockbackTicksLeft <= 0) continue;

      e.action = EntityAction.knockback;

      var nx = e.x + e.knockbackVelocity;
      final lo = w.minX(e.side);
      final hi = w.maxX(e.side);
      if (nx < lo) nx = lo;
      if (nx > hi) nx = hi;
      e.x = nx; // 경계에 닿아도 knockbackTicksLeft는 그대로 흐른다.

      e.knockbackTicksLeft--;
      if (e.knockbackTicksLeft == 0) {
        e.action = EntityAction.idle;
        e.actionTimer = 0;
        // attackCooldown은 유지 -> 복귀 후 전체 선딜 A를 다시 거침 (§4 상단).
        if (e.knockbackIsForced) {
          e.forcedKbImmuneUntilTick = w.tick + forcedKbImmuneTicks;
        }
      }
    }
  }
}
