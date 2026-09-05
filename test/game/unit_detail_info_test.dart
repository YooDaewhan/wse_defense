import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/entity/battle_entity.dart';
import 'package:wse_defense/battle/stat/modifier.dart';
import 'package:wse_defense/battle/stat/modifier_source.dart';
import 'package:wse_defense/battle/stat/stat_key.dart';
import 'package:wse_defense/battle/tag/tag_def.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/tag/tag_registry.dart';
import 'package:wse_defense/game/tags/unit_detail_info.dart';

final _registry = TagRegistry(const [
  TagDef(id: 'TAG_A', category: TagCategory.trait),
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
  test('lists every active tag with its level', () {
    final e = _entity();
    e.tags.add(0, 3);
    final info = unitDetailInfo(e, _registry);

    expect(info.tags, hasLength(1));
    expect(info.tags.single.tagId, 'TAG_A');
    expect(info.tags.single.level, 3);
  });

  test('lists every stat modifier with its source', () {
    final e = _entity();
    e.stats.addModifier(
      const StatModifier(
        stat: StatKey.atk,
        op: ModOp.pctAdd,
        value: 15000,
        source: ModifierSource(ModifierKind.tagUnit, 'TEF_STRONG'),
      ),
    );
    final info = unitDetailInfo(e, _registry);

    expect(info.modifiers, hasLength(1));
    final row = info.modifiers.single;
    expect(row.stat, 'atk');
    expect(row.value, 15000);
    expect(row.sourceLabel, 'tagUnit:TEF_STRONG');
  });

  test('no tags/modifiers -> empty lists, not crashes', () {
    final info = unitDetailInfo(_entity(), _registry);
    expect(info.tags, isEmpty);
    expect(info.modifiers, isEmpty);
  });
}
