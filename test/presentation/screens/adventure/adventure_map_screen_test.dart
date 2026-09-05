import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/presentation/screens/adventure/adventure_map_screen.dart';

List<StageDef> _chapter1() => [
  for (var i = 1; i <= 10; i++)
    StageDef(
      id: 'STG_1_$i',
      index: i,
      nameKey: 'stage.1.$i',
      fieldLength: 2400,
      allyBaseX: 0,
      enemyBaseX: 2400,
      enemyBaseHp: 1000,
      timeLimitSec: 300,
    ),
];

/// `ListView.builder`는 뷰포트+캐시 범위 밖의 항목을 안 만든다 — 기본
/// 테스트 화면(600px)엔 10칸이 다 안 들어가 화면을 넉넉하게 키운다.
void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('shows all 10 chapter-1 stage nodes', (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: AdventureMapScreen(chapterStages: _chapter1(), clearedStageIds: const {}, onStageTap: (_) {}),
      ),
    );

    for (var i = 1; i <= 10; i++) {
      expect(find.byKey(ValueKey('stage_node_STG_1_$i')), findsOneWidget);
    }
  });

  testWidgets('reflects progress: cleared/current/locked icons differ', (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: AdventureMapScreen(
          chapterStages: _chapter1(),
          clearedStageIds: const {'STG_1_1', 'STG_1_2'},
          onStageTap: (_) {},
        ),
      ),
    );

    expect(find.byKey(const ValueKey('stage_status_icon_cleared')), findsNWidgets(2));
    expect(find.byKey(const ValueKey('stage_status_icon_current')), findsOneWidget); // STG_1_3
    expect(find.byKey(const ValueKey('stage_status_icon_locked')), findsNWidgets(7));
  });

  testWidgets('tapping a playable stage invokes the callback, tapping a locked one does not', (tester) async {
    _useTallSurface(tester);
    StageDef? tapped;
    await tester.pumpWidget(
      MaterialApp(
        home: AdventureMapScreen(
          chapterStages: _chapter1(),
          clearedStageIds: const {},
          onStageTap: (s) => tapped = s,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('stage_node_STG_1_1'))); // current -> playable
    await tester.pump();
    expect(tapped?.id, 'STG_1_1');

    tapped = null;
    await tester.tap(find.byKey(const ValueKey('stage_node_STG_1_2'))); // locked
    await tester.pump();
    expect(tapped, isNull);
  });
}
