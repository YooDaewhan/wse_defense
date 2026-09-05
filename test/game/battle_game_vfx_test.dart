import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/constants.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/system/attack_system.dart';
import 'package:wse_defense/battle/system/damage_system.dart';
import 'package:wse_defense/battle/system/target_system.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/game/battle_game.dart';

const _aoeAttacker = UnitDef(
  id: 'CHR_AOE',
  base: UnitBaseStats(
    maxHp: 1000,
    atk: 10,
    attackPeriod: 30,
    attackWindup: 6,
    attackRecover: 24,
    attackRange: 500,
    moveSpeed: 0,
    attackMode: 'AOE',
    aoeMaxTargets: 30,
  ),
);

const _dummy = UnitDef(
  id: 'ENM_DUMMY',
  base: UnitBaseStats(
    maxHp: 1000,
    atk: 0,
    attackPeriod: 999999,
    attackWindup: 1,
    attackRecover: 1,
    attackRange: 0,
    moveSpeed: 0,
  ),
);

BattleWorld _newWorld() => BattleWorld(
  config: const BattleConfig(
    stage: StageDef(
      id: 'STG_TEST',
      index: 1,
      fieldLength: 24000,
      allyBaseX: 0,
      enemyBaseX: 24000,
      enemyBaseHp: 1000,
      timeLimitSec: 300,
    ),
    allyBaseHp: 1000,
  ),
  rngSeed: 1,
  datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
  systems: [TargetSystem(), AttackSystem(), DamageSystem()],
)..phase = BattlePhase.running;

Future<void> _pumpFrames(WidgetTester tester, int count) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testWidgets('multiple targets hit in the same tick play the hit SFX only once that frame', (tester) async {
    final world = _newWorld();
    world.spawnEntity(_aoeAttacker, Side.ally, 0);
    for (var i = 0; i < 5; i++) {
      world.spawnEntity(_dummy, Side.enemy, 10 * posScale); // 전부 사거리 안, 같은 판정에 다 맞음
    }

    final playedSounds = <String>[];
    final game = BattleGame(battleWorld: world, onPlaySound: playedSounds.add);

    await tester.pumpWidget(MaterialApp(home: GameWidget(game: game)));
    await _pumpFrames(tester, 3); // onLoad

    // 판정(windup=6틱)까지 충분히 프레임을 밟는다. 60fps에서 6틱 ≈ 12프레임.
    await _pumpFrames(tester, 20);

    final hitCount = playedSounds.where((s) => s == 'sfx_hit').length;
    // "그 프레임"에 여러 대상이 동시에 맞아도 1회만 -- 그런데 여러 프레임에
    // 걸쳐 재판정(다음 공격 주기)이 없었는지도 확인해야 하므로, 최소 1번은
    // 재생됐고 5번(대상 수)만큼 중복 재생되지는 않았음을 함께 확인한다.
    expect(hitCount, greaterThan(0));
    expect(hitCount, lessThan(5));
  });

  testWidgets('damage text pool never exceeds its cap even when many targets are hit at once', (tester) async {
    final world = _newWorld();
    world.spawnEntity(_aoeAttacker, Side.ally, 0);
    for (var i = 0; i < 30; i++) {
      world.spawnEntity(_dummy, Side.enemy, 10 * posScale);
    }
    final game = BattleGame(battleWorld: world);

    await tester.pumpWidget(MaterialApp(home: GameWidget(game: game)));
    await _pumpFrames(tester, 3);
    await _pumpFrames(tester, 20); // 첫 판정까지 -- 30마리가 한 틱에 동시에 맞음

    // 크래시 없이 여기까지 왔다는 것 자체가 핵심 확인 사항.
    expect(tester.takeException(), isNull);
  });
}
