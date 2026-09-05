import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/constants.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/effect/effect_params.dart';
import 'package:wse_defense/battle/effect/effect_registry.dart';
import 'package:wse_defense/battle/entity/entity_state.dart';
import 'package:wse_defense/battle/stat/modifier_source.dart';
import 'package:wse_defense/battle/stat/stat_key.dart';
import 'package:wse_defense/battle/system/knockback_system.dart';
import 'package:wse_defense/battle/system/status_system.dart';
import 'package:wse_defense/battle/tag/tag_def.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/tag/tag_registry.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';

UnitDef _unit({int maxHp = 1000, bool isBoss = false}) => UnitDef(
  id: 'T',
  isBoss: isBoss,
  base: UnitBaseStats(
    maxHp: maxHp,
    atk: 100,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 100,
    moveSpeed: 100,
  ),
);

BattleWorld _newWorld({TagRegistry? registry}) => BattleWorld(
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
    tagRegistry: registry,
  ),
  rngSeed: 1,
  datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
  systems: [KnockbackSystem(), const StatusSystem()],
)..phase = BattlePhase.running;

void main() {
  setUp(() {
    EffectRegistry.reset();
    registerAllEffects();
  });

  test('STUN: max(remaining, new), 30-tick immunity after it ends, no stacking', () {
    final w = _newWorld();
    final e = w.spawnEntity(_unit(), Side.ally, 0);
    const src = ModifierSource(ModifierKind.skill, 'SKL_TEST_STUN');
    final stun = EffectRegistry.of('STUN')!;

    stun.apply(w, e, const EffectParams(durationTicks: 15), src);
    expect(e.action, EntityAction.stunned);
    expect(e.effects.single.ticksLeft, 15);

    // 더 짧은 재적용 -> 무시하고 기존(더 긴) 잔여를 유지한다.
    stun.apply(w, e, const EffectParams(durationTicks: 5), src);
    expect(e.effects.single.ticksLeft, 15);

    // 더 긴 재적용 -> 갱신된다.
    stun.apply(w, e, const EffectParams(durationTicks: 20), src);
    expect(e.effects.single.ticksLeft, 20);
    expect(e.effects.length, 1); // 합산 없음, 인스턴스 1개만

    for (var i = 0; i < 20; i++) {
      w.step();
    }
    expect(e.action, EntityAction.idle);
    // 20번째 step() 호출이 처리되는 순간의 w.tick은 19(0-index) -> 19+30.
    expect(e.stunImmuneUntilTick, 19 + stunImmuneTicks);

    // 면역 기간 중 재적용 시도 -> 무시됨.
    stun.apply(w, e, const EffectParams(durationTicks: 10), src);
    expect(e.effects, isEmpty);
    expect(e.action, EntityAction.idle);
  });

  test('SLOW: move -30%, attack period x1.25, only affects the next attack cycle', () {
    final w = _newWorld();
    final e = w.spawnEntity(_unit(), Side.ally, 0);
    const src = ModifierSource(ModifierKind.skill, 'SKL_TEST_SLOW');

    EffectRegistry.of('SLOW')!.apply(
      w,
      e,
      const EffectParams(durationTicks: 90, movePct: -30000, attackPeriodMult: 125000),
      src,
    );

    expect(e.stats.get(StatKey.moveSpeed), 70); // 100*(1-0.30)
    expect(e.stats.get(StatKey.attackPeriod), 75); // 60*1.25

    for (var i = 0; i < 90; i++) {
      w.step();
    }
    expect(e.stats.get(StatKey.moveSpeed), 100); // 만료 후 원복
    expect(e.stats.get(StatKey.attackPeriod), 60);
  });

  test('PUSH: forced knockback, halved distance on bosses, 3s re-application cooldown', () {
    final w = _newWorld();
    final boss = w.spawnEntity(_unit(isBoss: true), Side.enemy, 500 * posScale);
    const src = ModifierSource(ModifierKind.skill, 'SKL_TEST_PUSH');
    final push = EffectRegistry.of('PUSH')!;

    push.apply(w, boss, const EffectParams(distance: 60), src);
    expect(boss.knockbackTicksLeft, naturalKbTicks);
    expect(boss.knockbackIsForced, isTrue);
    // 보스는 거리 50%: 60 -> 30(논리단위) x posScale, naturalKbTicks로 나눈 속도.
    final expectedVelocity = -boss.facingSign * 30 * posScale ~/ naturalKbTicks;
    expect(boss.knockbackVelocity, expectedVelocity);

    for (var i = 0; i < naturalKbTicks; i++) {
      w.step();
    }
    expect(boss.knockbackTicksLeft, 0);

    // 밀치기 자체의 3초 쿨다운 안에는 재적용되지 않는다.
    push.apply(w, boss, const EffectParams(distance: 60), src);
    expect(boss.knockbackTicksLeft, 0);

    for (var i = 0; i < pushCooldownTicks - naturalKbTicks; i++) {
      w.step();
    }
    push.apply(w, boss, const EffectParams(distance: 60), src);
    expect(boss.knockbackTicksLeft, naturalKbTicks); // 3초 경과 후엔 다시 걸림
  });

  test('HEAL(HOT): never exceeds max HP; only the strongest of the same exclusiveGroup applies', () {
    final w = _newWorld();
    final e = w.spawnEntity(_unit(maxHp: 1000), Side.ally, 0);
    e.hp = 900;
    final heal = EffectRegistry.of('HEAL')!;

    heal.apply(
      w,
      e,
      const EffectParams(
        amount: 50,
        intervalTicks: 10,
        durationTicks: 100,
        exclusiveGroup: 'HOT_SKL_WEAK',
      ),
      const ModifierSource(ModifierKind.skill, 'SKL_WEAK'),
    );
    // 더 약한 같은 그룹의 HOT을 나중에 걸어도 무시된다.
    heal.apply(
      w,
      e,
      const EffectParams(
        amount: 20,
        intervalTicks: 10,
        durationTicks: 100,
        exclusiveGroup: 'HOT_SKL_WEAK',
      ),
      const ModifierSource(ModifierKind.skill, 'SKL_WEAKER'),
    );
    expect(e.effects.length, 1);
    expect(e.effects.single.params.amount, 50); // 더 강한 쪽(50)만 남음

    for (var i = 0; i < 10; i++) {
      w.step();
    }
    expect(e.hp, 950); // 900 + 50

    for (var i = 0; i < 10; i++) {
      w.step();
    }
    expect(e.hp, 1000); // 950 + 50 = 1000 (최대치)

    for (var i = 0; i < 10; i++) {
      w.step();
    }
    expect(e.hp, 1000); // 최대HP 초과 불가
  });

  test('GRANT_TAG: unit scope reflects immediately, field scope waits a cycle', () {
    final registry = TagRegistry([
      const TagDef(id: 'TAG_TRAIT_BRAVE', category: TagCategory.trait),
    ]);
    final w = _newWorld(registry: registry);
    final tagIdx = registry.indexOf('TAG_TRAIT_BRAVE');
    final e = w.spawnEntity(_unit(), Side.ally, 0);

    EffectRegistry.of('GRANT_TAG')!.apply(
      w,
      e,
      EffectParams(durationTicks: 300, tagIndex: tagIdx, tagAmount: 1),
      const ModifierSource(ModifierKind.skill, 'SKL_BEAR_ROAR'),
    );

    expect(e.tags.levelOf(tagIdx), 1); // 유닛 스코프 즉시 반영
    expect(w.allyFieldTagLevel.levelOf(tagIdx), 0); // 필드는 아직(다음 주기 전)
  });

  test('adding a new effect only requires one line in registerAllEffects()', () {
    // registerAllEffects()가 실제로 6종을 전부 등록했는지 확인 — 새 효과를
    // 추가할 때 다른 파일을 고칠 필요가 없다는 걸 보여주는 것.
    for (final type in ['STUN', 'SLOW', 'PUSH', 'HEAL', 'STAT_BUFF', 'GRANT_TAG']) {
      expect(EffectRegistry.of(type), isNotNull, reason: '$type 미등록');
    }
  });
}
