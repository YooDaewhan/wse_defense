import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/entity/battle_entity.dart';
import 'package:wse_defense/battle/stat/stat_key.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';

void main() {
  test('hp starts at StatKey.maxHp derived from UnitDef.base', () {
    final entity = BattleEntity(
      id: 1,
      side: Side.ally,
      spawnTick: 0,
      x: 0,
      def: const UnitDef(
        id: 'CHR_ACORN',
        role: 'ROLE_DEFENDER',
        base: UnitBaseStats(
          maxHp: 1200,
          atk: 90,
          attackPeriod: 60,
          attackWindup: 12,
          attackRecover: 48,
          attackRange: 130,
          moveSpeed: 100,
        ),
      ),
    );

    expect(entity.hp, 1200);
    expect(entity.stats.get(StatKey.maxHp), 1200);
    expect(entity.stats.get(StatKey.atk), 90);
    expect(entity.isAlive, isTrue);
  });

  test('TagQueryTarget adapter reflects entity state (role, knockback)', () {
    final entity = BattleEntity(
      id: 2,
      side: Side.enemy,
      spawnTick: 0,
      x: 500,
      def: const UnitDef(
        id: 'ENM_TEST',
        role: 'ROLE_ATTACKER',
        base: UnitBaseStats(
          maxHp: 100,
          atk: 10,
          attackPeriod: 60,
          attackWindup: 12,
          attackRecover: 48,
          attackRange: 100,
          moveSpeed: 100,
        ),
      ),
    );

    expect(entity.role, 'ROLE_ATTACKER');
    expect(entity.posX, 500);
    expect(entity.entityId, 2);
    expect(entity.isKnockback, isFalse);

    entity.knockbackTicksLeft = 5;
    expect(entity.isKnockedBack, isTrue);
    expect(entity.isKnockback, isTrue);
  });
}
