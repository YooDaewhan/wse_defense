import 'tag_contribution.dart';
import 'tag_def.dart';
import 'tag_stack.dart';

/// 02_TAG_SYSTEM.md §3.2: `String id ↔ int index` 양방향 맵을 로딩 시 구축한다.
/// 매 틱 수백 번 조회되므로 문자열 대신 정수 인덱스로 다루기 위함.
class TagRegistry {
  TagRegistry(List<TagDef> defs)
    : _defs = List.unmodifiable(defs),
      _idToIndex = {for (var i = 0; i < defs.length; i++) defs[i].id: i};

  final List<TagDef> _defs;
  final Map<String, int> _idToIndex;

  int get length => _defs.length;

  /// 존재하지 않는 id면 -1 (경고 로그는 호출부 책임, 크래시 금지).
  int indexOf(String id) => _idToIndex[id] ?? -1;

  String idOf(int index) => _defs[index].id;

  TagDef defOf(int index) => _defs[index];

  /// contribution 목록을 처음부터 다시 합산해 TagStack을 만든다.
  /// "추가/제거가 대칭"이 되는 이유: 만료/제거된 contribution을 뺀 목록으로
  /// 다시 호출하면 정확히 이전 상태로 복귀한다(증분 계산의 누적 오차가 없음).
  TagStack buildStack(Iterable<TagContribution> contributions) {
    final stack = TagStack();
    for (final c in contributions) {
      if (c.tagIndex < 0 || c.tagIndex >= _defs.length) continue;
      stack.add(c.tagIndex, c.amount, maxLevel: _defs[c.tagIndex].maxUnitLevel);
    }
    return stack;
  }

  /// 02_TAG_SYSTEM.md §6.6: PASS 0 직후 1회 수행하는 상충 해석.
  /// CANCEL_EQUAL/HIGHER_WINS는 stack을 직접 변경한다. COEXIST는 아무것도 안 한다.
  void resolveConflicts(TagStack stack) {
    for (final def in _defs) {
      if (def.conflicts.isEmpty) continue;
      final aIndex = indexOf(def.id);
      if (aIndex == -1) continue;

      for (final conflict in def.conflicts) {
        final bIndex = indexOf(conflict.withId);
        if (bIndex == -1) continue;

        final aLevel = stack.levelOf(aIndex);
        final bLevel = stack.levelOf(bIndex);
        if (aLevel == 0 || bLevel == 0) continue;

        switch (conflict.resolve) {
          case ConflictResolve.cancelEqual:
            final cancel = aLevel < bLevel ? aLevel : bLevel;
            stack.add(aIndex, -cancel);
            stack.add(bIndex, -cancel);
          case ConflictResolve.higherWins:
            if (aLevel >= bLevel) {
              stack.add(bIndex, -bLevel);
            } else {
              stack.add(aIndex, -aLevel);
            }
          case ConflictResolve.coexist:
            break;
        }
      }
    }
  }
}
