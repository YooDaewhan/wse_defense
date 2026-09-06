import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_input.dart';
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

  /// 10_WIRING_PLAN.md T-60 완료조건: "전투 종료 시 입력 로그를
  /// submitBattle로 전송"의 전제 -- 결과가 확정되는 순간 딱 한 번, 그때까지
  /// 기록된 입력과 함께 알려준다.
  testWidgets('onBattleEnd fires exactly once, with the recorded inputs, when outcome is decided', (tester) async {
    final world = _newWorld();
    var callCount = 0;
    List<Object>? recordedAtEnd;

    await tester.pumpWidget(
      MaterialApp(
        home: BattleScreen(
          world: world,
          onBattleEnd: (recorded, maxFrontlineX) {
            callCount++;
            recordedAtEnd = recorded;
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    await tester.tap(find.byKey(const ValueKey('summon_slot_0')));
    await tester.pump(const Duration(milliseconds: 16));
    expect(callCount, 0); // 아직 안 끝남

    world.outcome = BattleOutcome.allyWin;
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16)); // 한 번 더 돌아도 재호출 안 됨

    expect(callCount, 1);
    expect(recordedAtEnd, hasLength(1));
    expect(recordedAtEnd!.single, isA<SummonInput>());
  });
}
