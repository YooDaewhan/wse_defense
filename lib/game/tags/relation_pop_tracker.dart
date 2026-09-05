import '../../battle/entity/battle_entity.dart';
import '../../battle/stat/modifier_source.dart';
import '../../battle/stat/stat_key.dart';

/// 05_FRONTEND.md §6.1: "관계 발동/해제 시 짧은 아이콘 팝 + 이동속도
/// 화살표(↑/↓) 0.6초."
class RelationPop {
  const RelationPop({required this.ruleId, required this.speedUp, required this.remainingSec});
  final String ruleId;

  /// true == ↑(빨라짐), false == ↓(느려짐).
  final bool speedUp;
  final double remainingSec;
}

/// 유닛 하나의 관계 활성화 상태 전이를 관찰해 0.6초짜리 팝을 만든다.
/// Flame 의존이 없는 순수 로직 — `BattleEntity`만 있으면 통째로 테스트된다.
class RelationPopTracker {
  static const double popDurationSec = 0.6;

  final Map<String, bool> _wasActive = {};
  final Map<String, bool> _lastDirectionUp = {};
  final Map<String, double> _remaining = {};

  /// 매 프레임 호출. 이번 프레임에 아직 살아있는(만료 안 된) 팝 목록을 돌려준다.
  List<RelationPop> update(BattleEntity e, double dtSeconds) {
    for (final entry in e.relationStates.entries) {
      final ruleId = entry.key;
      final isActive = entry.value.active;
      final wasActive = _wasActive[ruleId] ?? false;
      if (isActive != wasActive) {
        if (isActive) {
          // 활성화되는 순간에만 방향을 다시 읽는다 — 비활성화 시점엔 그
          // 관계의 모디파이어가 이미 제거된 뒤라 방향을 알 수 없으므로,
          // 마지막으로 활성이었을 때의 방향을 그대로 재사용한다.
          _lastDirectionUp[ruleId] = _speedUpDirection(e, ruleId);
        }
        _remaining[ruleId] = popDurationSec;
      }
      _wasActive[ruleId] = isActive;
    }

    final alive = <RelationPop>[];
    for (final ruleId in _remaining.keys.toList()) {
      final left = _remaining[ruleId]! - dtSeconds;
      if (left <= 0) {
        _remaining.remove(ruleId);
        continue;
      }
      _remaining[ruleId] = left;
      alive.add(RelationPop(ruleId: ruleId, speedUp: _lastDirectionUp[ruleId] ?? true, remainingSec: left));
    }
    return alive;
  }

  bool _speedUpDirection(BattleEntity e, String ruleId) {
    var sum = 0;
    for (final m in e.stats.modifiers) {
      if (m.source.kind == ModifierKind.relation && m.source.id == ruleId && m.stat == StatKey.moveSpeed) {
        sum += m.value;
      }
    }
    return sum >= 0;
  }
}
