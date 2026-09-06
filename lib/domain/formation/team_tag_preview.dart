import '../../battle/defs/unit_def.dart';
import '../../battle/tag/tag_effect_def.dart';
import '../../battle/tag/tag_query.dart';
import '../../battle/tag/tag_registry.dart';
import '../../battle/tag/tag_relation_rule.dart';

/// 05_FRONTEND.md §3.1 `TeamTagPreview`. 02_TAG_SYSTEM.md §2.2의 FORMATION
/// 스코프 규칙(고유 태그 + 장비부여태그, 런타임 버프는 제외) 그대로 —
/// 전투 시작 전 확정값을 미리 보여준다. T-31 당시엔 장비 시스템 자체가
/// 없어서 `equipmentGrantsPerSlot`가 없었지만(고유 태그만 다뤘음), 규칙은
/// 처음부터 장비 포함이었다 — T-43/T-44에서 실제로 채워 넣는다.
class ActiveTierInfo {
  const ActiveTierInfo({required this.effectId, required this.tagId, required this.minLevel});
  final String effectId;
  final String tagId;
  final int minLevel;
}

class NextTierHint {
  const NextTierHint({
    required this.effectId,
    required this.tagId,
    required this.currentLevel,
    required this.nextTierMinLevel,
  });
  final String effectId;
  final String tagId;
  final int currentLevel;
  final int nextTierMinLevel;

  int get levelsNeeded => nextTierMinLevel - currentLevel;
}

class RelationHint {
  const RelationHint({required this.ruleId, required this.nameKey});
  final String ruleId;
  final String nameKey;
}

class TeamTagPreview {
  const TeamTagPreview({
    required this.formationLevels,
    required this.activeTiers,
    required this.nextTierHints,
    required this.relationHints,
  });

  /// tagId -> 편성 전체 합산 레벨(0인 태그는 안 담김).
  final Map<String, int> formationLevels;
  final List<ActiveTierInfo> activeTiers;
  final List<NextTierHint> nextTierHints;
  final List<RelationHint> relationHints;
}

TeamTagPreview computeTeamTagPreview(
  List<UnitDef> formation,
  TagRegistry registry,
  List<TagEffectDef> effects,
  List<TagRelationRule> relations, {
  List<Map<String, int>>? equipmentGrantsPerSlot,
}) {
  // PASS 0~1 (02_TAG_SYSTEM.md §2.2/§2.3): UNIT 스코프 = 고유 태그 +
  // 장비부여태그(런타임 버프 제외) 합산. `equipmentGrantsPerSlot`은
  // `formation`과 같은 길이의 슬롯별 부여 태그 맵 — 안 주면(기존 호출부)
  // 장비가 아예 없는 것과 같다.
  final levelByIndex = <int, int>{};
  for (var i = 0; i < formation.length; i++) {
    final def = formation[i];
    for (final entry in def.intrinsicTags.entries) {
      final idx = registry.indexOf(entry.key);
      if (idx == -1) continue;
      levelByIndex[idx] = (levelByIndex[idx] ?? 0) + entry.value;
    }
    final equipmentGrants = (equipmentGrantsPerSlot != null && i < equipmentGrantsPerSlot.length)
        ? equipmentGrantsPerSlot[i]
        : const <String, int>{};
    for (final entry in equipmentGrants.entries) {
      final idx = registry.indexOf(entry.key);
      if (idx == -1) continue;
      levelByIndex[idx] = (levelByIndex[idx] ?? 0) + entry.value;
    }
  }
  for (final idx in levelByIndex.keys.toList()) {
    final cap = registry.defOf(idx).maxTeamLevel;
    if (levelByIndex[idx]! > cap) levelByIndex[idx] = cap;
  }

  final formationLevels = {
    for (final entry in levelByIndex.entries) registry.idOf(entry.key): entry.value,
  };

  final activeTiers = <ActiveTierInfo>[];
  final nextTierHints = <NextTierHint>[];
  for (final effect in effects) {
    if (effect.scope != TagScope.formation || effect.mode != TagEffectMode.tier) continue;
    final level = levelByIndex[effect.tagIndex] ?? 0;
    final tagId = registry.idOf(effect.tagIndex);
    final sortedTiers = [...effect.tiers]..sort((a, b) => a.minLevel.compareTo(b.minLevel));

    int? nextMinLevel;
    for (final tier in sortedTiers) {
      if (level >= tier.minLevel) {
        activeTiers.add(ActiveTierInfo(effectId: effect.id, tagId: tagId, minLevel: tier.minLevel));
      } else {
        nextMinLevel ??= tier.minLevel;
      }
    }
    if (nextMinLevel != null) {
      nextTierHints.add(
        NextTierHint(effectId: effect.id, tagId: tagId, currentLevel: level, nextTierMinLevel: nextMinLevel),
      );
    }
  }

  final unitTagSets = [for (final def in formation) _unitTagIndexSet(def, registry)];
  final relationHints = <RelationHint>[
    for (final rule in relations)
      if (_relationFeasible(rule, formation, unitTagSets)) RelationHint(ruleId: rule.id, nameKey: rule.nameKey),
  ];

  return TeamTagPreview(
    formationLevels: formationLevels,
    activeTiers: activeTiers,
    nextTierHints: nextTierHints,
    relationHints: relationHints,
  );
}

Set<int> _unitTagIndexSet(UnitDef def, TagRegistry registry) => {
  for (final entry in def.intrinsicTags.entries)
    if (entry.value > 0 && registry.indexOf(entry.key) != -1) registry.indexOf(entry.key),
};

/// 위치는 전투 중에만 정해지므로, 편성 화면에서는 "이 편성 안에 subject/
/// other 조건을 만족하는 유닛이 각각 최소 1명씩 있는가"만으로 발동
/// 가능성을 예고한다 — 실제 발동 여부(거리·정렬)는 전투 중에 결정된다.
bool _relationFeasible(TagRelationRule rule, List<UnitDef> formation, List<Set<int>> unitTagSets) {
  if (formation.length < 2) return false;

  bool satisfiedBy(TagQuery query) {
    for (var i = 0; i < formation.length; i++) {
      if (_staticMatch(formation[i], unitTagSets[i], query)) return true;
    }
    return false;
  }

  return satisfiedBy(rule.subject) && satisfiedBy(rule.other);
}

bool _staticMatch(UnitDef def, Set<int> unitTags, TagQuery query) {
  for (final t in query.hasTags) {
    if (!unitTags.contains(t)) return false;
  }
  if (query.anyTags.isNotEmpty && !query.anyTags.any(unitTags.contains)) return false;
  for (final t in query.notTags) {
    if (unitTags.contains(t)) return false;
  }
  if (query.roles.isNotEmpty && !query.roles.contains(def.role)) return false;
  return true;
}
