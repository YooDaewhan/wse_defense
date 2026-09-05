import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/constants.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/entity/battle_entity.dart';
import 'package:wse_defense/battle/stat/stat_key.dart';
import 'package:wse_defense/battle/system/relation_system.dart';
import 'package:wse_defense/battle/tag/tag_def.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/tag/tag_registry.dart';
import 'package:wse_defense/battle/tag/tag_relation_rule.dart';
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

List<TagRelationRule> _loadRules(TagRegistry registry) {
  final json =
      jsonDecode(File('assets/data/v1/tag_relations.json').readAsStringSync())
          as Map<String, Object?>;
  return [
    for (final r in json['rules'] as List<Object?>)
      TagRelationRule.fromJson(r as Map<String, Object?>, registry),
  ];
}

final _registry = _loadRegistry();
final _rules = _loadRules(_registry);

UnitDef _unit(String id, {Map<String, int> intrinsicTags = const {}, int def = 0}) => UnitDef(
  id: id,
  intrinsicTags: intrinsicTags,
  base: UnitBaseStats(
    maxHp: 1000,
    atk: 100,
    def: def,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 100,
    moveSpeed: 100,
  ),
);

BattleWorld _newWorld() => BattleWorld(
  config: BattleConfig(
    stage: const StageDef(
      id: 'STG_TEST',
      index: 1,
      fieldLength: 10000,
      allyBaseX: 0,
      enemyBaseX: 10000,
      enemyBaseHp: 1000,
      timeLimitSec: 300,
    ),
    allyBaseHp: 10000,
    tagRegistry: _registry,
    relationRules: _rules,
  ),
  rngSeed: 1,
  datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
  systems: [RelationSystem()],
)..phase = BattlePhase.running;

/// 다음 RELATION_SAMPLE_TICKS 경계를 반드시 한 번 지나도록 6틱 진행한다.
/// 딱 1번 step()만 부르면 다음 재평가가 안 일어날 수 있다(6틱 주기라서).
void _sample(BattleWorld w) {
  for (var i = 0; i < relationSampleTicks; i++) {
    w.step();
  }
}

BattleEntity _spawn(
  BattleWorld w,
  String id,
  Side side,
  int x, {
  Map<String, int> tags = const {},
  int def = 0,
}) => w.spawnEntity(_unit(id, intrinsicTags: tags, def: def), side, x * posScale);

void main() {
  test('coward within 400 ahead of a brave slows down within 0.2~0.4s', () {
    final w = _newWorld();
    final coward = _spawn(w, 'C', Side.ally, 0, tags: {'TAG_TRAIT_COWARD': 1});
    _spawn(w, 'B', Side.ally, 300, tags: {'TAG_TRAIT_BRAVE': 1}); // 앞(ahead), 거리 300<=400

    var activatedAtTick = -1;
    for (var i = 0; i < 12; i++) {
      w.step();
      if (activatedAtTick == -1 && coward.stats.get(StatKey.moveSpeed) < 100) {
        activatedAtTick = w.tick;
      }
    }

    expect(activatedAtTick, isNot(-1));
    expect(activatedAtTick, lessThanOrEqualTo(12)); // 0.4초(12틱) 이내
    expect(coward.stats.get(StatKey.moveSpeed), 75); // -25%
  });

  test('brave with 1 coward behind: +12%; with 2: +24% (scaleByOtherCount, maxScale 3)', () {
    final w = _newWorld();
    final brave = _spawn(w, 'B', Side.ally, 300, tags: {'TAG_TRAIT_BRAVE': 1});
    _spawn(w, 'C1', Side.ally, 0, tags: {'TAG_TRAIT_COWARD': 1}); // 뒤(behind)

    w.step();
    expect(brave.stats.get(StatKey.moveSpeed), 112); // 100*1.12

    _spawn(w, 'C2', Side.ally, 10, tags: {'TAG_TRAIT_COWARD': 1});
    _sample(w);
    expect(brave.stats.get(StatKey.moveSpeed), 124); // 100*1.24

    // maxScale 3 -> 4명이 되어도 3배에서 캡.
    _spawn(w, 'C3', Side.ally, 20, tags: {'TAG_TRAIT_COWARD': 1});
    _spawn(w, 'C4', Side.ally, 30, tags: {'TAG_TRAIT_COWARD': 1});
    _sample(w);
    expect(brave.stats.get(StatKey.moveSpeed), 136); // 100*(1+0.12*3), 4배 아님
  });

  test('scaleBySubjectTagLevel: coward Lv2 gets -50% instead of -25%', () {
    final w = _newWorld();
    final coward = _spawn(w, 'C', Side.ally, 0, tags: {'TAG_TRAIT_COWARD': 2});
    _spawn(w, 'B', Side.ally, 300, tags: {'TAG_TRAIT_BRAVE': 1});

    w.step();
    expect(coward.stats.get(StatKey.moveSpeed), 50); // 100*(1-0.25*2)
  });

  test('brave dying reverts the coward only after minActiveTicks(30) has elapsed', () {
    final w = _newWorld();
    final coward = _spawn(w, 'C', Side.ally, 0, tags: {'TAG_TRAIT_COWARD': 1});
    final brave = _spawn(w, 'B', Side.ally, 300, tags: {'TAG_TRAIT_BRAVE': 1});

    w.step(); // tick0: 활성화 (activeSince=0)
    expect(coward.stats.get(StatKey.moveSpeed), 75);

    brave.hp = 0; // 용감 사망 -> aliveOnly 필터에서 제외됨

    for (var i = 0; i < 29; i++) {
      w.step();
    }
    expect(w.tick, 30);
    expect(coward.stats.get(StatKey.moveSpeed), 75); // 아직(30틱 미만 경과 시점) 유지

    // minActiveTicks(30) 경과 후에도 offDelayTicks(12)만큼 더 필요
    // (30틱째 평가에서 offCounter=6, 36틱째 평가에서 12 -> 해제).
    for (var i = 0; i < 7; i++) {
      w.step();
    }
    expect(coward.stats.get(StatKey.moveSpeed), 100); // 36틱째 해제
  });

  test('no more than 2 on/off toggles occur within any 1-second (30-tick) window', () {
    final w = _newWorld();
    final coward = _spawn(w, 'C', Side.ally, 0, tags: {'TAG_TRAIT_COWARD': 1});
    final brave = _spawn(w, 'B', Side.ally, 300, tags: {'TAG_TRAIT_BRAVE': 1});

    final toggleTicks = <int>[];
    var wasActive = false;
    for (var i = 0; i < 20; i++) {
      // 최대한 적대적으로: 매 샘플마다 사거리 안/밖으로 순간이동.
      brave.x = (i.isEven ? 300 : 5000) * posScale;
      w.step();
      final isActive = coward.stats.get(StatKey.moveSpeed) != 100;
      if (isActive != wasActive) toggleTicks.add(w.tick);
      wasActive = isActive;
    }

    for (final t in toggleTicks) {
      final withinSecond = toggleTicks.where((o) => o >= t && o < t + ticksPerSec).length;
      expect(withinSecond, lessThan(3));
    }
  });

  test('OTHER_IS_ADJACENT and NO_OTHER_AHEAD relations work', () {
    final w = _newWorld();

    // ADJACENT: 방향 무관, 거리 250 이내.
    final herd1 = _spawn(w, 'H1', Side.ally, 100, tags: {'TAG_TRAIT_HERD': 1}, def: 100);
    _spawn(w, 'H2', Side.ally, 0, tags: {'TAG_TRAIT_HERD': 1}); // 뒤에 있어도 인접
    w.step();
    expect(herd1.stats.get(StatKey.def), 103); // 100*1.03

    // NO_OTHER_AHEAD: 앞에 아무도 없으면 활성.
    final vanguard = _spawn(w, 'V', Side.ally, 9999, tags: {'TAG_TRAIT_FIERCE': 1});
    _sample(w);
    expect(vanguard.stats.get(StatKey.atk), 115); // 100*1.15
  });

  test('the same rule applies independently on the enemy side too', () {
    final w = _newWorld();
    final allyCoward = _spawn(w, 'AC', Side.ally, 0, tags: {'TAG_TRAIT_COWARD': 1});
    _spawn(w, 'AB', Side.ally, 300, tags: {'TAG_TRAIT_BRAVE': 1});

    // 적 진영: facingSign=-1이므로 "앞"은 더 작은 x.
    final enemyCoward = _spawn(w, 'EC', Side.enemy, 9000, tags: {'TAG_TRAIT_COWARD': 1});
    _spawn(w, 'EB', Side.enemy, 8700, tags: {'TAG_TRAIT_BRAVE': 1});

    w.step();

    expect(allyCoward.stats.get(StatKey.moveSpeed), 75);
    expect(enemyCoward.stats.get(StatKey.moveSpeed), 75);
  });
}
