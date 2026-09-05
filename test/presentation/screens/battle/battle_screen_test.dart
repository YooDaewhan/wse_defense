import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/game/battle_game.dart';
import 'package:wse_defense/presentation/screens/battle/battle_hud.dart';
import 'package:wse_defense/presentation/screens/battle/battle_screen.dart';

const _cheap = UnitDef(
  id: 'CHR_CHEAP',
  base: UnitBaseStats(
    summonCost: 75,
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

BattleWorld _newWorld() => BattleWorld(
  config: const BattleConfig(
    stage: StageDef(
      id: 'STG_TEST',
      index: 1,
      fieldLength: 2400,
      allyBaseX: 0,
      enemyBaseX: 2400,
      enemyBaseHp: 1000,
      timeLimitSec: 300,
    ),
    allyBaseHp: 1000,
    formation: [_cheap],
  ),
  rngSeed: 1,
  datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
  systems: const [],
)..phase = BattlePhase.running;

void main() {
  testWidgets('renders the Flame canvas and the HUD together, HUD reflects live world state', (tester) async {
    final world = _newWorld();
    await tester.pumpWidget(MaterialApp(home: BattleScreen(world: world)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.byType(GameWidget<BattleGame>), findsOneWidget);
    expect(find.byType(BattleHud), findsOneWidget);
    expect(find.byKey(const ValueKey('summon_slot_0')), findsOneWidget);

    // 소환 성공 -> HUD가(같은 world를 보므로) 소환 슬롯 상태 변화를 반영한다.
    await tester.tap(find.byKey(const ValueKey('summon_slot_0')));
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.byKey(const ValueKey('cooldown_overlay')), findsOneWidget);
  });
}
