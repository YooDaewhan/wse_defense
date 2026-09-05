import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/constants.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/effect/effect_params.dart';
import 'package:wse_defense/battle/effect/effect_registry.dart';
import 'package:wse_defense/battle/entity/battle_entity.dart';
import 'package:wse_defense/battle/entity/entity_state.dart';
import 'package:wse_defense/battle/skill/skill_trigger_def.dart';
import 'package:wse_defense/battle/skill/skill_trigger_runner.dart';
import 'package:wse_defense/battle/system/attack_system.dart';
import 'package:wse_defense/battle/system/damage_system.dart';
import 'package:wse_defense/battle/system/death_system.dart';
import 'package:wse_defense/battle/system/knockback_system.dart';
import 'package:wse_defense/battle/system/status_system.dart';
import 'package:wse_defense/battle/system/target_system.dart';
import 'package:wse_defense/battle/tag/tag_def.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/tag/tag_registry.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';

final _registry = TagRegistry([
  const TagDef(id: 'TAG_TEST_MARK', category: TagCategory.trait, maxUnitLevel: 999),
]);
final _markIdx = _registry.indexOf('TAG_TEST_MARK');

BattleWorld _newWorld({
  Map<String, SkillTriggerDef> skillDefs = const {},
  int rngSeed = 1,
}) => BattleWorld(
  config: BattleConfig(
    stage: const StageDef(
      id: 'STG_TEST',
      index: 1,
      fieldLength: 2400,
      allyBaseX: 0,
      enemyBaseX: 2400,
      enemyBaseHp: 1000,
      timeLimitSec: 300,
    ),
    allyBaseHp: 10000,
    tagRegistry: _registry,
    skillDefs: skillDefs,
  ),
  rngSeed: rngSeed,
  datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
  // 03_BATTLE_ENGINE.md §3의 상대 순서를 지킨다: StatusSystem(8)이
  // AttackSystem(12)보다 먼저 돌아야, 이번 틱에 새로 건 효과가 같은 틱에
  // 바로 깎이지 않는다.
  systems: [
    const StatusSystem(),
    KnockbackSystem(),
    TargetSystem(),
    AttackSystem(),
    DamageSystem(),
    DeathSystem(),
  ],
)..phase = BattlePhase.running;

BattleEntity _spawn(
  BattleWorld w,
  Side side,
  int x, {
  List<String> skills = const [],
  int maxHp = 1000,
  int attackPeriod = 60,
  int attackWindup = 12,
  int attackRecover = 48,
  int attackRange = 1000,
  String attackMode = 'SINGLE',
  int aoeMaxTargets = 1,
}) => w.spawnEntity(
  UnitDef(
    id: 'T_${side.name}_$x',
    skills: skills,
    base: UnitBaseStats(
      maxHp: maxHp,
      atk: 10,
      attackPeriod: attackPeriod,
      attackWindup: attackWindup,
      attackRecover: attackRecover,
      attackRange: attackRange,
      moveSpeed: 0,
      attackMode: attackMode,
      aoeMaxTargets: aoeMaxTargets,
    ),
  ),
  side,
  x * posScale,
);

void main() {
  setUp(() {
    EffectRegistry.reset();
    registerAllEffects();
  });

  test('ON_NTH_ATTACK (n=3): a fresh 15-tick stun fires on every 3rd completed attack', () {
    final w = _newWorld(
      skillDefs: {
        'SKL_LULLABY': const SkillTriggerDef(
          id: 'SKL_LULLABY',
          triggerKind: TriggerKind.onNthAttack,
          n: 3,
          target: TagQuery(side: QuerySide.enemy, limit: 1, sort: QuerySort.nearest),
          actions: [SkillActionDef(type: 'STUN', params: EffectParams(durationTicks: 15))],
        ),
      },
    );
    // 3사이클 간격(3*attackPeriod)이 멈칫 지속(15) + 재적용 면역(30)보다
    // 커야 매번 새로 걸린다 — 안 그러면 스턴 자신의 면역 규칙(T-17)에 막힌다.
    final attacker = _spawn(
      w,
      Side.ally,
      0,
      skills: ['SKL_LULLABY'],
      attackPeriod: 20,
      attackWindup: 4,
      attackRecover: 16,
    );
    final enemy = _spawn(w, Side.enemy, 50);

    var lastCompleted = 0;
    var confirmedFires = 0;
    for (var i = 0; i < 1000 && confirmedFires < 4; i++) {
      w.step();
      if (attacker.completedAttacks == lastCompleted) continue;
      lastCompleted = attacker.completedAttacks;
      if (lastCompleted % 3 != 0) continue;

      final stun = enemy.effects.where((e) => e.type == 'STUN').toList();
      expect(stun, hasLength(1));
      expect(stun.single.ticksLeft, 15); // 방금 새로 걸린 것(잔여가 다 안 깎임)
      confirmedFires++;
    }

    expect(confirmedFires, 4);
  });

  test('AOE hitting 5 targets fires the trigger once; a knockback-cancelled attack fires 0 times', () {
    final w = _newWorld(
      skillDefs: {
        'SKL_MARK': SkillTriggerDef(
          id: 'SKL_MARK',
          triggerKind: TriggerKind.onNthAttack,
          n: 1,
          actions: [
            SkillActionDef(
              type: 'GRANT_TAG',
              params: EffectParams(durationTicks: 0, tagIndex: _markIdx, tagAmount: 1),
            ),
          ],
        ),
      },
    );

    final attacker = _spawn(
      w,
      Side.ally,
      0,
      skills: ['SKL_MARK'],
      attackPeriod: 30,
      attackWindup: 5,
      attackRecover: 25,
      attackMode: 'AOE',
      aoeMaxTargets: 5,
    );
    for (var i = 0; i < 5; i++) {
      _spawn(w, Side.enemy, 60 + i);
    }

    for (var i = 0; i < 6; i++) {
      w.step();
    } // windup(5) 완료 시점까지
    expect(attacker.completedAttacks, 1);
    expect(attacker.lastHitTargetIds.length, 5); // 실제로 5명을 맞혔다
    expect(attacker.tags.levelOf(_markIdx), 1); // 하지만 트리거는 1회

    // 두 번째 사이클: windup 도중 강제 넉백으로 취소.
    // P=A+R=30이라 recover가 끝나자마자 같은 틱에 새 windup이 시작된다
    // (T-09) -> 25(recover 잔여) 더 지나야 두 번째 windup이 열린다.
    for (var i = 0; i < 25; i++) {
      w.step();
    }
    for (var i = 0; i < 2; i++) {
      w.step();
    } // 두 번째 windup 진행 중(5틱 중 2틱)
    expect(attacker.action, EntityAction.attackWindup);
    attacker.knockbackTicksLeft = naturalKbTicks; // 강제로 넉백 상태 진입(시뮬레이션)
    for (var i = 0; i < naturalKbTicks + 5; i++) {
      w.step();
    }
    expect(attacker.completedAttacks, 1); // 늘지 않음
    expect(attacker.tags.levelOf(_markIdx), 1); // 트리거도 안 늘어남
  });

  test('ON_HP_THRESHOLD fires exactly once per lifetime even after healing back up', () {
    final w = _newWorld(
      skillDefs: {
        'SKL_HALF_HP': SkillTriggerDef(
          id: 'SKL_HALF_HP',
          triggerKind: TriggerKind.onHpThreshold,
          hpThresholdPct: 50000,
          actions: [
            SkillActionDef(
              type: 'GRANT_TAG',
              params: EffectParams(durationTicks: 0, tagIndex: _markIdx, tagAmount: 1),
            ),
          ],
        ),
      },
    );
    final e = _spawn(w, Side.ally, 0, skills: ['SKL_HALF_HP'], maxHp: 1000);

    SkillTriggerRunner.onHpChanged(w, e, 1000, 400); // 50% 아래로
    expect(e.tags.levelOf(_markIdx), 1);

    e.hp = 900; // 회복
    SkillTriggerRunner.onHpChanged(w, e, 400, 900);
    SkillTriggerRunner.onHpChanged(w, e, 900, 300); // 다시 50% 아래로
    expect(e.tags.levelOf(_markIdx), 1); // 늘지 않음(생애 1회)
  });

  test('ON_SPAWN and ON_DEATH each fire exactly once per instance', () {
    final w = _newWorld(
      skillDefs: {
        'SKL_ON_SPAWN': SkillTriggerDef(
          id: 'SKL_ON_SPAWN',
          triggerKind: TriggerKind.onSpawn,
          actions: [
            SkillActionDef(
              type: 'GRANT_TAG',
              params: EffectParams(durationTicks: 0, tagIndex: _markIdx, tagAmount: 1),
            ),
          ],
        ),
      },
    );
    final e = _spawn(w, Side.ally, 0, skills: ['SKL_ON_SPAWN']);

    expect(e.tags.levelOf(_markIdx), 1);
    SkillTriggerRunner.onSpawn(w, e); // 실수로 두 번 불려도
    expect(e.tags.levelOf(_markIdx), 1); // 늘지 않음

    expect(e.firedOnceTriggers.contains('SKL_ON_SPAWN'), isTrue);

    final w2 = _newWorld(
      skillDefs: {
        'SKL_ON_DEATH': const SkillTriggerDef(id: 'SKL_ON_DEATH', triggerKind: TriggerKind.onDeath),
      },
    );
    final e2 = _spawn(w2, Side.ally, 0, skills: ['SKL_ON_DEATH']);
    e2.hp = 0;
    w2.step(); // DeathSystem이 처리 -> onDeath 1회
    expect(e2.firedOnceTriggers.contains('SKL_ON_DEATH'), isTrue);

    // DeathSystem을 다시 돌려도(예: 실수로) action==dead라 재실행되지 않는다.
    final firedBefore = Set.of(e2.firedOnceTriggers);
    w2.step();
    expect(e2.firedOnceTriggers, firedBefore);
  });

  test('ON_CHANCE defaults to PER_ATTACK and is deterministic via rng.stream(skillProc)', () {
    SkillTriggerDef skill(int chance) => SkillTriggerDef(
      id: 'SKL_CHANCE',
      triggerKind: TriggerKind.onChance,
      chance: chance,
      actions: [
        SkillActionDef(
          type: 'GRANT_TAG',
          params: EffectParams(durationTicks: 0, tagIndex: _markIdx, tagAmount: 1),
        ),
      ],
    );

    // chance=0 -> 절대 안 뜬다.
    final wNever = _newWorld(skillDefs: {'SKL_CHANCE': skill(0)});
    final never = _spawn(
      wNever,
      Side.ally,
      0,
      skills: ['SKL_CHANCE'],
      attackPeriod: 10,
      attackWindup: 2,
      attackRecover: 8,
    );
    _spawn(wNever, Side.enemy, 50);
    for (var i = 0; i < 60; i++) {
      wNever.step();
    }
    expect(never.tags.levelOf(_markIdx), 0);

    // chance=100% -> 매 판정마다(대상 수와 무관하게 1번) 뜬다.
    final wAlways = _newWorld(skillDefs: {'SKL_CHANCE': skill(pctScale)});
    final always = _spawn(
      wAlways,
      Side.ally,
      0,
      skills: ['SKL_CHANCE'],
      attackPeriod: 10,
      attackWindup: 2,
      attackRecover: 8,
    );
    _spawn(wAlways, Side.enemy, 50);
    for (var i = 0; i < 60; i++) {
      wAlways.step();
    }
    expect(always.tags.levelOf(_markIdx), always.completedAttacks);

    // 같은 시드로 두 번 굴리면 같은 결과 -> 결정론적 RNG 스트림 사용 확인.
    final chance50 = skill(50000);
    final wA = _newWorld(skillDefs: {'SKL_CHANCE': chance50}, rngSeed: 7);
    final wB = _newWorld(skillDefs: {'SKL_CHANCE': chance50}, rngSeed: 7);
    final a = _spawn(
      wA,
      Side.ally,
      0,
      skills: ['SKL_CHANCE'],
      attackPeriod: 10,
      attackWindup: 2,
      attackRecover: 8,
    );
    final b = _spawn(
      wB,
      Side.ally,
      0,
      skills: ['SKL_CHANCE'],
      attackPeriod: 10,
      attackWindup: 2,
      attackRecover: 8,
    );
    _spawn(wA, Side.enemy, 50);
    _spawn(wB, Side.enemy, 50);
    for (var i = 0; i < 60; i++) {
      wA.step();
      wB.step();
    }
    expect(a.tags.levelOf(_markIdx), b.tags.levelOf(_markIdx));
  });
}
