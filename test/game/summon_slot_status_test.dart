import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/constants.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/battle/world/summon.dart';
import 'package:wse_defense/game/hud/summon_slot_status.dart';

const _cheap = UnitDef(
  id: 'CHR_CHEAP',
  base: UnitBaseStats(
    summonCost: 100,
    maxHp: 100,
    atk: 10,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 100,
    moveSpeed: 0,
    resummonCooldownSec: 5,
  ),
);

const _tooExpensive = UnitDef(
  id: 'CHR_EXPENSIVE',
  base: UnitBaseStats(
    summonCost: 99999,
    maxHp: 100,
    atk: 10,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 100,
    moveSpeed: 0,
  ),
);

BattleWorld _newWorld({int startingPrayerPower = 200, int focusBaseCap = 1000}) => BattleWorld(
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
    formation: const [_cheap, _tooExpensive],
    startingPrayerPower: startingPrayerPower,
    focusBaseCap: focusBaseCap,
  ),
  rngSeed: 1,
  datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
  systems: const [],
)..phase = BattlePhase.running;

void main() {
  test('ready when affordable, off cooldown, under the unit cap', () {
    final w = _newWorld(startingPrayerPower: 200);
    expect(summonSlotStatus(w, 0), SummonSlotStatus.ready);
  });

  test('costExceedsCap takes priority even with plenty of prayer power', () {
    final w = _newWorld(startingPrayerPower: 99999); // cap은 기본치(1000)로 둬서 cost(99999) > cap을 보장
    expect(summonSlotStatus(w, 1), SummonSlotStatus.costExceedsCap);
  });

  test('notEnoughPrayer when below cost but within cap', () {
    final w = _newWorld(startingPrayerPower: 50);
    expect(summonSlotStatus(w, 0), SummonSlotStatus.notEnoughPrayer);
  });

  test('onCooldown after a successful summon, until cooldownLeft drains', () {
    final w = _newWorld(startingPrayerPower: 200);
    expect(trySummon(w, 0), SummonResult.ok);
    expect(summonSlotStatus(w, 0), SummonSlotStatus.onCooldown);
  });

  test('unitCapReached when the ally side is already full', () {
    final w = _newWorld(startingPrayerPower: 999999, focusBaseCap: 999999);
    for (var i = 0; i < unitCap; i++) {
      w.spawnEntity(_cheap, Side.ally, 0);
    }
    expect(summonSlotStatus(w, 0), SummonSlotStatus.unitCapReached);
  });

  test('invalidSlot outside formation range', () {
    final w = _newWorld();
    expect(summonSlotStatus(w, 5), SummonSlotStatus.invalidSlot);
  });

  test('ticksUntilAffordable is 0 once affordable, positive while short', () {
    final w = _newWorld(startingPrayerPower: 0, focusBaseCap: 1000);
    // 도토리 스타일 회복 없이(0) 는 무한대 취급.
    expect(ticksUntilAffordable(w, 0), greaterThan(0));

    final affordable = _newWorld(startingPrayerPower: 200);
    expect(ticksUntilAffordable(affordable, 0), 0);
  });
}
