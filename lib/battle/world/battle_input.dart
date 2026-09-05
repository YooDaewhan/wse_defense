/// 03_BATTLE_ENGINE.md §14의 입력 모델. 리플레이/직렬화(`InputLog`)는 T-20에서
/// 붙인다 — 여기서는 InputSystem(T-12)이 소비할 수 있는 만큼만 정의한다.
sealed class BattleInput {
  const BattleInput(this.tick);
  final int tick;
}

class SummonInput extends BattleInput {
  const SummonInput(super.tick, this.slotIndex);
  final int slotIndex;
}

class UltimateInput extends BattleInput {
  const UltimateInput(super.tick);
}

class FocusBoostInput extends BattleInput {
  const FocusBoostInput(super.tick, this.stage);
  final int stage;
}

class PageSwitchInput extends BattleInput {
  const PageSwitchInput(super.tick, this.page); // 편성 2페이지 전환
  final int page;
}

/// 틱별 입력 큐. `TagStack`과 같은 이유로 정렬된 평행 배열을 쓴다
/// (Map/Set 순회 금지, 01_ARCHITECTURE.md §3.2).
class InputQueue {
  final List<int> _ticks = [];
  final List<List<BattleInput>> _batches = [];

  void add(int tick, BattleInput input) {
    final pos = _positionOf(tick);
    if (pos == -1) {
      final at = _insertionPoint(tick);
      _ticks.insert(at, tick);
      _batches.insert(at, [input]);
    } else {
      _batches[pos].add(input);
    }
  }

  /// 해당 틱의 입력을 꺼내고 큐에서 제거한다. 없으면 빈 리스트.
  List<BattleInput> take(int tick) {
    final pos = _positionOf(tick);
    if (pos == -1) return const [];
    final batch = _batches.removeAt(pos);
    _ticks.removeAt(pos);
    return batch;
  }

  int _positionOf(int tick) {
    var lo = 0;
    var hi = _ticks.length - 1;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      final v = _ticks[mid];
      if (v == tick) return mid;
      if (v < tick) {
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    return -1;
  }

  int _insertionPoint(int tick) {
    var lo = 0;
    var hi = _ticks.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (_ticks[mid] < tick) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo;
  }
}
