import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/defs/wave_def.dart';
import 'package:wse_defense/battle/effect/effect_params.dart';
import 'package:wse_defense/battle/effect/effect_registry.dart';
import 'package:wse_defense/battle/skill/skill_trigger_def.dart';
import 'package:wse_defense/battle/system/attack_system.dart';
import 'package:wse_defense/battle/system/battle_system.dart';
import 'package:wse_defense/battle/system/damage_system.dart';
import 'package:wse_defense/battle/system/death_system.dart';
import 'package:wse_defense/battle/system/input_system.dart';
import 'package:wse_defense/battle/system/knockback_system.dart';
import 'package:wse_defense/battle/system/movement_system.dart';
import 'package:wse_defense/battle/system/relation_system.dart';
import 'package:wse_defense/battle/system/resource_system.dart';
import 'package:wse_defense/battle/system/spawn_system.dart';
import 'package:wse_defense/battle/system/status_system.dart';
import 'package:wse_defense/battle/system/tag_resolve_system.dart';
import 'package:wse_defense/battle/system/target_system.dart';
import 'package:wse_defense/battle/system/victory_system.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_input.dart';
import 'package:wse_defense/battle/world/battle_world.dart';

/// T-20 결정론/직렬화/골든 리플레이 테스트가 공유하는 시나리오.
///
/// 태그·관계 규칙은 일부러 비워둔다(TagRegistry 기본값) — 그 결정론은
/// T-15/T-16이 이미 전담해서 검증하므로, 여기서는 직렬화·리플레이 자체가
/// 맞는지에 집중한다. 대신 RNG가 실제로 쓰이는 경로(스킬 발동 확률)는
/// 포함시켜 `DeterministicRng.exportState/restoreState`가 진짜로 필요한
/// 시나리오로 만든다.
const fighterDef = UnitDef(
  id: 'CHR_TEST_FIGHTER',
  base: UnitBaseStats(
    summonCost: 150,
    maxHp: 800,
    atk: 120,
    attackPeriod: 45,
    attackWindup: 10,
    attackRecover: 35,
    attackRange: 80,
    moveSpeed: 60,
    hpSegments: 2,
    resummonCooldownSec: 5,
  ),
  skills: ['SKL_ONCHANCE_HEAL'],
);

const grubDef = UnitDef(
  id: 'ENM_TEST_GRUB',
  base: UnitBaseStats(
    maxHp: 500,
    atk: 60,
    attackPeriod: 60,
    attackWindup: 15,
    attackRecover: 45,
    attackRange: 60,
    moveSpeed: 40,
    hpSegments: 2,
  ),
  killPrayerReward: 20,
);

const _healSkill = SkillTriggerDef(
  id: 'SKL_ONCHANCE_HEAL',
  triggerKind: TriggerKind.onChance,
  chance: 30000, // 30% (pctScale 기준)
  actions: [
    SkillActionDef(
      type: 'HEAL',
      params: EffectParams(
        amount: 40,
        intervalTicks: 10,
        durationTicks: 30,
        exclusiveGroup: 'HOT_SKL_ONCHANCE_HEAL',
      ),
    ),
  ],
);

BattleConfig buildScenarioConfig() => BattleConfig(
  stage: const StageDef(
    id: 'STG_TEST_REPLAY',
    index: 1,
    fieldLength: 2400,
    allyBaseX: 0,
    enemyBaseX: 2400,
    enemyBaseHp: 5000,
    timeLimitSec: 300,
    waves: [
      WaveDef(
        enemyId: 'ENM_TEST_GRUB',
        startSec: 2,
        intervalSec: 4,
        stopSec: 290,
        spawnX: 2350,
      ),
    ],
  ),
  allyBaseHp: 8000,
  formation: const [fighterDef],
  focusBaseRegen: 40, // 300초 안에 여러 번 소환할 수 있도록 기본치보다 빠르게
  skillDefs: const {'SKL_ONCHANCE_HEAL': _healSkill},
);

Datapack buildScenarioDatapack() =>
    const Datapack(characters: {}, enemies: {'ENM_TEST_GRUB': grubDef}, stages: {});

/// 03_BATTLE_ENGINE.md §3의 순서. EffectExpireSystem/WeatherSystem/
/// EventFlushSystem은 아직 없는 시스템이라(각각 미래 티켓 스코프) 뺀다.
List<BattleSystem> buildScenarioSystems() => [
  InputSystem(),
  ResourceSystem(),
  SpawnSystem(),
  TagResolveSystem(),
  RelationSystem(),
  const StatusSystem(),
  KnockbackSystem(),
  TargetSystem(),
  MovementSystem(),
  AttackSystem(),
  DamageSystem(),
  DeathSystem(),
  VictorySystem(),
];

/// seed로부터 결정론적으로 파생된, 매 시나리오마다 조금씩 다른 입력 스케줄.
/// tick 오름차순 (InputLog의 전제).
List<BattleInput> scriptedInputs(int seed) {
  final offset = seed % 7;
  final summonTicks = [30 + offset, 300, 900, 2400, 5000, 7200];
  return [
    for (final t in summonTicks) SummonInput(t, 0),
    UltimateInput(2000 + offset * 10),
    FocusBoostInput(10, 1),
    UltimateInput(6500 + offset * 10),
  ]..sort((a, b) => a.tick.compareTo(b.tick));
}

BattleWorld buildScenarioWorld(int seed) {
  EffectRegistry.reset();
  registerAllEffects();
  return BattleWorld(
    config: buildScenarioConfig(),
    rngSeed: seed,
    datapack: buildScenarioDatapack(),
    systems: buildScenarioSystems(),
  )..phase = BattlePhase.running;
}

/// [inputs]를 tick 순서대로 정확한 시점에 enqueue하면서 [ticks]번 step한다.
/// `BattleWorld.enqueueInput`은 "현재 tick"에 넣은 것을 그 tick의
/// InputSystem이 바로 소비하므로(battle_world.dart 주석 참고), 각 입력이
/// 가리키는 tick과 world.tick이 같아지는 정확한 순간에 넣어야 한다.
void replay(BattleWorld w, List<BattleInput> inputs, int ticks) {
  var idx = 0;
  // 재개(deserialize) 시 w.tick > 0으로 시작할 수 있다 — 이미 지나간 입력은
  // (직렬화 이전에 이미 적용됐으므로) 건너뛰고, 정확히 지금 tick과 같은
  // 것부터 다시 enqueue한다.
  while (idx < inputs.length && inputs[idx].tick < w.tick) {
    idx++;
  }
  for (var t = w.tick; t < ticks; t++) {
    while (idx < inputs.length && inputs[idx].tick == w.tick) {
      w.enqueueInput(inputs[idx]);
      idx++;
    }
    w.step();
  }
}
