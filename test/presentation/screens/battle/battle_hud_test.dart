import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/constants.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/presentation/screens/battle/battle_hud.dart';

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

const _expensive = UnitDef(
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

BattleWorld _newWorld({int startingPrayerPower = 50, List<UnitDef>? formation}) => BattleWorld(
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
    formation: formation ?? const [_cheap, _expensive],
    startingPrayerPower: startingPrayerPower,
  ),
  rngSeed: 1,
  datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
  systems: const [],
)..phase = BattlePhase.running;

Future<void> _pumpHud(WidgetTester tester, BattleWorld world) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: BattleHud(world: world, speedMultiplier: 1.0, onSpeedChanged: (_) {}),
    ),
  ),
);

void main() {
  testWidgets('the prayer gauge shows a tick for the slot the player cannot yet afford', (tester) async {
    final world = _newWorld(startingPrayerPower: 50); // slot 0 costs 100
    await _pumpHud(tester, world);

    expect(find.byKey(const ValueKey('prayer_tick_100')), findsOneWidget);
  });

  testWidgets('tapping a too-expensive slot toasts "집중 강화가 필요합니다"', (tester) async {
    final world = _newWorld(startingPrayerPower: 999999);
    await _pumpHud(tester, world);

    await tester.tap(find.byKey(const ValueKey('summon_slot_1'))); // CHR_EXPENSIVE
    await tester.pump();

    expect(find.text('집중 강화가 필요합니다'), findsOneWidget);
  });

  testWidgets('tapping an unaffordable slot toasts "기도력이 부족합니다"', (tester) async {
    final world = _newWorld(startingPrayerPower: 0);
    await _pumpHud(tester, world);

    await tester.tap(find.byKey(const ValueKey('summon_slot_0')));
    await tester.pump();

    expect(find.text('기도력이 부족합니다'), findsOneWidget);
  });

  testWidgets('tapping a slot on cooldown toasts the cooldown message', (tester) async {
    final world = _newWorld(startingPrayerPower: 200);
    await _pumpHud(tester, world);

    await tester.tap(find.byKey(const ValueKey('summon_slot_0'))); // 성공 -> 쿨다운 진입
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('summon_slot_0'))); // 바로 다시 -> 쿨다운 중
    await tester.pump();

    expect(find.text('아직 재사용 대기 중입니다'), findsOneWidget);
  });

  testWidgets('tapping a slot while the ally side is at the unit cap toasts the cap message', (tester) async {
    final world = _newWorld(startingPrayerPower: 999999);
    for (var i = 0; i < unitCap; i++) {
      world.spawnEntity(_cheap, Side.ally, 0);
    }
    await _pumpHud(tester, world);

    await tester.tap(find.byKey(const ValueKey('summon_slot_0')));
    await tester.pump();

    expect(find.text('더 이상 소환할 수 없습니다(상한 도달)'), findsOneWidget);
  });

  testWidgets('a successful summon shows no toast', (tester) async {
    final world = _newWorld(startingPrayerPower: 200);
    await _pumpHud(tester, world);

    await tester.tap(find.byKey(const ValueKey('summon_slot_0')));
    await tester.pump();

    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('a formation over 5 slots shows page tabs, and switching pages changes the visible slots', (
    tester,
  ) async {
    final formation = [for (var i = 0; i < 7; i++) _cheap];
    final world = _newWorld(startingPrayerPower: 200, formation: formation);
    await _pumpHud(tester, world);

    expect(find.byKey(const ValueKey('summon_slot_0')), findsOneWidget);
    expect(find.byKey(const ValueKey('summon_slot_5')), findsNothing); // 아직 1페이지

    await tester.tap(find.byKey(const ValueKey('page_tab_1')));
    await tester.pump();

    expect(find.byKey(const ValueKey('summon_slot_5')), findsOneWidget);
    expect(find.byKey(const ValueKey('summon_slot_0')), findsNothing);
  });

  /// 10_WIRING_PLAN.md T-60: 소환/필살기가 실제로 성사됐을 때만 기록용
  /// 콜백이 불린다(제출용 입력 로그 재료).
  testWidgets('onSummon fires only when the summon actually succeeds', (tester) async {
    final world = _newWorld(startingPrayerPower: 200);
    int? summoned;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BattleHud(world: world, speedMultiplier: 1.0, onSpeedChanged: (_) {}, onSummon: (i) => summoned = i),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('summon_slot_1'))); // CHR_EXPENSIVE, 감당 못 함
    await tester.pump();
    expect(summoned, isNull);

    await tester.tap(find.byKey(const ValueKey('summon_slot_0')));
    await tester.pump();
    expect(summoned, 0);
  });

  testWidgets('onUltimate fires when the ultimate button is tapped', (tester) async {
    final world = _newWorld()..ultimateStock = 1;
    var ultimateFired = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BattleHud(
            world: world,
            speedMultiplier: 1.0,
            onSpeedChanged: (_) {},
            onUltimate: () => ultimateFired = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('ultimate_button')));
    await tester.pump();

    expect(ultimateFired, isTrue);
  });
}
