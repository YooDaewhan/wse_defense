import 'dungeon_def.dart';

/// 화면이 해금 여부를 판정하는 데 필요한 진행도 — 실제 값은 서버 계정
/// 미러(progress.clearedStages/chapterUnlocked)에서 채워진다. 여기서는
/// 순수하게 판정 로직만 다룬다.
class DungeonProgressSnapshot {
  const DungeonProgressSnapshot({
    this.clearedStageIds = const {},
    this.clearedChapterIds = const {},
    this.dungeonDifficultyCleared = const {},
  });

  final Set<String> clearedStageIds;
  final Set<String> clearedChapterIds;

  /// dungeonId -> 그 던전에서 클리어한 최고 난이도(0 = 아직 없음).
  final Map<String, int> dungeonDifficultyCleared;
}

/// 07_DUNGEON_EXCHANGE.md §3 해금 조건 — `unlock`의 필드는 전부 AND.
bool isDungeonDifficultyUnlocked(
  String dungeonId,
  DungeonDifficultyDef difficulty,
  DungeonProgressSnapshot progress,
) {
  final unlock = difficulty.unlock;
  if (unlock == null) return true;

  if (unlock.stageCleared != null && !progress.clearedStageIds.contains(unlock.stageCleared)) {
    return false;
  }
  if (unlock.difficultyCleared != null &&
      (progress.dungeonDifficultyCleared[dungeonId] ?? 0) < unlock.difficultyCleared!) {
    return false;
  }
  if (unlock.chapterCleared != null && !progress.clearedChapterIds.contains(unlock.chapterCleared)) {
    return false;
  }
  return true;
}
