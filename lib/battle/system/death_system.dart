import '../entity/entity_state.dart';
import '../event/battle_event.dart';
import '../skill/skill_trigger_runner.dart';
import '../tag/tag_query.dart';
import '../world/battle_world.dart';
import 'battle_system.dart';

/// 03_BATTLE_ENGINE.md §6 4단계: HP 0 처리, 처치 기도력 지급.
///
/// `action == dead`를 이미 처리된 표시로 써서, 실수로 두 번 실행되거나
/// 여러 틱에 걸쳐 hp<=0 상태가 유지돼도 보상이 한 번만 나가게 한다.
/// `isFinal`은 항상 true로 넘긴다 — REVIVE(M3)가 아직 없어 모든 사망이
/// 곧 최종 사망이다.
class DeathSystem implements BattleSystem {
  @override
  void execute(BattleWorld w) {
    for (final e in w.entities.ordered) {
      if (e.action == EntityAction.dead) continue;
      if (e.hp > 0) continue;

      e.hp = 0;
      e.action = EntityAction.dead;
      w.events.add(DeathEvent(w.tick, e.id));

      if (e.side == Side.enemy) {
        w.prayerPower += e.def.killPrayerReward;
      }

      SkillTriggerRunner.onDeath(w, e, true);
    }
  }
}
