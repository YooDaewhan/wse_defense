import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/game/hud/summon_slot_status.dart';
import 'package:wse_defense/presentation/screens/battle/widgets/summon_slot_widget.dart';

Future<void> _pump(WidgetTester tester, Widget child) =>
    tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(child: child))));

void main() {
  testWidgets('ready: plain cost text, no overlay markers, full opacity', (tester) async {
    await _pump(
      tester,
      SummonSlotWidget(status: SummonSlotStatus.ready, cost: 75, onTap: () {}),
    );

    expect(find.text('75'), findsOneWidget);
    expect(find.byKey(const ValueKey('locked_icon')), findsNothing);
    expect(find.byKey(const ValueKey('cap_badge')), findsNothing);
    expect(find.byKey(const ValueKey('cooldown_overlay')), findsNothing);
    expect(find.byKey(const ValueKey('wait_seconds')), findsNothing);
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1.0);
  });

  testWidgets('notEnoughPrayer: dimmed, red cost, wait-seconds shown', (tester) async {
    await _pump(
      tester,
      SummonSlotWidget(status: SummonSlotStatus.notEnoughPrayer, cost: 200, waitSecLeft: 12, onTap: () {}),
    );

    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, lessThan(1.0));
    final costText = tester.widget<Text>(find.text('200'));
    expect(costText.style?.color, Colors.red);
    expect(find.byKey(const ValueKey('wait_seconds')), findsOneWidget);
    expect(find.text('12s'), findsOneWidget);
  });

  testWidgets('onCooldown: circular overlay + remaining seconds', (tester) async {
    await _pump(
      tester,
      SummonSlotWidget(
        status: SummonSlotStatus.onCooldown,
        cost: 75,
        cooldownSecLeft: 3,
        cooldownFraction: 0.4,
        onTap: () {},
      ),
    );

    expect(find.byKey(const ValueKey('cooldown_overlay')), findsOneWidget);
    expect(find.byKey(const ValueKey('cooldown_seconds')), findsOneWidget);
    expect(find.text('3s'), findsOneWidget);
  });

  testWidgets('unitCapReached: "가득" badge', (tester) async {
    await _pump(
      tester,
      SummonSlotWidget(status: SummonSlotStatus.unitCapReached, cost: 75, onTap: () {}),
    );

    expect(find.byKey(const ValueKey('cap_badge')), findsOneWidget);
    expect(find.text('가득'), findsOneWidget);
  });

  testWidgets('costExceedsCap: lock icon', (tester) async {
    await _pump(
      tester,
      SummonSlotWidget(status: SummonSlotStatus.costExceedsCap, cost: 900, onTap: () {}),
    );

    expect(find.byKey(const ValueKey('locked_icon')), findsOneWidget);
  });

  testWidgets('tapping the slot invokes onTap', (tester) async {
    var tapped = false;
    await _pump(
      tester,
      SummonSlotWidget(status: SummonSlotStatus.ready, cost: 75, onTap: () => tapped = true),
    );
    await tester.tap(find.byType(SummonSlotWidget));
    expect(tapped, isTrue);
  });
}
