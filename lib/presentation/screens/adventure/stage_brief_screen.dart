import 'package:flutter/material.dart';

import '../../../battle/defs/datapack.dart';
import '../../../battle/defs/stage_def.dart';
import '../../../battle/defs/unit_def.dart';

/// 05_FRONTEND.md §2 `/adventure/:stageId/brief`: 적 특징·보스 조건·기믹
/// 사전 표시. "기믹"에 대응하는 전용 데이터 필드가 스키마에 없어(§8),
/// 가장 가까운 사전 정보인 전투 조건(제한시간·목표시간)으로 대신한다.
class StageBriefScreen extends StatelessWidget {
  const StageBriefScreen({super.key, required this.stage, required this.datapack});

  final StageDef stage;
  final Datapack datapack;

  List<UnitDef> get _regularEnemies {
    final ids = <String>{for (final w in stage.waves) w.enemyId};
    return [for (final id in ids) if (datapack.enemyById(id) != null) datapack.enemyById(id)!];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(stage.nameKey.isEmpty ? stage.id : stage.nameKey)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('적 특징', style: TextStyle(fontWeight: FontWeight.bold)),
          if (_regularEnemies.isEmpty)
            const Text('-')
          else
            for (final e in _regularEnemies)
              Text(
                '${e.nameKey.isEmpty ? e.id : e.nameKey} (HP ${e.base.maxHp}, 공격력 ${e.base.atk})',
                key: ValueKey('enemy_feature_${e.id}'),
              ),
          const SizedBox(height: 16),
          const Text('보스 조건', style: TextStyle(fontWeight: FontWeight.bold)),
          if (stage.bossTriggers.isEmpty)
            const Text('-', key: ValueKey('no_boss'))
          else
            for (final b in stage.bossTriggers)
              Text(_bossConditionLabel(b, datapack), key: ValueKey('boss_condition_${b.id}')),
          const SizedBox(height: 16),
          const Text('전투 조건', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('제한시간 ${stage.timeLimitSec}초', key: const ValueKey('time_limit')),
          if (stage.targetClearSec.length >= 2 && stage.targetClearSec.any((s) => s > 0))
            Text(
              '목표 클리어 시간 ${stage.targetClearSec[0]}~${stage.targetClearSec[1]}초',
              key: const ValueKey('target_clear_sec'),
            ),
        ],
      ),
    );
  }

  static String _bossConditionLabel(BossTriggerDef trigger, Datapack datapack) {
    final boss = datapack.enemyById(trigger.enemyId);
    final bossName = boss == null ? trigger.enemyId : (boss.nameKey.isEmpty ? boss.id : boss.nameKey);
    final conditionText = switch (trigger.conditionKind) {
      'NEST_FIRST_HIT' => '둥지 첫 타격 시 등장',
      'TIME' => '일정 시간 경과 시 등장',
      _ => trigger.conditionKind,
    };
    return '$bossName — $conditionText';
  }
}
