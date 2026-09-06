import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/presentation/screens/character_detail/character_list_screen.dart';

const _acorn = UnitDef(
  id: 'CHR_ACORN',
  nameKey: 'chr.acorn',
  base: UnitBaseStats(summonCost: 75, maxHp: 1200, atk: 90, attackPeriod: 60, attackWindup: 12, attackRecover: 48, attackRange: 130, moveSpeed: 100),
);

void main() {
  testWidgets('shows an empty hint with no owned characters', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CharacterListScreen(
          ownedCharacterIds: const {},
          datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
          onCharacterTap: (_) {},
        ),
      ),
    );

    expect(find.byKey(const ValueKey('friends_empty')), findsOneWidget);
  });

  testWidgets('tapping an owned character reports its id', (tester) async {
    String? tapped;
    await tester.pumpWidget(
      MaterialApp(
        home: CharacterListScreen(
          ownedCharacterIds: const {'CHR_ACORN'},
          datapack: const Datapack(characters: {'CHR_ACORN': _acorn}, enemies: {}, stages: {}),
          onCharacterTap: (id) => tapped = id,
        ),
      ),
    );

    expect(find.text('chr.acorn'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('friends_card_CHR_ACORN')));
    await tester.pump();

    expect(tapped, 'CHR_ACORN');
  });
}
