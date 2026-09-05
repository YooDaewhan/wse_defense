import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/entity/battle_entity.dart';
import 'package:wse_defense/battle/entity/entity_store.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';

UnitDef _minimalDef(String id) => UnitDef(
  id: id,
  base: const UnitBaseStats(
    maxHp: 100,
    atk: 10,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 100,
    moveSpeed: 100,
  ),
);

BattleEntity _entity(int id) => BattleEntity(
  id: id,
  side: Side.ally,
  def: _minimalDef('CHR_TEST'),
  spawnTick: 0,
  x: 0,
);

void main() {
  test('iterates entities in ascending entityId order', () {
    final store = EntityStore()
      ..add(_entity(1))
      ..add(_entity(2))
      ..add(_entity(3));

    expect(store.all.map((e) => e.id), [1, 2, 3]);
    expect(store.length, 3);
  });

  test('byId looks up directly; removeById keeps the remaining order intact', () {
    final store = EntityStore()
      ..add(_entity(1))
      ..add(_entity(2))
      ..add(_entity(3));

    expect(store.byId(2)?.id, 2);

    store.removeById(2);

    expect(store.byId(2), isNull);
    expect(store.all.map((e) => e.id), [1, 3]);
    expect(store.length, 2);
  });
}
