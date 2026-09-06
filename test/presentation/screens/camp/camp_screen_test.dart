import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/domain/account/account_state.dart';
import 'package:wse_defense/presentation/screens/camp/camp_screen.dart';

const _account = AccountState(gold: 1234, ownedCharacterIds: {'CHR_ACORN'}, bondLevel: 2, focusLevel: 3, campLevel: 4);

Widget _buildScreen({void Function(String tapped)? onTap}) {
  void report(String id) => onTap?.call(id);
  return MaterialApp(
    home: CampScreen(
      account: _account,
      onAdventureTap: () => report('adventure'),
      onFormationTap: () => report('formation'),
      onSummonTap: () => report('summon'),
      onDungeonTap: () => report('dungeon'),
      onExchangeTap: () => report('exchange'),
      onInventoryTap: () => report('inventory'),
      onMailTap: () => report('mail'),
      onJournalTap: () => report('journal'),
      onSettingsTap: () => report('settings'),
    ),
  );
}

/// 10_WIRING_PLAN.md T-58 완료조건: "재화(금화, 기도력 관련 표시) +
/// 동행/집중력/캠프 레벨을 AccountState에서 읽어 표시, 9개 화면 진입 동선".
void main() {
  testWidgets('shows gold and the three growth levels from AccountState', (tester) async {
    await tester.pumpWidget(_buildScreen());

    expect(find.text('금화 1234'), findsOneWidget);
    expect(find.text('동행 Lv.2'), findsOneWidget);
    expect(find.textContaining('집중력 Lv.3'), findsOneWidget);
    expect(find.text('캠프 방어 Lv.4'), findsOneWidget);
  });

  testWidgets('every destination button invokes its own callback', (tester) async {
    final tapped = <String>[];
    await tester.pumpWidget(_buildScreen(onTap: tapped.add));

    const destinations = [
      'adventure', 'formation', 'summon', 'dungeon', 'exchange', 'inventory', 'mail', 'journal', 'settings',
    ];
    for (final id in destinations) {
      await tester.tap(find.byKey(ValueKey('camp_nav_$id')));
    }

    expect(tapped, destinations);
  });
}
