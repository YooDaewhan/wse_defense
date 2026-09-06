import 'package:flutter/material.dart';

import '../../../domain/dungeon/dungeon_bonus.dart';
import '../../../domain/dungeon/dungeon_def.dart';
import '../../../domain/dungeon/dungeon_progress.dart';

/// 05_FRONTEND.md §2 `/dungeon`. 09_MILESTONES.md T-41: "3종 × 5난이도,
/// 해금 조건, 요일 보너스 표시(서버 시각 기준), 잔여 횟수 6회 공유".
/// [gameDayWeekday]는 호출부가 서버 시각(및 dailyResetHourUtc 보정)으로
/// 미리 구해서 넘긴다 — 이 위젯은 로컬 시계를 절대 보지 않는다.
class DungeonScreen extends StatelessWidget {
  const DungeonScreen({
    super.key,
    required this.config,
    required this.progress,
    required this.gameDayWeekday,
    required this.remainingRuns,
    required this.onDifficultyTap,
  });

  final DungeonConfig config;
  final DungeonProgressSnapshot progress;
  final int gameDayWeekday;
  final int remainingRuns;
  final void Function(DungeonDef dungeon, DungeonDifficultyDef difficulty) onDifficultyTap;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: config.dungeons.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('요일던전'),
          bottom: TabBar(
            tabs: [for (final d in config.dungeons) Tab(text: d.nameKey, key: ValueKey('dungeon_tab_${d.id}'))],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                '오늘 남은 입장 횟수: $remainingRuns / ${config.dailyRunLimit} (3종 공유)',
                key: const ValueKey('dungeon_remaining_runs'),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  for (final d in config.dungeons)
                    _DungeonDifficultyList(
                      dungeon: d,
                      progress: progress,
                      gameDayWeekday: gameDayWeekday,
                      onTap: (diff) => onDifficultyTap(d, diff),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DungeonDifficultyList extends StatelessWidget {
  const _DungeonDifficultyList({
    required this.dungeon,
    required this.progress,
    required this.gameDayWeekday,
    required this.onTap,
  });

  final DungeonDef dungeon;
  final DungeonProgressSnapshot progress;
  final int gameDayWeekday;
  final void Function(DungeonDifficultyDef difficulty) onTap;

  @override
  Widget build(BuildContext context) {
    final bonusToday = isBonusDay(gameDayWeekday, dungeon.bonusWeekdays);
    return ListView.builder(
      key: ValueKey('dungeon_list_${dungeon.id}'),
      itemCount: dungeon.difficulties.length,
      itemBuilder: (context, i) {
        final difficulty = dungeon.difficulties[i];
        final unlocked = isDungeonDifficultyUnlocked(dungeon.id, difficulty, progress);
        return ListTile(
          key: ValueKey('dungeon_difficulty_${dungeon.id}_${difficulty.level}'),
          enabled: unlocked,
          leading: Icon(unlocked ? Icons.play_circle_fill : Icons.lock),
          title: Text('난이도 ${difficulty.level}'),
          subtitle: Text('권장 동행Lv ${difficulty.recommendedBondLevel}'),
          trailing: bonusToday
              ? const Chip(label: Text('보너스'), key: ValueKey('dungeon_bonus_badge'))
              : null,
          onTap: unlocked ? () => onTap(difficulty) : null,
        );
      },
    );
  }
}
