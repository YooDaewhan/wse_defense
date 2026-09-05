import '../constants.dart';
import '../entity/battle_entity.dart';
import '../world/battle_world.dart';
import 'tag_query.dart';
import 'tag_relation_rule.dart';

/// 02_TAG_SYSTEM.md §4.2, §4.4~4.6: subject 기준으로 규칙 하나를 평가한다.
/// 순수 함수 모음 — 상태는 전혀 들고 있지 않는다 (상태는 RelationState).
class RelationEvaluator {
  const RelationEvaluator._();

  /// §4.2: other가 subject보다 전진 방향으로 앞인가.
  static bool isAhead(BattleEntity subject, BattleEntity other) =>
      (other.x - subject.x) * subject.facingSign > 0;

  static bool isBehind(BattleEntity subject, BattleEntity other) =>
      (other.x - subject.x) * subject.facingSign < 0;

  /// 논리 단위 거리.
  static int distance(BattleEntity subject, BattleEntity other) =>
      (other.x - subject.x).abs() ~/ posScale;

  static bool _inRange(int dist, TagRelationRule rule) {
    if (dist < rule.rangeMin) return false;
    if (rule.rangeMax > 0 && dist > rule.rangeMax) return false;
    return true;
  }

  /// relation 종류별 "만족하는 other 수"(FRONTMOST류는 1/0으로 환산).
  static int countMatches(
    TagRelationRule rule,
    BattleEntity subject,
    BattleWorld w,
  ) {
    switch (rule.relation) {
      case RelationKind.otherIsAhead:
      case RelationKind.noOtherAhead:
        return _countCandidates(
          rule,
          subject,
          w,
          (other) => isAhead(subject, other) && _inRange(distance(subject, other), rule),
        );
      case RelationKind.otherIsBehind:
        return _countCandidates(
          rule,
          subject,
          w,
          (other) => isBehind(subject, other) && _inRange(distance(subject, other), rule),
        );
      case RelationKind.otherIsAdjacent:
        return _countCandidates(
          rule,
          subject,
          w,
          (other) => _inRange(distance(subject, other), rule),
        );
      case RelationKind.enemyWithin:
        return _countCandidates(
          rule,
          subject,
          w,
          (other) => other.side != subject.side && _inRange(distance(subject, other), rule),
        );
      case RelationKind.otherIsFrontmost:
        final front = _frontmost(subject.side, w);
        return (front != null && rule.other.matches(front, subject)) ? 1 : 0;
      case RelationKind.subjectIsFrontmost:
        return identical(_frontmost(subject.side, w), subject) ? 1 : 0;
      case RelationKind.subjectIsRearmost:
        return identical(_rearmost(subject.side, w), subject) ? 1 : 0;
    }
  }

  /// NO_OTHER_AHEAD만 "이하"로 뒤집힌다 (requireCount:0 -> 앞에 0명이어야 활성).
  static bool wantActive(TagRelationRule rule, int matched) {
    if (rule.relation == RelationKind.noOtherAhead) {
      return matched <= rule.requireCount;
    }
    return matched >= rule.requireCount;
  }

  static int computeScale(TagRelationRule rule, int matched, BattleEntity subject) {
    if (rule.scaleByOtherCount) {
      final s = matched < 1 ? 1 : matched;
      return s > rule.maxScale ? rule.maxScale : s;
    }
    if (rule.scaleBySubjectTagLevel && rule.subject.hasTags.isNotEmpty) {
      final level = subject.tagLevel(rule.subject.hasTags.first);
      final s = level < 1 ? 1 : level;
      return s > rule.maxScale ? rule.maxScale : s;
    }
    return 1;
  }

  static int _countCandidates(
    TagRelationRule rule,
    BattleEntity subject,
    BattleWorld w,
    bool Function(BattleEntity other) geometry,
  ) {
    var count = 0;
    for (final other in w.entities.ordered) {
      if (other.id == subject.id) continue;
      if (!rule.other.matches(other, subject)) continue;
      if (!geometry(other)) continue;
      count++;
    }
    return count;
  }

  static BattleEntity? _frontmost(Side side, BattleWorld w) {
    BattleEntity? best;
    final sign = side == Side.ally ? 1 : -1;
    for (final e in w.entities.ordered) {
      if (e.side != side || !e.isAlive) continue;
      if (best == null || e.x * sign > best.x * sign) best = e;
    }
    return best;
  }

  static BattleEntity? _rearmost(Side side, BattleWorld w) {
    BattleEntity? best;
    final sign = side == Side.ally ? 1 : -1;
    for (final e in w.entities.ordered) {
      if (e.side != side || !e.isAlive) continue;
      if (best == null || e.x * sign < best.x * sign) best = e;
    }
    return best;
  }
}
