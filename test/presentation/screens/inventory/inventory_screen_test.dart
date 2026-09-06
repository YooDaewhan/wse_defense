import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/domain/exchange/equipment_def.dart';
import 'package:wse_defense/domain/exchange/equipment_instance.dart';
import 'package:wse_defense/presentation/screens/inventory/inventory_screen.dart';

const _mask = EquipmentDef(id: 'EQP_ANIMAL_MASK', nameKey: 'eqp.animal_mask', originDungeonId: 'DGN_SUN');

void main() {
  testWidgets('shows an empty hint with no equipment', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: InventoryScreen(instances: [], equipmentById: {}, onEnhanceTap: _noop)),
    );

    expect(find.byKey(const ValueKey('inventory_empty')), findsOneWidget);
  });

  testWidgets('tapping enhance below the max level reports the instance id', (tester) async {
    String? enhanced;
    const instance = EquipmentInstance(id: 'inst-1', equipmentId: 'EQP_ANIMAL_MASK', enhanceLevel: 3, equippedTo: null);
    await tester.pumpWidget(
      MaterialApp(
        home: InventoryScreen(
          instances: const [instance],
          equipmentById: const {'EQP_ANIMAL_MASK': _mask},
          onEnhanceTap: (id) => enhanced = id,
        ),
      ),
    );

    expect(find.text('eqp.animal_mask'), findsOneWidget);
    expect(find.text('+3 (미장착)'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('inventory_enhance_inst-1')));
    await tester.pump();

    expect(enhanced, 'inst-1');
  });

  testWidgets('an equipment at the max enhance level has a disabled button', (tester) async {
    const instance = EquipmentInstance(id: 'inst-2', equipmentId: 'EQP_ANIMAL_MASK', enhanceLevel: 10, equippedTo: 'CHR_BEAR');
    await tester.pumpWidget(
      const MaterialApp(
        home: InventoryScreen(instances: [instance], equipmentById: {'EQP_ANIMAL_MASK': _mask}, onEnhanceTap: _noop),
      ),
    );

    expect(find.text('+10 (CHR_BEAR 장착 중)'), findsOneWidget);
    final button = tester.widget<ElevatedButton>(find.byKey(const ValueKey('inventory_enhance_inst-2')));
    expect(button.onPressed, isNull);
  });
}

void _noop(String id) {}
