import '../constants.dart';
import '../entity/battle_entity.dart';
import '../stat/stat_key.dart';
import '../world/battle_world.dart';
import 'battle_system.dart';

/// 03_BATTLE_ENGINE.md §4.2: 충돌 경계 간 거리 (기획서 6-1).
int gapBetween(BattleEntity a, BattleEntity b) =>
    ((a.x - b.x).abs() ~/ posScale) -
    a.def.base.collisionRadius -
    b.def.base.collisionRadius;

bool inRange(BattleEntity a, BattleEntity b) =>
    gapBetween(a, b) <= a.stats.get(StatKey.attackRange);

/// 03_BATTLE_ENGINE.md §4.2 사거리 판정을 바탕으로 각 유닛의 표적을 정한다.
/// 넉백 중이거나 죽은 유닛은 표적이 될 수 없다(`isTargetable`).
/// 동거리면 entityId 오름차순(결정론).
class TargetSystem implements BattleSystem {
  @override
  void execute(BattleWorld w) {
    for (final e in w.entities.ordered) {
      if (!e.isAlive) continue;

      BattleEntity? best;
      var bestDist = 0;
      for (final other in w.entities.ordered) {
        if (other.side == e.side) continue;
        if (!other.isTargetable) continue;

        final dist = (other.x - e.x).abs();
        if (best == null ||
            dist < bestDist ||
            (dist == bestDist && other.id < best.id)) {
          best = other;
          bestDist = dist;
        }
      }

      e.currentTargetId = best?.id;
      e.currentTargetInRange = best != null && inRange(e, best);
    }
  }
}
