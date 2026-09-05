import '../constants.dart';
import '../entity/battle_entity.dart';
import '../entity/entity_state.dart';
import '../stat/stat_key.dart';
import '../tag/tag_query.dart';
import '../world/battle_world.dart';
import 'battle_system.dart';

/// 03_BATTLE_ENGINE.md §5.
///
/// 같은 편은 겹쳐 지나가고, 상대편끼리는 충돌 경계에서 막힌다. 넉백 중인
/// 유닛은 차단 판정에서 제외한다(`isTargetable`이 이미 그 조건).
///
/// `_sortedBySide`로 진영별 x 정렬 리스트를 매 틱 1회 만들고, 이분 탐색으로
/// "전방의 첫 상대"를 찾는다 — O(N log N). 이 규모(전투당 유닛 수백 이하)에서
/// 굳이 필요한 최적화는 아니지만, 03_BATTLE_ENGINE.md §5가 명시한 복잡도라
/// 그대로 따랐다.
class MovementSystem implements BattleSystem {
  @override
  void execute(BattleWorld w) {
    final allySorted = _sortedBySide(w, Side.ally);
    final enemySorted = _sortedBySide(w, Side.enemy);

    for (final e in w.entities.ordered) {
      if (!e.isAlive || e.isKnockedBack) continue;
      if (e.action != EntityAction.idle && e.action != EntityAction.moving) {
        continue;
      }
      if (e.currentTargetInRange) {
        e.action = EntityAction.idle;
        continue;
      }

      final speed = e.stats.get(StatKey.moveSpeed); // 논리단위/초
      final perTick = speed * posScale ~/ ticksPerSec;
      var nx = e.x + perTick * e.facingSign;

      final opposing = e.side == Side.ally ? enemySorted : allySorted;
      nx = _clampByBlocker(e, opposing, nx);

      final lo = w.minX(e.side);
      final hi = w.maxX(e.side);
      if (nx < lo) nx = lo;
      if (nx > hi) nx = hi;

      if (nx != e.x) {
        e.x = nx;
        e.action = EntityAction.moving;
      } else {
        e.action = EntityAction.idle;
      }
    }
  }

  List<BattleEntity> _sortedBySide(BattleWorld w, Side side) {
    final list = [
      for (final e in w.entities.ordered)
        if (e.side == side && e.isTargetable) e,
    ];
    list.sort((a, b) => a.x.compareTo(b.x));
    return list;
  }

  int _clampByBlocker(BattleEntity e, List<BattleEntity> opposing, int nx) {
    if (e.facingSign > 0) {
      final blocker = _firstAfter(opposing, e.x);
      if (blocker == null) return nx;
      final maxNx =
          blocker.x -
          (e.def.base.collisionRadius + blocker.def.base.collisionRadius) *
              posScale;
      return nx > maxNx ? maxNx : nx;
    } else {
      final blocker = _lastBefore(opposing, e.x);
      if (blocker == null) return nx;
      final minNx =
          blocker.x +
          (e.def.base.collisionRadius + blocker.def.base.collisionRadius) *
              posScale;
      return nx < minNx ? minNx : nx;
    }
  }

  /// [sortedByX]에서 x보다 큰 것 중 가장 작은 원소 (x 오름차순 정렬 가정).
  BattleEntity? _firstAfter(List<BattleEntity> sortedByX, int x) {
    var lo = 0;
    var hi = sortedByX.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (sortedByX[mid].x <= x) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo < sortedByX.length ? sortedByX[lo] : null;
  }

  /// [sortedByX]에서 x보다 작은 것 중 가장 큰 원소.
  BattleEntity? _lastBefore(List<BattleEntity> sortedByX, int x) {
    var lo = 0;
    var hi = sortedByX.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (sortedByX[mid].x < x) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo > 0 ? sortedByX[lo - 1] : null;
  }
}
