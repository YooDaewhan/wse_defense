import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/entity/battle_entity.dart';
import 'package:wse_defense/battle/tag/tag_def.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/tag/tag_registry.dart';
import 'package:wse_defense/battle/tag/tag_relation_state.dart';
import 'package:wse_defense/game/tags/unit_tag_icons.dart';

final _registry = TagRegistry(const [
  TagDef(id: 'TAG_A', category: TagCategory.trait),
  TagDef(id: 'TAG_B', category: TagCategory.trait),
  TagDef(id: 'TAG_C', category: TagCategory.trait),
]);

const _unit = UnitDef(
  id: 'T',
  base: UnitBaseStats(
    maxHp: 100,
    atk: 10,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 100,
    moveSpeed: 0,
  ),
);

BattleEntity _entity() => BattleEntity(id: 1, side: Side.ally, def: _unit, spawnTick: 0, x: 0);

void main() {
  test('never shows more than max icons', () {
    final e = _entity();
    e.tags.add(0, 1);
    e.tags.add(1, 1);
    e.tags.add(2, 1);
    expect(unitTagIcons(e, _registry).length, 2);
  });

  test('active relations take priority over tags', () {
    final e = _entity();
    e.tags.add(0, 1);
    e.relationStates['RULE_X'] = RelationState()..active = true;

    final icons = unitTagIcons(e, _registry);
    expect(icons.length, 2);
    expect(icons.first.isRelation, isTrue);
    expect(icons.first.label, 'RULE_X');
    expect(icons.last.isRelation, isFalse);
    expect(icons.last.label, 'TAG_A');
  });

  test('inactive relations are not shown', () {
    final e = _entity();
    e.relationStates['RULE_X'] = RelationState()..active = false;
    e.tags.add(0, 1);

    final icons = unitTagIcons(e, _registry);
    expect(icons.length, 1);
    expect(icons.single.label, 'TAG_A');
  });

  test('a tag with level 0 (nothing added) never appears', () {
    final e = _entity();
    expect(unitTagIcons(e, _registry), isEmpty);
  });
}
