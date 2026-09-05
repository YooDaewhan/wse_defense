import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/constants.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/system/resource_system.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/battle/world/summon.dart';

const _bear = UnitDef(
  id: 'CHR_BEAR',
  base: UnitBaseStats(
    summonCost: 900,
    maxHp: 3400,
    atk: 1100,
    attackPeriod: 105,
    attackWindup: 36,
    attackRecover: 69,
    attackRange: 200,
    moveSpeed: 50,
    resummonCooldownSec: 30,
  ),
);

BattleWorld _newWorld({
  int startingPrayerPower = 200,
  int focusBaseCap = 1000,
  List<UnitDef> formation = const [_bear],
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
    startingPrayerPower: startingPrayerPower,
    focusBaseCap: focusBaseCap,
    formation: formation,
  ),
  rngSeed: 1,
  datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
  systems: [ResourceSystem()],
)..phase = BattlePhase.running;

void main() {
  test('focus Lv1: waiting to afford the bear (900) takes 38.89s (+-1 tick)', () {
    final world = _newWorld(); // regen 18/s, start 200, cap 1000 (growth.json Lv1)

    var ticks = 0;
    while (world.prayerPower < 900) {
      world.step();
      ticks++;
      if (ticks > 100000) {
        fail('타임아웃: 900 기도력에 도달하지 못함');
      }
    }

    final expectedTicks = 700 / 18 * ticksPerSec; // (900-200)/18초 x 30틱/초
    expect((ticks - expectedTicks).abs(), lessThanOrEqualTo(1));
  });

  test('trySummon fails distinctly and never deducts prayer on failure', () {
    // costExceedsCap: 곰(900) 비용이 상한(500)보다 큼.
    final capWorld = _newWorld(startingPrayerPower: 500, focusBaseCap: 500);
    expect(trySummon(capWorld, 0), SummonResult.costExceedsCap);
    expect(capWorld.prayerPower, 500);

    // notEnoughPrayer: 비용(900)보다 적음.
    final poorWorld = _newWorld(startingPrayerPower: 100);
    expect(trySummon(poorWorld, 0), SummonResult.notEnoughPrayer);
    expect(poorWorld.prayerPower, 100);

    // onCooldown: 슬롯이 쿨다운 중.
    final cooldownWorld = _newWorld(startingPrayerPower: 1000);
    cooldownWorld.formation[0].cooldownLeft = 10;
    expect(trySummon(cooldownWorld, 0), SummonResult.onCooldown);
    expect(cooldownWorld.prayerPower, 1000);

    // unitCapReached: 아군이 이미 unitCap명.
    final fullWorld = _newWorld(startingPrayerPower: 1000);
    for (var i = 0; i < unitCap; i++) {
      fullWorld.spawnEntity(_bear, Side.ally, 0);
    }
    expect(trySummon(fullWorld, 0), SummonResult.unitCapReached);
    expect(fullWorld.prayerPower, 1000);

    // 성공: 위 실패 케이스들과 달리 실제로 차감된다.
    final okWorld = _newWorld(startingPrayerPower: 1000);
    expect(trySummon(okWorld, 0), SummonResult.ok);
    expect(okWorld.prayerPower, 1000 - 900);
  });

  test('prayer power never stores overflow past the cap', () {
    final world = _newWorld(startingPrayerPower: 990, focusBaseCap: 1000);
    for (var i = 0; i < 300; i++) {
      world.step();
    }
    expect(world.prayerPower, 1000);
  });

  test('prayerPowerFrac accumulation has zero cumulative regen error', () {
    final world = _newWorld(startingPrayerPower: 0, focusBaseCap: 1000000);
    for (var i = 0; i < 300; i++) {
      world.step(); // 300틱 = 10초, regen 18/초 -> 정확히 180
    }
    expect(world.prayerPower, 180);
  });
}
