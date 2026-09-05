import '../../battle/defs/unit_def.dart';

/// 05_FRONTEND.md §3.1: "역할/물리·마법/근·원거리/기질/특징 필터가 각각
/// 독립 동작". 카테고리 사이는 AND, 같은 카테고리 안에서 고른 값들끼리는
/// OR — 카테고리가 비어 있으면(아무것도 선택 안 함) 그 축은 필터링하지
/// 않는다. `tempers`/`traits`는 `UnitDef.intrinsicTags`의 태그 id를 그대로
/// 쓴다(TagRegistry 조회 없이도 필터링이 가능해 편성 화면이 태그 데이터
/// 로딩에 의존하지 않아도 된다).
class CharacterFilter {
  const CharacterFilter({
    this.roles = const {},
    this.damageTypes = const {},
    this.attackReaches = const {},
    this.tempers = const {},
    this.traits = const {},
  });

  final Set<String> roles;
  final Set<String> damageTypes;
  final Set<String> attackReaches;
  final Set<String> tempers;
  final Set<String> traits;

  bool get isEmpty =>
      roles.isEmpty && damageTypes.isEmpty && attackReaches.isEmpty && tempers.isEmpty && traits.isEmpty;

  bool matches(UnitDef def) {
    if (roles.isNotEmpty && !roles.contains(def.role)) return false;
    if (damageTypes.isNotEmpty && !damageTypes.contains(def.base.damageType)) return false;
    if (attackReaches.isNotEmpty && !attackReaches.contains(def.base.attackReach)) return false;
    if (tempers.isNotEmpty && !tempers.any(def.intrinsicTags.containsKey)) return false;
    if (traits.isNotEmpty && !traits.any(def.intrinsicTags.containsKey)) return false;
    return true;
  }

  CharacterFilter copyWith({
    Set<String>? roles,
    Set<String>? damageTypes,
    Set<String>? attackReaches,
    Set<String>? tempers,
    Set<String>? traits,
  }) => CharacterFilter(
    roles: roles ?? this.roles,
    damageTypes: damageTypes ?? this.damageTypes,
    attackReaches: attackReaches ?? this.attackReaches,
    tempers: tempers ?? this.tempers,
    traits: traits ?? this.traits,
  );
}
