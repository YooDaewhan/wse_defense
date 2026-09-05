import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/domain/tutorial/tutorial_gate.dart';
import 'package:wse_defense/domain/tutorial/tutorial_step.dart';
import 'package:wse_defense/presentation/screens/tutorial/tutorial_overlay.dart';

Future<void> _pump(WidgetTester tester, TutorialStep? step) => tester.pumpWidget(
  MaterialApp(home: Scaffold(body: Stack(children: [TutorialOverlay(step: step)]))),
);

void main() {
  testWidgets('shows nothing once the tutorial is complete (step == null)', (tester) async {
    await _pump(tester, null);
    expect(find.byKey(const ValueKey('tutorial_overlay')), findsNothing);
  });

  testWidgets('shows the step text, and only the highlight/pause labels that apply', (tester) async {
    const step = TutorialStep(id: 'T1', textKey: 'tut.1', highlight: 'PRAYER_GAUGE', gate: PrayerAtLeastGate(75), pauseSim: true);
    await _pump(tester, step);

    expect(find.text('tut.1'), findsOneWidget);
    expect(find.byKey(const ValueKey('tutorial_highlight')), findsOneWidget);
    expect(find.byKey(const ValueKey('tutorial_paused')), findsOneWidget);
  });

  testWidgets('a step with no highlight and no pause omits both labels', (tester) async {
    const step = TutorialStep(id: 'T7', textKey: 'tut.7', gate: RewardClaimedGate());
    await _pump(tester, step);

    expect(find.text('tut.7'), findsOneWidget);
    expect(find.byKey(const ValueKey('tutorial_highlight')), findsNothing);
    expect(find.byKey(const ValueKey('tutorial_paused')), findsNothing);
  });
}
