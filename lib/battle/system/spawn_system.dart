import '../constants.dart';
import '../defs/stage_def.dart';
import '../tag/tag_query.dart';
import '../world/battle_world.dart';
import '../world/spawn_runtime.dart';
import 'battle_system.dart';

/// 03_BATTLE_ENGINE.md §12 + 04_DATA_SCHEMA.md §8: 웨이브 스폰 + 보스 트리거.
///
/// 유닛이 실제로 둥지(enemyBase)에 피해를 주는 경로(AttackSystem이 기지를
/// 표적으로 삼는 것)는 아직 없다 — VictorySystem(T-14)이 "기지 파괴" 승패
/// 조건을 다룰 때 함께 정리한다. 여기서는 `enemyBase.hp`가 maxHp 아래로
/// 떨어지는 것 자체를 "첫 타격" 신호로 본다(누가/어떻게 줄였는지는 안 가림).
///
/// TIME/NEST_HP_BELOW/CAMP_HP_BELOW/ENEMY_KILLED/ALL_WAVES_DONE 조건은
/// `BossTriggerDef`에 파라미터가 아직 없어(04_DATA_SCHEMA.md §8.1) 미구현 —
/// NEST_FIRST_HIT만 이 티켓의 완료 조건이 요구하는 범위다.
///
/// 동시 상한: 일반 스폰은 `unitCap - 1`을 상한으로 써서 보스용 1칸을
/// 남긴다. 상한에 걸린 스폰은 (문서의 "5초 대기 후 취소"를 단순화해)
/// 그 자리에서 바로 취소하고, 다음 정규 스폰 틱은 그대로 유지한다.
class SpawnSystem implements BattleSystem {
  @override
  void execute(BattleWorld w) {
    _processWaves(w);
    _processBossTriggers(w);
  }

  void _processWaves(BattleWorld w) {
    // 보스는 별도 카운트에서 제외한다 — 그래야 "일반 스폰은 unitCap-1까지"가
    // 보스 존재 여부와 무관하게 항상 지켜지고, 보스가 진짜 여분의 1칸을 쓴다.
    var nonBossEnemyCount = 0;
    for (final e in w.entities.ordered) {
      if (e.side == Side.enemy && e.isAlive && !e.def.isBoss) {
        nonBossEnemyCount++;
      }
    }

    for (final wave in w.waveStates) {
      final def = wave.def;
      final startTick = def.startSec * ticksPerSec;
      final stopTick = def.stopSec * ticksPerSec;
      if (w.tick < startTick || w.tick > stopTick) continue;

      final intervalTicks = def.intervalSec * ticksPerSec;
      if (intervalTicks <= 0) continue;
      if ((w.tick - startTick) % intervalTicks != 0) continue;
      if (def.count >= 0 && wave.spawnedCount >= def.count) continue;

      if (nonBossEnemyCount >= unitCap - 1) continue; // 보스용 1칸 예약

      final enemyDef = w.datapack.enemyById(def.enemyId);
      if (enemyDef == null) continue; // 존재하지 않는 참조 -> 경고 없이 스킵

      w.spawnEntity(enemyDef, Side.enemy, def.spawnX * posScale);
      wave.spawnedCount++;
      nonBossEnemyCount++;
    }
  }

  void _processBossTriggers(BattleWorld w) {
    for (final trigger in w.bossTriggers) {
      switch (trigger.state) {
        case BossTriggerState.pending:
          if (_conditionMet(w, trigger.def)) {
            trigger.state = BossTriggerState.warning;
            trigger.warningTicksLeft = trigger.def.warningTicks;
            w.enemyBase.hp = 1; // 파괴급 피해라도 HP 1을 남기고 보호
            w.enemyBase.damageImmune = true;
          }
        case BossTriggerState.warning:
          trigger.warningTicksLeft--;
          if (trigger.warningTicksLeft <= 0) {
            trigger.state = BossTriggerState.spawned;
            w.enemyBase.damageImmune = false;
            final bossDef = w.datapack.enemyById(trigger.def.enemyId);
            if (bossDef != null) {
              // 보스는 예약된 자리를 쓰므로 상한 검사를 하지 않는다.
              w.spawnEntity(bossDef, Side.enemy, trigger.def.spawnX * posScale);
            }
          }
        case BossTriggerState.spawned:
          break; // 재진입 없음 -> 다단히트/저장복구에도 1회만 등장
      }
    }
  }

  bool _conditionMet(BattleWorld w, BossTriggerDef def) {
    return switch (def.conditionKind) {
      'NEST_FIRST_HIT' => w.enemyBase.hp < w.enemyBase.maxHp,
      _ => false,
    };
  }
}
