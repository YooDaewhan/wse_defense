import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/tag/tag_registry.dart';
import 'package:wse_defense/data/tag/tag_data_loader.dart';
import 'package:wse_defense/domain/exchange/equipment_def.dart';
import 'package:wse_defense/domain/exchange/exchange_def.dart';
import 'package:wse_defense/presentation/screens/exchange/exchange_screen.dart';

const _mask = EquipmentDef(
  id: 'EQP_ANIMAL_MASK',
  nameKey: 'eqp.animal_mask',
  originDungeonId: 'DGN_SUN',
  grantTagId: 'TAG_RACE_ANIMAL',
  grantTagBaseLevel: 1,
  tagBonusAtEnhance5: true,
);

const _config = ExchangeConfig(
  upgrades: [
    ExchangeEntryDef(
      id: 'UPG_SUN_T1_T2',
      cost: [CostEntry(item: 'ITM_SHARD_SUN_T1', amount: 5)],
      gain: GainDef(type: 'ITEM', id: 'ITM_SHARD_SUN_T2'),
    ),
  ],
  shops: [
    ShopDef(
      id: 'SHOP_DUNGEON_SUN',
      nameKey: 'shop.dungeon.sun',
      entries: [
        ExchangeEntryDef(
          id: 'EX_ANIMAL_MASK',
          cost: [CostEntry(item: 'ITM_SHARD_SUN_T3', amount: 10)],
          gain: GainDef(type: 'EQUIPMENT', id: 'EQP_ANIMAL_MASK'),
        ),
      ],
    ),
  ],
);

void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// 09_MILESTONES.md T-43 완료조건: "장비 카드에 부여 태그가 가장 크게
/// 표시되고, 현재 편성 기준 '팀 태그 4→5' 안내".
///
/// `loadTagBundle`(실제 파일 I/O)은 반드시 `setUpAll`에서 한 번만 부른다 —
/// `testWidgets` 본문 안에서 직접 `await`하면 이 환경에서 원인 불명으로
/// 영영 멈춘다(T-31에서 Hive로 겪은 것과 같은 종류의 문제를 파일 I/O에서도
/// 겪음 — formation_screen_test.dart의 해결책을 그대로 따름).
void main() {
  late TagRegistry registry;

  setUpAll(() async {
    final bundle = await loadTagBundle((path) => File('assets/data/v1/$path').readAsString());
    registry = bundle.registry;
  });

  testWidgets('shows held shard counts and the equipment\'s granted tag prominently', (tester) async {
    _useTallSurface(tester);

    await tester.pumpWidget(
      MaterialApp(
        home: ExchangeScreen(
          config: _config,
          equipmentById: const {'EQP_ANIMAL_MASK': _mask},
          heldItems: const {'ITM_SHARD_SUN_T3': 4},
          formationTagLevels: const {'TAG_RACE_ANIMAL': 4},
          registry: registry,
          onExchange: (_) {},
          onUpgrade: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SUNT3 4'), findsOneWidget);
    expect(find.byKey(const ValueKey('exchange_tag_label_EX_ANIMAL_MASK')), findsOneWidget);
    expect(find.text('TAG_RACE_ANIMAL'), findsOneWidget);
  });

  testWidgets('T-44: shows the +5 tag-bonus hint in advance, before any enhancement happens', (tester) async {
    _useTallSurface(tester);

    await tester.pumpWidget(
      MaterialApp(
        home: ExchangeScreen(
          config: _config,
          equipmentById: const {'EQP_ANIMAL_MASK': _mask},
          heldItems: const {},
          formationTagLevels: const {},
          registry: registry,
          onExchange: (_) {},
          onUpgrade: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('+5 강화 시 TAG_RACE_ANIMAL 태그 +1 추가 부여'), findsOneWidget);
  });

  testWidgets('tapping the card reveals the "team tag 4 -> 5" preview', (tester) async {
    _useTallSurface(tester);

    await tester.pumpWidget(
      MaterialApp(
        home: ExchangeScreen(
          config: _config,
          equipmentById: const {'EQP_ANIMAL_MASK': _mask},
          heldItems: const {},
          formationTagLevels: const {'TAG_RACE_ANIMAL': 4},
          registry: registry,
          onExchange: (_) {},
          onUpgrade: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('exchange_tag_preview_EX_ANIMAL_MASK')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('exchange_entry_EX_ANIMAL_MASK')));
    await tester.pumpAndSettle();

    expect(find.text('이 장비를 장착하면 팀 TAG_RACE_ANIMAL 레벨이 4 → 5가 됩니다.'), findsOneWidget);
  });

  testWidgets('the exchange button invokes onExchange with the tapped entry', (tester) async {
    _useTallSurface(tester);
    ExchangeEntryDef? exchanged;

    await tester.pumpWidget(
      MaterialApp(
        home: ExchangeScreen(
          config: _config,
          equipmentById: const {'EQP_ANIMAL_MASK': _mask},
          heldItems: const {},
          formationTagLevels: const {},
          registry: registry,
          onExchange: (entry) => exchanged = entry,
          onUpgrade: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('exchange_button_EX_ANIMAL_MASK')));
    await tester.pumpAndSettle();

    expect(exchanged?.id, 'EX_ANIMAL_MASK');
  });

  testWidgets('the upgrade button invokes onUpgrade with the tapped upgrade', (tester) async {
    _useTallSurface(tester);
    ExchangeEntryDef? upgraded;

    await tester.pumpWidget(
      MaterialApp(
        home: ExchangeScreen(
          config: _config,
          equipmentById: const {'EQP_ANIMAL_MASK': _mask},
          heldItems: const {},
          formationTagLevels: const {},
          registry: registry,
          onExchange: (_) {},
          onUpgrade: (upgrade) => upgraded = upgrade,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('exchange_upgrade_UPG_SUN_T1_T2')));
    await tester.pumpAndSettle();

    expect(upgraded?.id, 'UPG_SUN_T1_T2');
  });
}
