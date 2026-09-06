import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/presentation/screens/settings/settings_screen.dart';

import '../../../data/local/support/in_memory_settings_store.dart';

/// 10_WIRING_PLAN.md T-63: 저장 버튼 없이 즉시 SettingsStore에 반영되는지
/// 확인한다.
void main() {
  testWidgets('changing battle speed writes through to the store immediately', (tester) async {
    final store = InMemorySettingsStore();
    await tester.pumpWidget(MaterialApp(home: SettingsScreen(store: store)));

    await tester.tap(find.byKey(const ValueKey('settings_battle_speed_2')));
    await tester.pump();

    expect(store.battleSpeed, 2);
  });

  testWidgets('toggling skip-story writes through to the store immediately', (tester) async {
    final store = InMemorySettingsStore();
    await tester.pumpWidget(MaterialApp(home: SettingsScreen(store: store)));

    await tester.tap(find.byKey(const ValueKey('settings_skip_story')));
    await tester.pump();

    expect(store.skipStory, isTrue);
  });

  testWidgets('changing locale writes through to the store immediately', (tester) async {
    final store = InMemorySettingsStore();
    await tester.pumpWidget(MaterialApp(home: SettingsScreen(store: store)));

    await tester.tap(find.byKey(const ValueKey('settings_locale')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    expect(store.locale, 'en');
  });

  testWidgets('dragging the bgm volume slider writes through to the store', (tester) async {
    final store = InMemorySettingsStore();
    await tester.pumpWidget(MaterialApp(home: SettingsScreen(store: store)));

    await tester.drag(find.byKey(const ValueKey('settings_bgm_volume')), const Offset(-200, 0));
    await tester.pump();

    expect(store.bgmVolume, lessThan(1.0));
  });
}
