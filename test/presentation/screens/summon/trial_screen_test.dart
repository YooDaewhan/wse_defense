import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/presentation/screens/summon/trial_screen.dart';

/// 09_MILESTONES.md T-51 완료조건: "미보유 픽업 캐릭터를 지정 레벨로 사용,
/// 보상 없음, 진행도 영향 없음".
void main() {
  testWidgets('shows the trial character id and invokes onStartTrial when tapped', (tester) async {
    bool started = false;

    await tester.pumpWidget(
      MaterialApp(
        home: TrialScreen(characterId: 'CHR_BEAR', onStartTrial: () => started = true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CHR_BEAR'), findsOneWidget);
    expect(find.textContaining('보상은 없고'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('trial_start_button')));
    await tester.pumpAndSettle();

    expect(started, true);
  });
}
