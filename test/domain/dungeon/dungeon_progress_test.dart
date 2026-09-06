import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/domain/dungeon/dungeon_def.dart';
import 'package:wse_defense/domain/dungeon/dungeon_progress.dart';

const _difficulty1 = DungeonDifficultyDef(
  level: 1,
  stageId: 'STG_DGN_SUN_1',
  unlock: DungeonUnlockDef(stageCleared: 'STG_1_3'),
);

const _difficulty3 = DungeonDifficultyDef(
  level: 3,
  stageId: 'STG_DGN_SUN_3',
  unlock: DungeonUnlockDef(difficultyCleared: 2, chapterCleared: 'CH_1'),
);

/// 09_MILESTONES.md T-41 완료조건: "해금 조건".
void main() {
  test('a difficulty with no unlock condition is always unlocked', () {
    const difficulty = DungeonDifficultyDef(level: 1, stageId: 'x');
    expect(isDungeonDifficultyUnlocked('DGN_SUN', difficulty, const DungeonProgressSnapshot()), isTrue);
  });

  test('stageCleared unlock requires that exact stage in progress', () {
    expect(isDungeonDifficultyUnlocked('DGN_SUN', _difficulty1, const DungeonProgressSnapshot()), isFalse);
    expect(
      isDungeonDifficultyUnlocked(
        'DGN_SUN',
        _difficulty1,
        const DungeonProgressSnapshot(clearedStageIds: {'STG_1_3'}),
      ),
      isTrue,
    );
  });

  test('difficultyCleared + chapterCleared unlock requires both (AND)', () {
    const onlyDifficulty = DungeonProgressSnapshot(dungeonDifficultyCleared: {'DGN_SUN': 2});
    const onlyChapter = DungeonProgressSnapshot(clearedChapterIds: {'CH_1'});
    const both = DungeonProgressSnapshot(dungeonDifficultyCleared: {'DGN_SUN': 2}, clearedChapterIds: {'CH_1'});

    expect(isDungeonDifficultyUnlocked('DGN_SUN', _difficulty3, onlyDifficulty), isFalse);
    expect(isDungeonDifficultyUnlocked('DGN_SUN', _difficulty3, onlyChapter), isFalse);
    expect(isDungeonDifficultyUnlocked('DGN_SUN', _difficulty3, both), isTrue);
  });

  test('difficultyCleared is scoped to the same dungeon id', () {
    const wrongDungeonCleared = DungeonProgressSnapshot(
      dungeonDifficultyCleared: {'DGN_MOON': 2},
      clearedChapterIds: {'CH_1'},
    );
    expect(isDungeonDifficultyUnlocked('DGN_SUN', _difficulty3, wrongDungeonCleared), isFalse);
  });
}
