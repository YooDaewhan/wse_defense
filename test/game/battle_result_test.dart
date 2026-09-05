import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/constants.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/entity/entity_state.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/game/battle_result.dart';

const _defender = UnitDef(
  id: 'CHR_DEFENDER',
  role: 'ROLE_DEFENDER',
  base: UnitBaseStats(
    maxHp: 1000,
    atk: 50,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 80,
    moveSpeed: 0,
  ),
);

const _attacker = UnitDef(
  id: 'CHR_ATTACKER',
  role: 'ROLE_ATTACKER',
  base: UnitBaseStats(
    maxHp: 300,
    atk: 100,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 100,
    moveSpeed: 0,
  ),
);

const _shortRangeGrub = UnitDef(
  id: 'ENM_GRUB',
  base: UnitBaseStats(
    maxHp: 200,
    atk: 20,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 60,
    moveSpeed: 0,
  ),
);

const _longRangeSniper = UnitDef(
  id: 'ENM_SNIPER',
  base: UnitBaseStats(
    maxHp: 200,
    atk: 20,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 999,
    moveSpeed: 0,
  ),
);

const _boss = UnitDef(
  id: 'ENM_BOSS',
  isBoss: true,
  base: UnitBaseStats(
    maxHp: 5000,
    atk: 200,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 100,
    moveSpeed: 0,
  ),
);

BattleWorld _newWorld({List<UnitDef> formation = const [_attacker]}) => BattleWorld(
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
    allyBaseHp: 1000,
    formation: formation,
  ),
  rngSeed: 1,
  datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
  systems: const [],
)..phase = BattlePhase.running;

void main() {
  test('formationUsed reflects the formation the battle was fought with', () {
    final w = _newWorld(formation: const [_attacker, _defender]);
    final result = computeBattleResult(w);
    expect(result.formationUsed.map((d) => d.id), ['CHR_ATTACKER', 'CHR_DEFENDER']);
  });

  test('no ally deaths -> no frontline collapse tick', () {
    final w = _newWorld();
    w.spawnEntity(_attacker, Side.ally, 0);
    expect(computeBattleResult(w).frontlineCollapseTick, isNull);
  });

  test('frontline collapse tick is the last ally death', () {
    final w = _newWorld();
    final a = w.spawnEntity(_attacker, Side.ally, 0);
    final b = w.spawnEntity(_attacker, Side.ally, 0);
    a.hp = 0;
    a.action = EntityAction.dead;
    a.deathTick = 100;
    b.hp = 0;
    b.action = EntityAction.dead;
    b.deathTick = 250;
    w.outcome = BattleOutcome.enemyWin;

    expect(computeBattleResult(w).frontlineCollapseTick, 250);
  });

  test('a boss present is always the main enemy, even with other enemies alive', () {
    final w = _newWorld();
    w.spawnEntity(_shortRangeGrub, Side.enemy, 2000 * posScale);
    w.spawnEntity(_boss, Side.enemy, 2200 * posScale);
    w.outcome = BattleOutcome.enemyWin;

    expect(computeBattleResult(w).mainEnemy?.id, 'ENM_BOSS');
  });

  test('without a boss, the main enemy is the alive enemy closest to the ally base', () {
    final w = _newWorld();
    w.spawnEntity(_shortRangeGrub, Side.enemy, 2000 * posScale); // 더 멀리
    w.spawnEntity(_longRangeSniper, Side.enemy, 500 * posScale); // 아군 기지(x=0)에 더 가까움
    w.outcome = BattleOutcome.enemyWin;

    expect(computeBattleResult(w).mainEnemy?.id, 'ENM_SNIPER');
  });

  test('a win never surfaces hints, even if the formation "looks" defenseless', () {
    final w = _newWorld(formation: const [_attacker]);
    w.spawnEntity(_longRangeSniper, Side.enemy, 500 * posScale);
    w.outcome = BattleOutcome.allyWin;

    expect(computeBattleResult(w).hints, isEmpty);
  });

  test('a loss with no defender in the formation gets the defender hint', () {
    final w = _newWorld(formation: const [_attacker]);
    w.outcome = BattleOutcome.enemyWin;
    expect(computeBattleResult(w).hints, contains('편성에 방어형이 없습니다.'));
  });

  test('a loss with a defender in the formation does not get the defender hint', () {
    final w = _newWorld(formation: const [_attacker, _defender]);
    w.outcome = BattleOutcome.enemyWin;
    expect(computeBattleResult(w).hints, isNot(contains('편성에 방어형이 없습니다.')));
  });

  test('a loss where the main enemy outranges every unit in the formation gets the range hint', () {
    final w = _newWorld(formation: const [_attacker, _defender]); // 최대 사거리 100
    w.spawnEntity(_longRangeSniper, Side.enemy, 500 * posScale); // 사거리 999
    w.outcome = BattleOutcome.enemyWin;

    expect(
      computeBattleResult(w).hints.any((h) => h.contains('사거리')),
      isTrue,
    );
  });

  test('a loss with a long gap between summons gets the stagger-summon hint', () {
    final w = _newWorld(formation: const [_attacker]);
    w.spawnEntity(_attacker, Side.ally, 0); // spawnTick 0 (world.tick 아직 0)
    w.tick = 2000;
    w.spawnEntity(_attacker, Side.ally, 0); // spawnTick 2000 -- 2000틱(66초 이상) 공백
    w.outcome = BattleOutcome.enemyWin;

    expect(
      computeBattleResult(w).hints.any((h) => h.contains('교대 소환')),
      isTrue,
    );
  });

  test('stats: clearSec/summons/kills reflect the final world state', () {
    final w = _newWorld(formation: const [_attacker]);
    w.spawnEntity(_attacker, Side.ally, 0);
    final enemy = w.spawnEntity(_shortRangeGrub, Side.enemy, 2000 * posScale);
    enemy.hp = 0;
    enemy.action = EntityAction.dead;
    w.tick = 900; // 30초
    w.outcome = BattleOutcome.allyWin;

    final result = computeBattleResult(w);
    expect(result.clearSec, 30.0);
    expect(result.summons, 1);
    expect(result.kills, 1);
    expect(result.isWin, isTrue);
  });
}
