import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/domain/story/story_beat.dart';
import 'package:wse_defense/presentation/screens/story/story_player_screen.dart';

import 'support/in_memory_journal_store.dart';

const _beats = [
  BgBeat(key: 'bg_a'), // 텍스트 없음 -> 즉시 통과
  LineBeat(speakerKey: 'spk.girl', textKey: 'l1'),
  SfxBeat(key: 'sfx_a'), // 즉시 통과
  LineBeat(textKey: 'l2'), // 내레이션(화자 없음)
];

void main() {
  testWidgets('skips non-LINE beats automatically and shows the first line', (tester) async {
    final journal = InMemoryJournalStore();
    var finished = false;
    await tester.pumpWidget(
      MaterialApp(
        home: StoryPlayerScreen(
          sceneId: 'story.test',
          beats: _beats,
          journalStore: journal,
          onFinished: () => finished = true,
        ),
      ),
    );

    expect(find.text('l1'), findsOneWidget);
    expect(find.text('spk.girl'), findsOneWidget);
    expect(finished, isFalse);
  });

  testWidgets('tapping advances through lines, and finishing registers the scene in the journal', (tester) async {
    final journal = InMemoryJournalStore();
    var finished = false;
    await tester.pumpWidget(
      MaterialApp(
        home: StoryPlayerScreen(
          sceneId: 'story.test',
          beats: _beats,
          journalStore: journal,
          onFinished: () => finished = true,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('story_tap_area')));
    await tester.pump();
    expect(find.text('l2'), findsOneWidget);
    expect(find.byKey(const ValueKey('story_speaker')), findsNothing); // 내레이션 -- 화자 없음
    expect(finished, isFalse); // 아직 마지막 줄이 남아 있었을 뿐, 이제 막 봄

    await tester.tap(find.byKey(const ValueKey('story_tap_area')));
    await tester.pump();

    expect(finished, isTrue);
    expect(journal.unlockedSceneIds, contains('story.test'));
  });

  testWidgets('skipping immediately registers the scene, without reading every line', (tester) async {
    final journal = InMemoryJournalStore();
    var finished = false;
    await tester.pumpWidget(
      MaterialApp(
        home: StoryPlayerScreen(
          sceneId: 'story.test',
          beats: _beats,
          journalStore: journal,
          onFinished: () => finished = true,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('story_skip')));
    await tester.pump();

    expect(finished, isTrue);
    expect(journal.unlockedSceneIds, contains('story.test'));
  });
}
