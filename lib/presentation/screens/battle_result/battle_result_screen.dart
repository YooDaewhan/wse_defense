import 'package:flutter/material.dart';

import '../../../battle/constants.dart';
import '../../../game/battle_result.dart';

/// game_design_final.md §7 "패배 화면" + 09_MILESTONES.md T-26.
/// 보상 지급 모델(T-42/T-48 스코프)이 아직 없어 승리 시 보상 칸은
/// 자리만 잡아둔다.
class BattleResultScreen extends StatelessWidget {
  const BattleResultScreen({super.key, required this.result});

  final BattleResultSummary result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.isWin ? '승리!' : '패배',
                key: const ValueKey('result_title'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              _Stats(result: result),
              if (result.isWin) ...[
                const SizedBox(height: 16),
                const Text('보상: 지급 준비 중', key: ValueKey('reward_placeholder')),
              ] else ...[
                const SizedBox(height: 16),
                _CollapseInfo(result: result),
                const SizedBox(height: 8),
                _MainEnemyInfo(result: result),
                const SizedBox(height: 8),
                _FormationUsed(result: result),
                if (result.hints.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _Hints(hints: result.hints),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.result});
  final BattleResultSummary result;

  @override
  Widget build(BuildContext context) => Text(
    '클리어 시간 ${result.clearSec.toStringAsFixed(1)}초 · 소환 ${result.summons} · 처치 ${result.kills}',
    key: const ValueKey('battle_stats'),
  );
}

class _CollapseInfo extends StatelessWidget {
  const _CollapseInfo({required this.result});
  final BattleResultSummary result;

  @override
  Widget build(BuildContext context) {
    final tick = result.frontlineCollapseTick;
    final label = tick == null
        ? '전선 붕괴: 없음'
        : '전선 붕괴 시점: ${(tick / ticksPerSec).toStringAsFixed(1)}초';
    return Text(label, key: const ValueKey('frontline_collapse'));
  }
}

class _MainEnemyInfo extends StatelessWidget {
  const _MainEnemyInfo({required this.result});
  final BattleResultSummary result;

  @override
  Widget build(BuildContext context) {
    final enemy = result.mainEnemy;
    return Text(
      enemy == null ? '주요 적: 없음' : '주요 적: ${enemy.nameKey}',
      key: const ValueKey('main_enemy'),
    );
  }
}

class _FormationUsed extends StatelessWidget {
  const _FormationUsed({required this.result});
  final BattleResultSummary result;

  @override
  Widget build(BuildContext context) => Wrap(
    key: const ValueKey('formation_used'),
    spacing: 8,
    children: [
      for (final def in result.formationUsed) Chip(label: Text(def.nameKey)),
    ],
  );
}

class _Hints extends StatelessWidget {
  const _Hints({required this.hints});
  final List<String> hints;

  @override
  Widget build(BuildContext context) => Column(
    key: const ValueKey('hints'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [for (final h in hints) Text('- $h')],
  );
}
