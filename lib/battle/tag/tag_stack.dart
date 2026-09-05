/// 02_TAG_SYSTEM.md §3.2: 한 유닛의 태그 레벨 집합.
/// 결정론을 위해 (인덱스 오름차순, Map/Set 미사용) 정렬된 평행 배열로 보관한다.
/// 레벨이 0인 태그는 저장하지 않는다(희소 표현).
class TagStack {
  final List<int> _tagIndex = [];
  final List<int> _levels = [];

  int levelOf(int tagIndex) {
    final pos = _positionOf(tagIndex);
    return pos == -1 ? 0 : _levels[pos];
  }

  bool has(int tagIndex) => levelOf(tagIndex) > 0;

  /// delta만큼 더하고 [0, maxLevel]로 clamp한다. maxLevel 생략 시 하한 0만 적용.
  void add(int tagIndex, int delta, {int maxLevel = 1 << 30}) {
    final pos = _positionOf(tagIndex);
    final current = pos == -1 ? 0 : _levels[pos];
    var next = current + delta;
    if (next < 0) next = 0;
    if (next > maxLevel) next = maxLevel;

    if (next == 0) {
      if (pos != -1) {
        _tagIndex.removeAt(pos);
        _levels.removeAt(pos);
      }
      return;
    }
    if (pos == -1) {
      final at = _insertionPoint(tagIndex);
      _tagIndex.insert(at, tagIndex);
      _levels.insert(at, next);
    } else {
      _levels[pos] = next;
    }
  }

  /// 항상 tagIndex 오름차순으로 순회한다.
  Iterable<(int tag, int level)> entries() sync* {
    for (var i = 0; i < _tagIndex.length; i++) {
      yield (_tagIndex[i], _levels[i]);
    }
  }

  int _positionOf(int tagIndex) {
    var lo = 0;
    var hi = _tagIndex.length - 1;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      final v = _tagIndex[mid];
      if (v == tagIndex) return mid;
      if (v < tagIndex) {
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    return -1;
  }

  int _insertionPoint(int tagIndex) {
    var lo = 0;
    var hi = _tagIndex.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (_tagIndex[mid] < tagIndex) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo;
  }
}
