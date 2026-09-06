import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/domain/exchange/equipment_def.dart';
import 'package:wse_defense/domain/exchange/equipment_instance.dart';
import 'package:wse_defense/presentation/screens/character_detail/character_detail_screen.dart';

const _acorn = UnitDef(
  id: 'CHR_ACORN',
  nameKey: 'chr.acorn',
  role: 'ROLE_DEFENDER',
  intrinsicTags: {'TAG_RACE_ANIMAL': 1},
  base: UnitBaseStats(summonCost: 75, maxHp: 1200, atk: 90, def: 20, attackPeriod: 60, attackWindup: 12, attackRecover: 48, attackRange: 130, moveSpeed: 100),
);

const _mask = EquipmentDef(id: 'EQP_ANIMAL_MASK', nameKey: 'eqp.animal_mask', originDungeonId: 'DGN_SUN');

void main() {
  testWidgets('shows stats, tags, and an unequip button when equipped', (tester) async {
    String? equipTapped = 'not called';
    await tester.pumpWidget(
      MaterialApp(
        home: CharacterDetailScreen(
          character: _acorn,
          equipmentById: const {'EQP_ANIMAL_MASK': _mask},
          equippedInstance: const EquipmentInstance(id: 'inst-1', equipmentId: 'EQP_ANIMAL_MASK', enhanceLevel: 2, equippedTo: 'CHR_ACORN'),
          unequippedInstances: const [],
          onEquipTap: (id) => equipTapped = id,
        ),
      ),
    );

    expect(find.text('역할: ROLE_DEFENDER'), findsOneWidget);
    expect(find.byKey(const ValueKey('character_tag_TAG_RACE_ANIMAL')), findsOneWidget);
    expect(find.text('HP 1200 / 공격력 90 / 방어력 20'), findsOneWidget);
    expect(find.text('eqp.animal_mask'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('character_unequip')));
    await tester.pump();

    expect(equipTapped, isNull);
  });

  testWidgets('tapping an equip candidate reports its instance id', (tester) async {
    String? equipped;
    await tester.pumpWidget(
      MaterialApp(
        home: CharacterDetailScreen(
          character: _acorn,
          equipmentById: const {'EQP_ANIMAL_MASK': _mask},
          equippedInstance: null,
          unequippedInstances: const [EquipmentInstance(id: 'inst-2', equipmentId: 'EQP_ANIMAL_MASK', enhanceLevel: 0, equippedTo: null)],
          onEquipTap: (id) => equipped = id,
        ),
      ),
    );

    expect(find.text('미장착'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('character_equip_inst-2')));
    await tester.pump();

    expect(equipped, 'inst-2');
  });
}
