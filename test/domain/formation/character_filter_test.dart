import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/domain/formation/character_filter.dart';

const _acorn = UnitDef(
  id: 'CHR_ACORN',
  role: 'ROLE_DEFENDER',
  intrinsicTags: {'TAG_TEMPER_FIELD': 1, 'TAG_RACE_PLANT': 1},
  base: UnitBaseStats(
    maxHp: 100,
    atk: 10,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 100,
    moveSpeed: 0,
    damageType: 'PHYSICAL',
    attackReach: 'MELEE',
  ),
);

const _droplet = UnitDef(
  id: 'CHR_DROPLET',
  role: 'ROLE_ATTACKER',
  intrinsicTags: {'TAG_TEMPER_MOON': 1, 'TAG_ELEM_WATER': 1},
  base: UnitBaseStats(
    maxHp: 100,
    atk: 10,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 100,
    moveSpeed: 0,
    damageType: 'MAGICAL',
    attackReach: 'RANGED',
  ),
);

void main() {
  test('no filters set -> everything matches', () {
    const filter = CharacterFilter();
    expect(filter.isEmpty, isTrue);
    expect(filter.matches(_acorn), isTrue);
    expect(filter.matches(_droplet), isTrue);
  });

  test('role filter only affects role', () {
    const filter = CharacterFilter(roles: {'ROLE_DEFENDER'});
    expect(filter.matches(_acorn), isTrue);
    expect(filter.matches(_droplet), isFalse);
  });

  test('damage type filter is independent of role filter', () {
    const filter = CharacterFilter(damageTypes: {'MAGICAL'});
    expect(filter.matches(_acorn), isFalse);
    expect(filter.matches(_droplet), isTrue);
  });

  test('attack reach filter', () {
    const filter = CharacterFilter(attackReaches: {'MELEE'});
    expect(filter.matches(_acorn), isTrue);
    expect(filter.matches(_droplet), isFalse);
  });

  test('temper filter matches by intrinsic tag id', () {
    const filter = CharacterFilter(tempers: {'TAG_TEMPER_MOON'});
    expect(filter.matches(_acorn), isFalse);
    expect(filter.matches(_droplet), isTrue);
  });

  test('combining two categories applies both (AND across categories)', () {
    const filter = CharacterFilter(roles: {'ROLE_DEFENDER'}, damageTypes: {'MAGICAL'});
    // 도토리는 역할은 맞지만 속성이 다르고, 물방울은 속성은 맞지만 역할이 다름 -> 둘 다 탈락
    expect(filter.matches(_acorn), isFalse);
    expect(filter.matches(_droplet), isFalse);
  });

  test('multiple values within one category are OR-ed', () {
    const filter = CharacterFilter(roles: {'ROLE_DEFENDER', 'ROLE_ATTACKER'});
    expect(filter.matches(_acorn), isTrue);
    expect(filter.matches(_droplet), isTrue);
  });

  test('changing one filter category does not affect another (independence)', () {
    const base = CharacterFilter(roles: {'ROLE_DEFENDER'});
    final withTraits = base.copyWith(traits: {'TAG_TRAIT_HERD'});
    expect(withTraits.roles, base.roles); // role 필터는 그대로 유지됨
  });
}
