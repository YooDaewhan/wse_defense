import '../entity/battle_entity.dart';
import '../entity/entity_state.dart';
import '../skill/skill_trigger_runner.dart';
import '../stat/stat_key.dart';
import '../world/battle_world.dart';
import 'battle_system.dart';
import 'damage_system.dart';
import 'pending_damage.dart';
import 'target_system.dart';

/// 03_BATTLE_ENGINE.md §4: 공격 상태머신.
/// cooldown 대기 -> [attackWindup](A틱) -> ★판정 -> [attackRecover](R틱) -> idle.
///
/// `w.events`는 아직 없어(이벤트 버스) 호출을 생략한다. 판정에서 맞은 대상
/// id는 [BattleEntity.lastHitTargetIds]에도 남겨 관측 가능하게 해둔다(테스트용).
class AttackSystem implements BattleSystem {
  @override
  void execute(BattleWorld w) {
    for (final e in w.entities.ordered) {
      if (!e.isAlive) continue;
      if (e.action == EntityAction.stunned) continue; // 타이머 정지

      if (e.isKnockedBack) {
        _cancelAttack(e);
        continue;
      }

      if (e.attackCooldown > 0) e.attackCooldown--;

      switch (e.action) {
        case EntityAction.attackWindup:
          e.actionTimer--;
          if (e.actionTimer <= 0) {
            _resolveHit(w, e);
            e.completedAttacks++;
            SkillTriggerRunner.onAttackCompleted(w, e);
            e.action = EntityAction.attackRecover;
            // attackCooldown은 windup 진입 시 attackPeriod로 스냅샷된 뒤 매 틱
            // 감소해왔으므로, 지금 값이 곧 (스냅샷된) P - A다. 공격속도가
            // windup 도중 바뀌어도 이번 사이클의 recover 길이엔 영향 없음
            // (§4.1 "공격속도 변화는 다음 공격 시작부터 반영").
            e.actionTimer = e.attackCooldown;
          }
        case EntityAction.attackRecover:
          e.actionTimer--;
          if (e.actionTimer <= 0) {
            e.action = EntityAction.idle;
            // 같은 틱에 즉시 재시도해야 P(=A+R)틱마다 정확히 1회 판정이 된다.
            // 다음 틱까지 미루면 idle로 대기하는 틱이 하나 더 끼어 P+1이 된다.
            _tryStartWindup(e);
          }
        default:
          _tryStartWindup(e);
      }
    }
  }

  void _tryStartWindup(BattleEntity e) {
    if (e.attackCooldown == 0 && e.currentTargetInRange) {
      e.action = EntityAction.attackWindup;
      e.actionTimer = e.stats.get(StatKey.attackWindup);
      e.attackCooldown = e.stats.get(StatKey.attackPeriod); // 이번 사이클 스냅샷
      e.lockedTargetId = e.currentTargetId; // SINGLE: 시작 시 고정. AOE는 판정 시 다시 뽑음.
    }
  }

  void _cancelAttack(BattleEntity e) {
    if (e.action == EntityAction.attackWindup ||
        e.action == EntityAction.attackRecover) {
      e.actionTimer = 0;
      e.lockedTargetId = null;
    }
  }

  void _resolveHit(BattleWorld w, BattleEntity e) {
    final hits = e.def.base.attackMode == 'AOE'
        ? _selectAoeTargets(w, e)
        : _resolveSingleTarget(w, e);
    e.lastHitTargetIds = hits;

    for (final targetId in hits) {
      final target = w.entities.byId(targetId);
      if (target == null) continue;
      final amount = computeDamage(w, e, target, e.stats.get(StatKey.atk));
      w.pendingDamage.add(
        PendingDamage(targetId: targetId, sourceId: e.id, amount: amount),
      );
    }
  }

  List<int> _resolveSingleTarget(BattleWorld w, BattleEntity e) {
    final targetId = e.lockedTargetId;
    if (targetId == null) return const [];
    final target = w.entities.byId(targetId);
    if (target == null || !target.isAlive) return const []; // 사망 -> 헛침
    if (!inRange(e, target)) return const []; // 사거리 밖 -> 헛침
    return [target.id];
  }

  /// 발동 시점에 다시 뽑는다: NEAREST 정렬 후 aoeMaxTargets개, 동거리는 entityId 오름차순.
  List<int> _selectAoeTargets(BattleWorld w, BattleEntity e) {
    final maxTargets = e.stats.get(StatKey.aoeMaxTargets);
    final candidates = [
      for (final other in w.entities.ordered)
        if (other.side != e.side && other.isTargetable && inRange(e, other))
          other,
    ];
    candidates.sort((a, b) {
      final da = (a.x - e.x).abs();
      final db = (b.x - e.x).abs();
      final cmp = da.compareTo(db);
      return cmp != 0 ? cmp : a.id.compareTo(b.id);
    });
    return [for (final c in candidates.take(maxTargets)) c.id];
  }
}
