import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/constants.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/stat/stat_key.dart';
import 'package:wse_defense/battle/system/battle_system.dart';
import 'package:wse_defense/battle/system/tag_resolve_system.dart';
import 'package:wse_defense/battle/tag/tag_contribution.dart';
import 'package:wse_defense/battle/tag/tag_def.dart';
import 'package:wse_defense/battle/tag/tag_effect_def.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/tag/tag_registry.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';

TagRegistry _loadRegistry() {
  final json =
      jsonDecode(File('assets/data/v1/tags.json').readAsStringSync())
          as Map<String, Object?>;
  return TagRegistry([
    for (final t in json['tags'] as List<Object?>)
      TagDef.fromJson(t as Map<String, Object?>),
  ]);
}

List<TagEffectDef> _loadEffects(
  TagRegistry registry, {
  Set<String> exclude = const {},
}) {
  final json =
      jsonDecode(File('assets/data/v1/tag_effects.json').readAsStringSync())
          as Map<String, Object?>;
  return [
    for (final e in json['effects'] as List<Object?>)
      if (!exclude.contains((e as Map<String, Object?>)['id']))
        TagEffectDef.fromJson(e, registry),
  ];
}

UnitDef _unit(
  String id, {
  Map<String, int> intrinsicTags = const {},
  int maxHp = 1000,
}) => UnitDef(
  id: id,
  intrinsicTags: intrinsicTags,
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

BattleWorld _newWorld({
  required TagRegistry registry,
  required List<TagEffectDef> effects,
  List<UnitDef> formation = const [],
  List<BattleSystem> systems = const [],
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
    formation: formation,
    tagRegistry: registry,
    tagEffects: effects,
  ),
  rngSeed: 1,
  datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
  systems: systems,
)..phase = BattlePhase.running;

void main() {
  final registry = _loadRegistry();
  final effects = _loadEffects(registry);
  final animalIdx = registry.indexOf('TAG_RACE_ANIMAL');
  final chubbyIdx = registry.indexOf('TAG_BUILD_CHUBBY');

  test('3 animal characters in formation -> formationTagLevel[ANIMAL] == 3', () {
    final world = _newWorld(
      registry: registry,
      effects: effects,
      formation: [
        _unit('A1', intrinsicTags: {'TAG_RACE_ANIMAL': 1}),
        _unit('A2', intrinsicTags: {'TAG_RACE_ANIMAL': 1}),
        _unit('A3', intrinsicTags: {'TAG_RACE_ANIMAL': 1}),
      ],
    );

    expect(world.formationTagLevel.levelOf(animalIdx), 3);
  });

  test('adding a divine character wearing an animal mask -> formationTagLevel[ANIMAL] == 4', () {
    // 장비 시스템(T-39/T-44)이 아직 없어, "장비로 받은 태그가 합쳐진 뒤"의
    // intrinsicTags를 직접 준 UnitDef로 대신한다 — 여기서 검증하려는 건
    // 합산 로직(§2.2)이지 장비 부여 경로 자체가 아니다.
    final world = _newWorld(
      registry: registry,
      effects: effects,
      formation: [
        _unit('A1', intrinsicTags: {'TAG_RACE_ANIMAL': 1}),
        _unit('A2', intrinsicTags: {'TAG_RACE_ANIMAL': 1}),
        _unit('A3', intrinsicTags: {'TAG_RACE_ANIMAL': 1}),
        _unit('DIVINE_WITH_MASK', intrinsicTags: {'TAG_RACE_ANIMAL': 1}),
      ],
    );

    expect(world.formationTagLevel.levelOf(animalIdx), 4);
  });

  test('CHUBBY Lv1 -> maxHp x1.05, buffed to Lv2 -> x1.10, expiry -> exactly x1.05', () {
    final world = _newWorld(registry: registry, effects: effects);
    final e = world.spawnEntity(
      _unit('CHR_TEST', intrinsicTags: {'TAG_BUILD_CHUBBY': 1}, maxHp: 1000),
      Side.ally,
      0,
    );

    expect(e.stats.get(StatKey.maxHp), 1050);

    e.tagContribs.add(
      TagContribution(
        tagIndex: chubbyIdx,
        amount: 1,
        kind: TagSourceKind.buff,
        sourceId: 'SKL_TEST_BUFF',
      ),
    );
    world.tagEffectResolver.onUnitTagsChanged(world, e);
    expect(e.stats.get(StatKey.maxHp), 1100);

    e.tagContribs.removeWhere((c) => c.sourceId == 'SKL_TEST_BUFF');
    world.tagEffectResolver.onUnitTagsChanged(world, e);
    expect(e.stats.get(StatKey.maxHp), 1050); // 오차 0으로 정확히 복귀
  });

  test('FIELD scope only updates every fieldSampleTicks (2s), stale between cycles', () {
    final world = _newWorld(
      registry: registry,
      effects: effects,
      systems: [TagResolveSystem()],
    );

    final herdUnits = [
      for (var i = 0; i < 5; i++)
        world.spawnEntity(
          _unit('HERD_$i', intrinsicTags: {'TAG_TRAIT_HERD': 1}),
          Side.ally,
          0,
        ),
    ];

    world.step(); // tick 0: 첫 resolveField. level=5 -> tier3(+4000)+tier5(+8000)=+12000
    const buffedAtk = 100 + 100 * 12000 ~/ 100000; // 112
    for (final e in herdUnits) {
      expect(e.stats.get(StatKey.atk), buffedAtk);
    }

    // 3명을 "죽여서" 살아있는 HERD 레벨을 5 -> 2로 떨어뜨린다 (tier3 미달).
    for (var i = 0; i < 3; i++) {
      herdUnits[i].hp = 0;
    }

    // 다음 60틱 경계 전까지는 갱신되지 않는다 — 59틱을 더 진행해도 그대로.
    for (var i = 0; i < fieldSampleTicks - 1; i++) {
      world.step();
    }
    expect(herdUnits[3].stats.get(StatKey.atk), buffedAtk); // 아직 스탈

    world.step(); // tick 60: 두 번째 resolveField -> level=2, tier 미달 -> 제거
    expect(herdUnits[3].stats.get(StatKey.atk), 100);
    expect(herdUnits[4].stats.get(StatKey.atk), 100);
  });

  test('TIER(HIGHEST) applies only the single best-qualifying tier, not cumulative', () {
    final world = _newWorld(
      registry: registry,
      effects: effects,
      formation: [_unit('TEAM_ANIMAL', intrinsicTags: {'TAG_RACE_ANIMAL': 6})],
    );
    expect(world.formationTagLevel.levelOf(animalIdx), 6);

    final e = world.spawnEntity(
      _unit('A1', intrinsicTags: {'TAG_RACE_ANIMAL': 1}),
      Side.ally,
      0,
    );

    // tier3(+2000)와 tier6(+5000) 둘 다 조건을 만족하지만 HIGHEST는 tier6만
    // 적용한다 (2000+5000=7000이 아니라 5000).
    expect(e.stats.get(StatKey.atk), 105);
  });

  test('TIER(CUMULATIVE) stacks every qualifying tier', () {
    final world = _newWorld(
      registry: registry,
      effects: effects,
      systems: [TagResolveSystem()],
    );
    for (var i = 0; i < 5; i++) {
      world.spawnEntity(
        _unit('HERD_$i', intrinsicTags: {'TAG_TRAIT_HERD': 1}),
        Side.ally,
        0,
      );
    }
    world.step(); // level=5 -> tier3(+4000) + tier5(+8000) 누적 = +12000(12%)

    final e = world.entities.ordered.first;
    expect(e.stats.get(StatKey.atk), 112);
    expect(e.stats.get(StatKey.knockbackResist), 1); // tier5의 FLAT_ADD도 함께
  });

  test('deleting one effect from tag_effects.json makes it disappear on next load', () {
    final withoutChubby = _loadEffects(registry, exclude: {'TEF_CHUBBY'});

    final worldA = _newWorld(registry: registry, effects: effects); // 전체 로딩
    final worldB = _newWorld(registry: registry, effects: withoutChubby); // 삭제 후

    final def = _unit('CHR_TEST', intrinsicTags: {'TAG_BUILD_CHUBBY': 1}, maxHp: 1000);
    final eA = worldA.spawnEntity(def, Side.ally, 0);
    final eB = worldB.spawnEntity(def, Side.ally, 0);

    expect(eA.stats.get(StatKey.maxHp), 1050); // 그대로 적용됨
    expect(eB.stats.get(StatKey.maxHp), 1000); // 삭제됐으니 적용 안 됨
  });
}
