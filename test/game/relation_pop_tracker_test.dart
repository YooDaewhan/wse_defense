import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/entity/battle_entity.dart';
import 'package:wse_defense/battle/stat/modifier.dart';
import 'package:wse_defense/battle/stat/modifier_source.dart';
import 'package:wse_defense/battle/stat/stat_key.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/tag/tag_relation_state.dart';
import 'package:wse_defense/game/tags/relation_pop_tracker.dart';

const _unit = UnitDef(
  id: 'T',
  base: UnitBaseStats(
    maxHp: 100,
    atk: 10,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 100,
    moveSpeed: 100,
  ),
);

BattleEntity _entity() => BattleEntity(id: 1, side: Side.ally, def: _unit, spawnTick: 0, x: 0);

void main() {
  test('no relation ever active -> no pops', () {
    final e = _entity();
    final tracker = RelationPopTracker();
    expect(tracker.update(e, 1 / 60), isEmpty);
  });

  test('activating a relation with a positive moveSpeed modifier pops with speedUp=true', () {
    final e = _entity();
    e.stats.addModifier(
      const StatModifier(
        stat: StatKey.moveSpeed,
        op: ModOp.pctAdd,
        value: 20000,
        source: ModifierSource(ModifierKind.relation, 'RULE_FAST'),
      ),
    );
    final tracker = RelationPopTracker();

    e.relationStates['RULE_FAST'] = RelationState()..active = true;
    final pops = tracker.update(e, 1 / 60);

    expect(pops.length, 1);
    expect(pops.single.ruleId, 'RULE_FAST');
    expect(pops.single.speedUp, isTrue);
  });

  test('activating a relation with a negative moveSpeed modifier pops with speedUp=false', () {
    final e = _entity();
    e.stats.addModifier(
      const StatModifier(
        stat: StatKey.moveSpeed,
        op: ModOp.pctAdd,
        value: -20000,
        source: ModifierSource(ModifierKind.relation, 'RULE_SLOW'),
      ),
    );
    final tracker = RelationPopTracker();

    e.relationStates['RULE_SLOW'] = RelationState()..active = true;
    final pops = tracker.update(e, 1 / 60);

    expect(pops.single.speedUp, isFalse);
  });

  test('a pop expires after popDurationSec and does not linger', () {
    final e = _entity();
    e.relationStates['RULE_X'] = RelationState()..active = true;
    final tracker = RelationPopTracker();

    tracker.update(e, 0); // 활성화 감지, 팝 시작

    // 0.6초를 살짝 넘길 때까지 매 프레임 진행 -- 계속 active 상태여도 팝
    // 자체는 활성화 "전이" 그 순간부터 0.6초짜리라 시간이 지나면 사라진다.
    for (var i = 0; i < 40; i++) {
      tracker.update(e, 1 / 60); // 40 * 1/60 ≈ 0.667초
    }
    expect(tracker.update(e, 1 / 60), isEmpty);
  });

  test('deactivating reuses the direction captured while it was active (modifiers are already gone by then)', () {
    final e = _entity();
    e.stats.addModifier(
      const StatModifier(
        stat: StatKey.moveSpeed,
        op: ModOp.pctAdd,
        value: 20000,
        source: ModifierSource(ModifierKind.relation, 'RULE_FAST'),
      ),
    );
    final tracker = RelationPopTracker();

    e.relationStates['RULE_FAST'] = RelationState()..active = true;
    tracker.update(e, 0); // 활성화 팝 (speedUp=true로 기록됨)
    for (var i = 0; i < 40; i++) {
      tracker.update(e, 1 / 60); // 그 팝이 만료될 때까지 흘려보냄
    }

    // 실제 RelationSystem처럼, 비활성화 시점엔 모디파이어가 이미 제거된
    // 뒤라고 가정 -- 그래도 direction은 기억해뒀던 값을 그대로 쓴다.
    e.stats.removeBySource(ModifierKind.relation, 'RULE_FAST');
    e.relationStates['RULE_FAST'] = RelationState()..active = false;
    final pops = tracker.update(e, 1 / 60);

    expect(pops.single.ruleId, 'RULE_FAST');
    expect(pops.single.speedUp, isTrue);
  });
}
