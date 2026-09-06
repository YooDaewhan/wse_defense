import '../../battle/tag/tag_registry.dart';
import 'equipment_def.dart';

/// 02_TAG_SYSTEM.md §2.2 PASS 0: "장비로 받은 태그도 UNIT 레벨에 포함되므로
/// 팀 기여에 포함된다". 07_DUNGEON_EXCHANGE.md §6.3: "+5 도달 시 태그 +1".
Map<String, int> effectiveGrantTags(EquipmentDef def, int enhanceLevel) {
  final tagId = def.grantTagId;
  if (tagId == null || def.grantTagBaseLevel <= 0) return const {};
  final bonus = enhanceLevel >= 5 && def.tagBonusAtEnhance5 ? 1 : 0;
  return {tagId: def.grantTagBaseLevel + bonus};
}

class TagLevelChangePreview {
  const TagLevelChangePreview({required this.tagId, required this.beforeLevel, required this.afterLevel});
  final String tagId;
  final int beforeLevel;
  final int afterLevel;

  bool get isTierChange => beforeLevel != afterLevel;
}

/// 07_DUNGEON_EXCHANGE.md §5.1: "이 장비를 장착하면 팀 동물 레벨이 4 →
/// 5가 됩니다" — 아직 장착 전(교환소에서 후보를 검토하는 시점)의 예고.
/// 어느 슬롯에 낄지는 모르므로 "지금 편성에 이 장비의 부여 태그가
/// 더해지면"으로 단순화한다(§7.1 진행 예시와 일치).
TagLevelChangePreview? previewEquipTagChange({
  required Map<String, int> currentFormationLevels,
  required EquipmentDef candidate,
  required int enhanceLevel,
  required TagRegistry registry,
}) {
  final grants = effectiveGrantTags(candidate, enhanceLevel);
  if (grants.isEmpty) return null;

  final entry = grants.entries.first;
  final index = registry.indexOf(entry.key);
  if (index == -1) return null;

  final before = currentFormationLevels[entry.key] ?? 0;
  final cap = registry.defOf(index).maxTeamLevel;
  final after = (before + entry.value).clamp(0, cap);
  return TagLevelChangePreview(tagId: entry.key, beforeLevel: before, afterLevel: after);
}
