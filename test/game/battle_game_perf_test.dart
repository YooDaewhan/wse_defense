import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/constants.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/battle/world/canonical_systems.dart';
import 'package:wse_defense/game/battle_game.dart';

const _unit = UnitDef(
  id: 'T',
  base: UnitBaseStats(
    maxHp: 500,
    atk: 40,
    attackPeriod: 45,
    attackWindup: 10,
    attackRecover: 35,
    attackRange: 120,
    moveSpeed: 60,
    hpSegments: 2,
  ),
);

/// 05_FRONTEND.md T-25 완료조건: "유닛 80개 전투에서 프레임 드랍 없음".
///
/// 실제 프레임 드랍(DevTools raster/update ≤ 몇 ms) 측정은 실기 프로파일링
/// 영역이라 이 위젯 테스트로는 재현할 수 없다 — 대신 "80유닛(아군40+적40)이
/// 전부 싸우는 동안 60fps 렌더 루프 자체가 멈추거나 예외 없이 계속 도는가"
/// 를 벽시계 시간 상한으로 확인하는 대리 지표다. 진짜 프레임 타이밍
/// 확인은 T-25 보고서에 한계로 남긴다.
void main() {
  testWidgets('80 units (40 ally + 40 enemy) fighting keeps the render loop alive with no exceptions', (
    tester,
  ) async {
    final world = BattleWorld(
      config: const BattleConfig(
        stage: StageDef(
          id: 'STG_TEST_80',
          index: 1,
          fieldLength: 2400,
          allyBaseX: 0,
          enemyBaseX: 2400,
          enemyBaseHp: 100000,
          timeLimitSec: 300,
        ),
        allyBaseHp: 100000,
      ),
      rngSeed: 1,
      datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
      systems: canonicalBattleSystems(),
    )..phase = BattlePhase.running;

    for (var i = 0; i < 40; i++) {
      world.spawnEntity(_unit, Side.ally, (i * 20) * posScale);
      world.spawnEntity(_unit, Side.enemy, (2400 - i * 20) * posScale);
    }

    final game = BattleGame(battleWorld: world);
    final stopwatch = Stopwatch()..start();

    await tester.pumpWidget(MaterialApp(home: GameWidget(game: game)));
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    for (var i = 0; i < 120; i++) {
      // 120프레임 ≈ 2초 분량(60fps) -- 그동안 렌더 루프가 예외 없이 계속 돈다.
      await tester.pump(const Duration(milliseconds: 16));
    }
    stopwatch.stop();

    expect(tester.takeException(), isNull);
    expect(world.tick, greaterThan(0));
    // 위젯 테스트 하네스 자체의 오버헤드를 감안한 넉넉한 벽시계 상한 —
    // 실제 프레임 시간 보장이 아니라 "멈추지 않았다"는 것의 대리 확인.
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 30)));
  });
}
