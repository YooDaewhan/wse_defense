import '../constants.dart';
import 'modifier.dart';
import 'modifier_source.dart';
import 'stat_key.dart';

/// 02_TAG_SYSTEM.md §3.6 최종 계산식 + §8.1 출처 태깅.
///
/// final = clamp( (base + ΣFLAT_ADD) * (PCT_SCALE + ΣPCT_ADD) / PCT_SCALE
///                * Π(MULT), min, max )
class StatSheet {
  StatSheet(Map<StatKey, int> base) : _base = Map.of(base);

  final Map<StatKey, int> _base;
  final List<StatModifier> _modifiers = [];
  final Map<StatKey, int> _cache = {};
  bool _dirty = true;

  void addModifier(StatModifier m) {
    _modifiers.add(m);
    _dirty = true;
  }

  /// 해당 출처(kind, id)의 모디파이어를 통째로 제거한다.
  void removeBySource(ModifierKind kind, String id) {
    _modifiers.removeWhere((m) => m.source.kind == kind && m.source.id == id);
    _dirty = true;
  }

  /// 같은 스킬의 특정 인스턴스가 남긴 모디파이어만 제거한다.
  void removeByInstance(int instanceId) {
    _modifiers.removeWhere((m) => m.source.instanceId == instanceId);
    _dirty = true;
  }

  int get(StatKey k) {
    if (_dirty) _recompute();
    return _cache[k]!;
  }

  void _recompute() {
    for (final key in StatKey.values) {
      _cache[key] = _computeStat(key);
    }
    _dirty = false;
  }

  int _computeStat(StatKey key) {
    final active = _activeModifiersFor(key);

    var flatSum = 0;
    var pctSum = 0;
    var multProduct = pctScale;
    int? minBound;
    int? maxBound;

    for (final m in active) {
      switch (m.op) {
        case ModOp.flatAdd:
          flatSum += m.value;
        case ModOp.pctAdd:
          pctSum += m.value;
        case ModOp.mult:
          multProduct = multProduct * m.value ~/ pctScale;
        case ModOp.setMin:
          minBound = (minBound == null || m.value > minBound) ? m.value : minBound;
        case ModOp.setMax:
          maxBound = (maxBound == null || m.value < maxBound) ? m.value : maxBound;
      }
    }

    var result = (_base[key] ?? 0) + flatSum;
    result = result * (pctScale + pctSum) ~/ pctScale;
    result = result * multProduct ~/ pctScale;
    if (minBound != null && result < minBound) result = minBound;
    if (maxBound != null && result > maxBound) result = maxBound;
    return result;
  }

  /// exclusiveGroup이 없는 모디파이어는 전부, 있는 모디파이어는 그룹별로
  /// value 절대값이 가장 큰 1개만 남긴다. 모디파이어 수가 적어 O(n²)로
  /// 충분하다 (엔티티 목록처럼 대량 순회가 아님).
  /// ponytail: 그룹 수가 수백 단위로 커지면 Map+정렬 인덱스로 바꿀 것.
  List<StatModifier> _activeModifiersFor(StatKey key) {
    final candidates = [
      for (final m in _modifiers)
        if (m.stat == key) m,
    ];

    final groupNames = <String>[];
    final groupBest = <StatModifier>[];
    for (final m in candidates) {
      final group = m.exclusiveGroup;
      if (group == null) continue;
      final idx = groupNames.indexOf(group);
      if (idx == -1) {
        groupNames.add(group);
        groupBest.add(m);
      } else if (m.value.abs() > groupBest[idx].value.abs()) {
        groupBest[idx] = m;
      }
    }

    return [
      for (final m in candidates)
        if (m.exclusiveGroup == null) m,
      ...groupBest,
    ];
  }
}
