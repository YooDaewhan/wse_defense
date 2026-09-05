/// 02_TAG_SYSTEM.md §3.4 TagQuery.
///
/// `BattleEntity`/`BattleWorld`는 T-07에서 정의된다. T-06은 그보다 먼저
/// 배치된 티켓이라, TagQuery가 필요로 하는 최소 필드만 [TagQueryTarget]
/// 인터페이스로 뽑아둔다. T-07의 `BattleEntity`는 이 인터페이스를 구현하면
/// 그대로 select()/matches()에 넘길 수 있다.
enum Side { ally, enemy }

/// 효과 소유자(owner) 기준 대상 진영.
enum QuerySide { same, enemy, any }

enum QuerySort { nearest, farthest, lowestHp, entityId }

abstract class TagQueryTarget {
  int get entityId;
  Side get side;
  int get posX;
  int get hp;
  bool get isAlive;
  bool get isKnockback;
  String? get role;

  /// UNIT 스코프 태그 레벨. T-05 `TagStack`과 동일한 정수 인덱스 기준.
  int tagLevel(int tagIndex);
}

class TagQuery {
  const TagQuery({
    this.side = QuerySide.same,
    this.hasTags = const [],
    this.anyTags = const [],
    this.notTags = const [],
    this.minTagLevel = const [],
    this.roles = const [],
    this.aliveOnly = true,
    this.excludeKnockback = false,
    this.limit = 0,
    this.sort = QuerySort.entityId,
  });

  final QuerySide side;
  final List<int> hasTags; // 전부 보유 (AND)
  final List<int> anyTags; // 하나라도 (OR)
  final List<int> notTags;

  /// (tagIndex, minLevel) 쌍의 목록. Map을 쓰지 않는 이유는
  /// 01_ARCHITECTURE.md §3.2 "Map/Set 순회 금지"를 battle/** 전역에서 지키기 위함.
  final List<(int tagIndex, int minLevel)> minTagLevel;

  final List<String> roles;
  final bool aliveOnly;
  final bool excludeKnockback;

  /// 0 = 무제한.
  final int limit;
  final QuerySort sort;

  bool matches(TagQueryTarget e, TagQueryTarget owner) {
    if (aliveOnly && !e.isAlive) return false;
    if (excludeKnockback && e.isKnockback) return false;

    switch (side) {
      case QuerySide.same:
        if (e.side != owner.side) return false;
      case QuerySide.enemy:
        if (e.side == owner.side) return false;
      case QuerySide.any:
        break;
    }

    for (final t in hasTags) {
      if (e.tagLevel(t) <= 0) return false;
    }

    if (anyTags.isNotEmpty) {
      var matchedAny = false;
      for (final t in anyTags) {
        if (e.tagLevel(t) > 0) {
          matchedAny = true;
          break;
        }
      }
      if (!matchedAny) return false;
    }

    for (final t in notTags) {
      if (e.tagLevel(t) > 0) return false;
    }

    for (final (tagIndex, minLevel) in minTagLevel) {
      if (e.tagLevel(tagIndex) < minLevel) return false;
    }

    if (roles.isNotEmpty && !roles.contains(e.role)) return false;

    return true;
  }

  /// [candidates]는 호출부가 이미 확보한 후보 목록(보통 `BattleWorld`의
  /// 전체 엔티티)이다. side 조건은 matches()가 owner 기준으로 알아서 거른다.
  List<T> select<T extends TagQueryTarget>(Iterable<T> candidates, T owner) {
    final matched = [
      for (final c in candidates)
        if (matches(c, owner)) c,
    ];

    int distanceOf(T e) => (e.posX - owner.posX).abs();

    matched.sort((a, b) {
      final primary = switch (sort) {
        QuerySort.nearest => distanceOf(a).compareTo(distanceOf(b)),
        QuerySort.farthest => distanceOf(b).compareTo(distanceOf(a)),
        QuerySort.lowestHp => a.hp.compareTo(b.hp),
        QuerySort.entityId => 0,
      };
      // 동점이면 entityId 오름차순 (결정론).
      return primary != 0 ? primary : a.entityId.compareTo(b.entityId);
    });

    if (limit > 0 && matched.length > limit) {
      return matched.sublist(0, limit);
    }
    return matched;
  }
}
