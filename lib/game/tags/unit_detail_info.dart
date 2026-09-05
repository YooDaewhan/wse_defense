import '../../battle/entity/battle_entity.dart';
import '../../battle/stat/modifier.dart';
import '../../battle/tag/tag_registry.dart';

/// 05_FRONTEND.md §6.1: "유닛 탭 → 우측 슬라이드 패널에 전체 태그·
/// 모디파이어 내역(일시정지 상태에서만)."
///
/// 일시정지 여부는 렌더/화면 레이어(BattleGame.paused)의 몫이라 여기선
/// 다루지 않는다 — 이 함수는 "지금 이 유닛의 전체 내역이 뭔가"만 계산한다.
class UnitTagRow {
  const UnitTagRow({required this.tagId, required this.level});
  final String tagId;
  final int level;
}

class UnitModifierRow {
  const UnitModifierRow({required this.stat, required this.op, required this.value, required this.sourceLabel});
  final String stat;
  final String op;
  final int value;
  final String sourceLabel; // "관계:RULE_X", "태그:TEF_Y" 등
}

class UnitDetailInfo {
  const UnitDetailInfo({required this.tags, required this.modifiers});
  final List<UnitTagRow> tags;
  final List<UnitModifierRow> modifiers;
}

UnitDetailInfo unitDetailInfo(BattleEntity e, TagRegistry registry) {
  final tags = [
    for (final (tagIndex, level) in e.tags.entries())
      UnitTagRow(tagId: registry.idOf(tagIndex), level: level),
  ];
  final modifiers = [
    for (final m in e.stats.modifiers)
      UnitModifierRow(
        stat: m.stat.name,
        op: _opLabel(m.op),
        value: m.value,
        sourceLabel: '${m.source.kind.name}:${m.source.id}',
      ),
  ];
  return UnitDetailInfo(tags: tags, modifiers: modifiers);
}

String _opLabel(ModOp op) => switch (op) {
  ModOp.flatAdd => '+',
  ModOp.pctAdd => '%+',
  ModOp.mult => '×',
  ModOp.setMin => '≥',
  ModOp.setMax => '≤',
};
