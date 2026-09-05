import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/presentation/screens/battle/widgets/prayer_gauge.dart';

void main() {
  testWidgets('draws one tick mark per unaffordable slot cost, positioned proportionally', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: PrayerGauge(current: 200, cap: 1000, tickCosts: [500, 900]),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('prayer_tick_500')), findsOneWidget);
    expect(find.byKey(const ValueKey('prayer_tick_900')), findsOneWidget);

    final gaugeLeft = tester.getTopLeft(find.byType(PrayerGauge)).dx;
    final tick500X = tester.getTopLeft(find.byKey(const ValueKey('prayer_tick_500'))).dx - gaugeLeft;
    final tick900X = tester.getTopLeft(find.byKey(const ValueKey('prayer_tick_900'))).dx - gaugeLeft;

    // 500/1000 = 절반, 900/1000 = 90% 지점 -- 900 눈금이 더 오른쪽에 있어야 한다.
    expect(tick900X, greaterThan(tick500X));
    expect(tick500X, closeTo(400 * 0.5, 5));
    expect(tick900X, closeTo(400 * 0.9, 5));
  });

  testWidgets('no tick marks when every slot is affordable', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: PrayerGauge(current: 1000, cap: 1000)),
      ),
    );
    expect(find.byType(Container).evaluate().where((e) => e.widget.key != null), isEmpty);
  });
}
