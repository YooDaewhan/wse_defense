import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/constants.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/system/damage_system.dart';
import 'package:wse_defense/battle/system/resource_system.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/battle/world/ultimate.dart';

UnitDef _unit({bool isBoss = false}) => UnitDef(
  id: 'T',
  isBoss: isBoss,
  base: const UnitBaseStats(
    maxHp: 1000,
    atk: 10,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 100,
    moveSpeed: 0,
  ),
);

BattleWorld _newWorld({
  int focusBoostStage = 0,
  List<int> focusBoostBonus = const [0, 7, 14],
}) =>
    BattleWorld(
      config: BattleConfig(
        stage: const StageDef(
          id: 'STG_TEST',
          index: 1,
          fieldLength: 2400,
          allyBaseX: 0,
          enemyBaseX: 2400,
          enemyBaseHp: 5000,
          timeLimitSec: 300,
        ),
        allyBaseHp: 10000,
        focusBoostBonus: focusBoostBonus,
      ),
      rngSeed: 1,
      datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
      systems: [ResourceSystem(), DamageSystem()],
    )..phase = BattlePhase.running
      ..focusBoostStage = focusBoostStage;

void main() {
  test('ultimate gauge starts at 50%', () {
    final w = _newWorld();
    expect(w.ultimateGauge, ultGaugeMax ~/ 2);
  });

  test('charges from empty to full over 60 seconds (900 more ticks from the 50% start)', () {
    final w = _newWorld();
    for (var i = 0; i < ultGaugeMax ~/ 2; i++) {
      w.step();
    }
    expect(w.ultimateStock, 1);
    expect(w.ultimateGauge, 0);
  });

  test('caps at 1 stock even after charging far past full again', () {
    final w = _newWorld();
    for (var i = 0; i < ultGaugeMax * 3; i++) {
      w.step();
    }
    expect(w.ultimateStock, 1);
  });

  test('focus boost stage does not change the ultimate charge rate', () {
    final wPlain = _newWorld();
    final wBoosted = _newWorld(focusBoostStage: 2);

    for (var i = 0; i < 500; i++) {
      wPlain.step();
      wBoosted.step();
    }
    expect(wBoosted.ultimateGauge, wPlain.ultimateGauge);
  });

  test('deals 300 forced-knockback damage to every targetable enemy, spares the nest and knocked-back units', () {
    final w = _newWorld();
    w.ultimateStock = 1;

    final normalEnemy = w.spawnEntity(_unit(), Side.enemy, 0);
    final bossEnemy = w.spawnEntity(_unit(isBoss: true), Side.enemy, 500 * posScale);
    final knockedBackEnemy = w.spawnEntity(_unit(), Side.enemy, 1000 * posScale);
    knockedBackEnemy.knockbackTicksLeft = 10;
    final ally = w.spawnEntity(_unit(), Side.ally, 0);
    final nestHpBefore = w.enemyBase.hp;

    castUltimate(w);
    expect(w.ultimateStock, 0);
    w.step(); // DamageSystem이 pendingDamage를 확정 적용

    expect(normalEnemy.hp, 1000 - ultDamage);
    expect(bossEnemy.hp, 1000 - ultDamage); // 피해량 자체는 보스도 동일
    expect(bossEnemy.knockbackTicksLeft, naturalKbTicks);
    expect(normalEnemy.knockbackTicksLeft, naturalKbTicks);

    // 보스는 거리만 절반 -> 속도(밀린 정도)가 더 작다.
    expect(
      bossEnemy.knockbackVelocity.abs(),
      lessThan(normalEnemy.knockbackVelocity.abs()),
    );

    expect(knockedBackEnemy.hp, 1000); // 넉백 중 무적이라 대상에서 제외
    expect(ally.hp, 1000); // 아군은 애초에 대상이 아님
    expect(w.enemyBase.hp, nestHpBefore); // 둥지는 제외
  });
}
