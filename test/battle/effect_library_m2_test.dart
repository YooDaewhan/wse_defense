import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/effect/effect_params.dart';
import 'package:wse_defense/battle/effect/effect_registry.dart';
import 'package:wse_defense/battle/stat/modifier.dart';
import 'package:wse_defense/battle/stat/modifier_source.dart';
import 'package:wse_defense/battle/stat/stat_key.dart';
import 'package:wse_defense/battle/tag/tag_effect_def.dart' show StatModDef;
import 'package:wse_defense/battle/system/damage_system.dart';
import 'package:wse_defense/battle/system/knockback_system.dart';
import 'package:wse_defense/battle/system/pending_damage.dart';
import 'package:wse_defense/battle/system/status_system.dart';
import 'package:wse_defense/battle/system/weather_system.dart';
import 'package:wse_defense/battle/tag/tag_def.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/tag/tag_registry.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';

UnitDef _unit({
  int maxHp = 1000,
  int def = 0,
  int hpSegments = 1,
  Map<String, int> intrinsicTags = const {},
}) => UnitDef(
  id: 'T',
  intrinsicTags: intrinsicTags,
  base: UnitBaseStats(
    maxHp: maxHp,
    atk: 100,
    def: def,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 100,
    moveSpeed: 100,
    hpSegments: hpSegments,
  ),
);

BattleWorld _newWorld({TagRegistry? registry, List<UnitDef> formation = const []}) => BattleWorld(
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
    formation: formation,
    tagRegistry: registry,
  ),
  rngSeed: 1,
  datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
  systems: [KnockbackSystem(), const StatusSystem(), DamageSystem(), WeatherSystem()],
)..phase = BattlePhase.running;

void main() {
  setUp(() {
    EffectRegistry.reset();
    registerAllEffects();
  });

  group('ATK_DOWN', () {
    test('reduces ATK, and only the strongest of the same exclusive group applies', () {
      final w = _newWorld();
      final e = w.spawnEntity(_unit(), Side.ally, 0);
      final atkDown = EffectRegistry.of('ATK_DOWN')!;

      atkDown.apply(w, e, const EffectParams(atkPct: -10000, durationTicks: 100), const ModifierSource(ModifierKind.skill, 'SKL_WEAK'));
      expect(e.stats.get(StatKey.atk), 90);

      // 더 약한 기죽이기가 나중에 걸려도 무시된다(같은 그룹 최강만 적용).
      atkDown.apply(w, e, const EffectParams(atkPct: -5000, durationTicks: 100), const ModifierSource(ModifierKind.skill, 'SKL_WEAKER'));
      expect(e.stats.get(StatKey.atk), 90);

      // 더 강한 기죽이기가 걸리면 그쪽으로 바뀐다.
      atkDown.apply(w, e, const EffectParams(atkPct: -30000, durationTicks: 100), const ModifierSource(ModifierKind.skill, 'SKL_STRONG'));
      expect(e.stats.get(StatKey.atk), 70);
    });
  });

  group('RALLY', () {
    test('consumes 5% max HP and applies the buff when HP is above the cost', () {
      final w = _newWorld();
      final e = w.spawnEntity(_unit(maxHp: 1000), Side.ally, 0);
      e.hp = 1000;
      final rally = EffectRegistry.of('RALLY')!;

      rally.apply(
        w,
        e,
        const EffectParams(
          selfCostPct: 5000,
          durationTicks: 100,
          mods: [StatModDef(stat: StatKey.atk, op: ModOp.pctAdd, value: 20000)],
        ),
        const ModifierSource(ModifierKind.skill, 'SKL_RALLY'),
      );
      w.step(); // DamageSystem이 큐잉된 selfCost를 처리

      expect(e.hp, 950); // 1000 - 5%
      expect(e.stats.get(StatKey.atk), 120); // +20% 버프 적용됨
    });

    test('does not trigger when HP is at or below the cost -- no buff, no damage', () {
      final w = _newWorld();
      final e = w.spawnEntity(_unit(maxHp: 1000), Side.ally, 0);
      e.hp = 50; // cost(5%)=50 -> hp <= cost
      final rally = EffectRegistry.of('RALLY')!;

      rally.apply(
        w,
        e,
        const EffectParams(
          selfCostPct: 5000,
          durationTicks: 100,
          mods: [StatModDef(stat: StatKey.atk, op: ModOp.pctAdd, value: 20000)],
        ),
        const ModifierSource(ModifierKind.skill, 'SKL_RALLY'),
      );

      expect(e.hp, 50); // 변화 없음
      expect(e.stats.get(StatKey.atk), 100); // 버프 없음
      expect(w.pendingDamage, isEmpty);
    });

    test('self-cost damage does not trigger natural knockback', () {
      final w = _newWorld();
      // hpSegments=2 -> 50% 지점이 자연 넉백 임계. 자기비용으로 그 임계를
      // 넘겨도(1000 -> 500 이하) 넉백이 걸리면 안 된다.
      final e = w.spawnEntity(_unit(maxHp: 1000, hpSegments: 2), Side.ally, 0);
      e.hp = 520;
      final rally = EffectRegistry.of('RALLY')!;

      rally.apply(
        w,
        e,
        const EffectParams(selfCostPct: 5000, durationTicks: 100, mods: []),
        const ModifierSource(ModifierKind.skill, 'SKL_RALLY'),
      );
      w.step();

      expect(e.hp, 470); // 520 - 5%(=50)
      expect(e.knockbackTicksLeft, 0); // 임계(500)를 넘었어도 자연 넉백 없음
    });

    test('self-cost damage does not create weather activity for FIELD-temper units', () {
      final registry = TagRegistry([const TagDef(id: 'TAG_TEMPER_FIELD', category: TagCategory.temper)]);
      final fieldDef = _unit(maxHp: 1000, hpSegments: 2, intrinsicTags: {'TAG_TEMPER_FIELD': 1});
      final w = _newWorld(registry: registry, formation: [fieldDef]);
      final e = w.spawnEntity(fieldDef, Side.ally, 0);
      e.hp = 600;
      final rally = EffectRegistry.of('RALLY')!;

      rally.apply(
        w,
        e,
        const EffectParams(selfCostPct: 50000, durationTicks: 100, mods: []), // 50% 소비 -> 임계 확실히 통과
        const ModifierSource(ModifierKind.skill, 'SKL_RALLY'),
      );
      w.step();

      // RALLY의 버프 적용 자체는 활약이지만(스킬 트리거 활약), 자기비용으로
      // 인한 "피해 수신" 활약은 들 기질에도 크레딧되지 않아야 한다 -- 이미
      // recordWeatherActivity(target)가 apply()에서 한 번 불렸으므로,
      // DamageSystem 쪽에서 추가로 안 불렸는지는 활성 목록 크기로 확인한다.
      expect(w.activeFieldKinds, [0]); // apply()의 버프-크레딧 1건만, 중복 없음
    });
  });

  group('PIERCE', () {
    test('ignores DEF, but only DEF -- shield absorption still applies', () {
      final w = _newWorld();
      final attacker = w.spawnEntity(_unit(), Side.ally, 0);
      final target = w.spawnEntity(_unit(def: 50000), Side.enemy, 100);

      final withoutPierce = computeDamage(w, attacker, target, 100);
      expect(withoutPierce, 50); // 100 * (1-0.5)

      EffectRegistry.of('PIERCE')!.apply(
        w,
        attacker,
        const EffectParams(durationTicks: 100),
        const ModifierSource(ModifierKind.skill, 'SKL_PIERCE'),
      );
      final withPierce = computeDamage(w, attacker, target, 100);
      expect(withPierce, 100); // DEF 무시
    });
  });

  group('SHELL', () {
    test('absorbs damage first, and the overflow carries to the body HP', () {
      final w = _newWorld();
      final e = w.spawnEntity(_unit(maxHp: 1000), Side.ally, 0);
      EffectRegistry.of('SHELL')!.apply(
        w,
        e,
        const EffectParams(amount: 30, durationTicks: 100),
        const ModifierSource(ModifierKind.skill, 'SKL_SHELL'),
      );
      expect(e.shieldHp, 30);

      w.pendingDamage.add(PendingDamage(targetId: e.id, sourceId: -1, amount: 50));
      w.step();

      expect(e.shieldHp, 0);
      expect(e.hp, 1000 - 20); // 30은 껍질이 흡수, 나머지 20만 본체로
    });

    test('natural knockback is judged on body HP, not shield HP', () {
      final w = _newWorld();
      final e = w.spawnEntity(_unit(maxHp: 1000, hpSegments: 2), Side.ally, 0);
      EffectRegistry.of('SHELL')!.apply(
        w,
        e,
        const EffectParams(amount: 1000, durationTicks: 100), // 충분히 큰 껍질
        const ModifierSource(ModifierKind.skill, 'SKL_SHELL'),
      );

      w.pendingDamage.add(PendingDamage(targetId: e.id, sourceId: -1, amount: 600)); // 껍질로 전부 흡수
      w.step();

      expect(e.hp, 1000); // 본체는 안 다침
      expect(e.knockbackTicksLeft, 0); // 임계를 넘을 이유가 없음
    });

    test('expiry clears any remaining shield HP', () {
      final w = _newWorld();
      final e = w.spawnEntity(_unit(), Side.ally, 0);
      EffectRegistry.of('SHELL')!.apply(
        w,
        e,
        const EffectParams(amount: 30, durationTicks: 5),
        const ModifierSource(ModifierKind.skill, 'SKL_SHELL'),
      );
      expect(e.shieldHp, 30);

      for (var i = 0; i < 5; i++) {
        w.step();
      }
      expect(e.shieldHp, 0);
    });
  });
}
