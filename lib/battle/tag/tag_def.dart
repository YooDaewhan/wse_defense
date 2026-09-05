/// 02_TAG_SYSTEM.md §3.1 tags.json 스키마 + §6.6 상충 규칙.
enum TagCategory { race, element, temper, build, trait, role, habit }

TagCategory _categoryFromJson(String raw) => switch (raw) {
  'RACE' => TagCategory.race,
  'ELEMENT' => TagCategory.element,
  'TEMPER' => TagCategory.temper,
  'BUILD' => TagCategory.build,
  'TRAIT' => TagCategory.trait,
  'ROLE' => TagCategory.role,
  'HABIT' => TagCategory.habit,
  _ => throw FormatException('알 수 없는 TagCategory: $raw'),
};

/// CANCEL_EQUAL: 두 태그 레벨을 같은 만큼 상쇄.
/// HIGHER_WINS : 높은 쪽만 남기고 낮은 쪽 0.
/// COEXIST     : 둘 다 유지.
enum ConflictResolve { cancelEqual, higherWins, coexist }

ConflictResolve _resolveFromJson(String raw) => switch (raw) {
  'CANCEL_EQUAL' => ConflictResolve.cancelEqual,
  'HIGHER_WINS' => ConflictResolve.higherWins,
  'COEXIST' => ConflictResolve.coexist,
  _ => throw FormatException('알 수 없는 conflict resolve: $raw'),
};

class TagConflict {
  const TagConflict(this.withId, this.resolve);

  /// 상대 태그의 문자열 id. TagRegistry가 로딩 시 인덱스로 해석한다.
  final String withId;
  final ConflictResolve resolve;

  factory TagConflict.fromJson(Map<String, Object?> json) => TagConflict(
    json['with'] as String,
    _resolveFromJson(json['resolve'] as String),
  );
}

class TagDef {
  const TagDef({
    required this.id,
    required this.category,
    this.maxUnitLevel = 5,
    this.maxTeamLevel = 20,
    this.sortOrder = 0,
    this.conflicts = const [],
  });

  final String id;
  final TagCategory category;
  final int maxUnitLevel;
  final int maxTeamLevel;
  final int sortOrder;
  final List<TagConflict> conflicts;

  factory TagDef.fromJson(Map<String, Object?> json) => TagDef(
    id: json['id'] as String,
    category: _categoryFromJson(json['category'] as String),
    maxUnitLevel: json['maxUnitLevel'] as int? ?? 5,
    maxTeamLevel: json['maxTeamLevel'] as int? ?? 20,
    sortOrder: json['sortOrder'] as int? ?? 0,
    conflicts: [
      for (final c in (json['conflicts'] as List<Object?>? ?? const []))
        TagConflict.fromJson(c as Map<String, Object?>),
    ],
  );
}
