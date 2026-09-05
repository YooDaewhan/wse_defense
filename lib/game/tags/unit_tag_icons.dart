import '../../battle/entity/battle_entity.dart';
import '../../battle/tag/tag_registry.dart';

/// 05_FRONTEND.md §6.1: "유닛 발밑에 최대 2개의 소형 아이콘만(현재 활성
/// 시너지 / 관계). 그 이상은 시야를 가린다."
///
/// 실제 아이콘 이미지는 아직 없어(P0~P1 무아트) [label]만 담는다 — 렌더
/// 레이어가 작은 도형 + 텍스트로 대체 표시한다.
class UnitTagIcon {
  const UnitTagIcon({required this.label, required this.isRelation});
  final String label;
  final bool isRelation;
}

/// 관계(활성인 것)를 먼저 채우고, 남는 자리를 태그 레벨이 있는 순서대로
/// 채운다. 둘 다 [max](기본 2)를 넘지 않는다.
List<UnitTagIcon> unitTagIcons(BattleEntity e, TagRegistry registry, {int max = 2}) {
  final icons = <UnitTagIcon>[];

  for (final entry in e.relationStates.entries) {
    if (icons.length >= max) break;
    if (entry.value.active) {
      icons.add(UnitTagIcon(label: entry.key, isRelation: true));
    }
  }

  if (icons.length < max) {
    for (final (tagIndex, level) in e.tags.entries()) {
      if (icons.length >= max) break;
      if (level <= 0) continue;
      icons.add(UnitTagIcon(label: registry.idOf(tagIndex), isRelation: false));
    }
  }

  return icons;
}
