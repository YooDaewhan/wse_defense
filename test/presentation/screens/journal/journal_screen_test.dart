import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/presentation/screens/journal/journal_screen.dart';

/// 10_WIRING_PLAN.md T-63.
void main() {
  testWidgets('shows an empty hint when nothing is unlocked yet', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: JournalScreen(unlockedSceneIds: const {}, onReplayTap: (_) {})),
    );

    expect(find.byKey(const ValueKey('journal_empty')), findsOneWidget);
  });

  testWidgets('tapping replay on an unlocked scene reports its id', (tester) async {
    String? replayed;
    await tester.pumpWidget(
      MaterialApp(
        home: JournalScreen(
          unlockedSceneIds: const {'story.prologue'},
          onReplayTap: (sceneId) => replayed = sceneId,
        ),
      ),
    );

    expect(find.byKey(const ValueKey('journal_scene_story.prologue')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('journal_replay_story.prologue')));
    await tester.pump();

    expect(replayed, 'story.prologue');
  });
}
