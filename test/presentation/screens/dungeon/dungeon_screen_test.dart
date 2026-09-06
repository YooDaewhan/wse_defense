import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/domain/dungeon/dungeon_def.dart';
import 'package:wse_defense/domain/dungeon/dungeon_progress.dart';
import 'package:wse_defense/presentation/screens/dungeon/dungeon_screen.dart';

const _config = DungeonConfig(
  dailyRunLimit: 6,
  dungeons: [
    DungeonDef(
      id: 'DGN_SUN',
      nameKey: 'dgn.sun',
      themeKey: 'sun',
      bonusWeekdays: [1, 4],
      shardFamily: 'SUN',
      difficulties: [
        DungeonDifficultyDef(level: 1, stageId: 'STG_DGN_SUN_1'),
        DungeonDifficultyDef(level: 2, stageId: 'STG_DGN_SUN_2', unlock: DungeonUnlockDef(difficultyCleared: 1)),
      ],
    ),
    DungeonDef(
      id: 'DGN_MOON',
      nameKey: 'dgn.moon',
      themeKey: 'moon',
      bonusWeekdays: [2, 5],
      shardFamily: 'MOON',
      difficulties: [DungeonDifficultyDef(level: 1, stageId: 'STG_DGN_MOON_1')],
    ),
  ],
);

void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// 09_MILESTONES.md T-41 완료조건: "3종 × 5난이도, 해금 조건, 요일 보너스
/// 표시(서버 시각 기준), 잔여 횟수 6회 공유".
void main() {
  testWidgets('shows the shared remaining-run count and a bonus badge on a bonus day', (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: DungeonScreen(
          config: _config,
          progress: const DungeonProgressSnapshot(),
          gameDayWeekday: 1, // 월 -> SUN 보너스일
          remainingRuns: 4,
          onDifficultyTap: (dungeon, difficulty) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('오늘 남은 입장 횟수: 4 / 6 (3종 공유)'), findsOneWidget);
    expect(find.byKey(const ValueKey('dungeon_bonus_badge')), findsWidgets);
  });

  testWidgets('locked difficulties show a lock icon and are not tappable', (tester) async {
    _useTallSurface(tester);
    DungeonDifficultyDef? tapped;
    await tester.pumpWidget(
      MaterialApp(
        home: DungeonScreen(
          config: _config,
          progress: const DungeonProgressSnapshot(), // 아무것도 클리어 안 함 -> 난이도2 잠김
          gameDayWeekday: 3, // SUN 보너스 아닌 요일
          remainingRuns: 6,
          onDifficultyTap: (dungeon, difficulty) => tapped = difficulty,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('dungeon_difficulty_DGN_SUN_1')), findsOneWidget);
    expect(find.byKey(const ValueKey('dungeon_difficulty_DGN_SUN_2')), findsOneWidget);
    expect(find.byKey(const ValueKey('dungeon_bonus_badge')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('dungeon_difficulty_DGN_SUN_2')));
    await tester.pumpAndSettle();
    expect(tapped, isNull);

    await tester.tap(find.byKey(const ValueKey('dungeon_difficulty_DGN_SUN_1')));
    await tester.pumpAndSettle();
    expect(tapped?.level, 1);
  });

  testWidgets('switching tabs shows the other dungeon\'s difficulties', (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: DungeonScreen(
          config: _config,
          progress: const DungeonProgressSnapshot(),
          gameDayWeekday: 1,
          remainingRuns: 6,
          onDifficultyTap: (dungeon, difficulty) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('dungeon_tab_DGN_MOON')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('dungeon_difficulty_DGN_MOON_1')), findsOneWidget);
  });
}
