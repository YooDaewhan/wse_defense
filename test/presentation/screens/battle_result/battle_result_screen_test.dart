import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/game/battle_result.dart';
import 'package:wse_defense/presentation/screens/battle_result/battle_result_screen.dart';

const _defender = UnitDef(
  id: 'CHR_DEFENDER',
  nameKey: 'chr.defender',
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

Future<void> _pump(WidgetTester tester, BattleResultSummary result) =>
    tester.pumpWidget(MaterialApp(home: BattleResultScreen(result: result)));

void main() {
  testWidgets('a loss shows frontline collapse time, main enemy, and the formation used', (tester) async {
    const result = BattleResultSummary(
      outcome: BattleOutcome.enemyWin,
      frontlineCollapseTick: 300, // 10초
      mainEnemy: _defender, // 실제로는 적 def지만 텍스트 렌더만 확인하면 되므로 재사용
      formationUsed: [_defender],
      hints: [],
      clearSec: 45.0,
      summons: 3,
      kills: 2,
    );
    await _pump(tester, result);

    expect(find.text('패배'), findsOneWidget);
    expect(find.byKey(const ValueKey('frontline_collapse')), findsOneWidget);
    expect(find.textContaining('10.0초'), findsOneWidget);
    expect(find.byKey(const ValueKey('main_enemy')), findsOneWidget);
    expect(find.byKey(const ValueKey('formation_used')), findsOneWidget);
    expect(find.text('chr.defender'), findsOneWidget); // 사용한 편성에 표시됨
  });

  testWidgets('hints render only the ones the summary actually contains', (tester) async {
    const result = BattleResultSummary(
      outcome: BattleOutcome.enemyWin,
      frontlineCollapseTick: 100,
      mainEnemy: null,
      formationUsed: [],
      hints: ['편성에 방어형이 없습니다.', '소환 사이 공백이 길었습니다. 교대 소환을 활용하세요.'],
      clearSec: 20,
      summons: 1,
      kills: 0,
    );
    await _pump(tester, result);

    expect(find.byKey(const ValueKey('hints')), findsOneWidget);
    expect(find.textContaining('방어형'), findsOneWidget);
    expect(find.textContaining('교대 소환'), findsOneWidget);
  });

  testWidgets('a win shows no hints/collapse/enemy section, and a reward placeholder', (tester) async {
    const result = BattleResultSummary(
      outcome: BattleOutcome.allyWin,
      frontlineCollapseTick: null,
      mainEnemy: null,
      formationUsed: [_defender],
      hints: [],
      clearSec: 90,
      summons: 5,
      kills: 4,
    );
    await _pump(tester, result);

    expect(find.text('승리!'), findsOneWidget);
    expect(find.byKey(const ValueKey('reward_placeholder')), findsOneWidget);
    expect(find.byKey(const ValueKey('frontline_collapse')), findsNothing);
    expect(find.byKey(const ValueKey('hints')), findsNothing);
  });

  testWidgets('a loss with no ally deaths shows "no collapse" rather than a bogus time', (tester) async {
    const result = BattleResultSummary(
      outcome: BattleOutcome.timeout,
      frontlineCollapseTick: null,
      mainEnemy: null,
      formationUsed: [],
      hints: [],
      clearSec: 300,
      summons: 2,
      kills: 1,
    );
    await _pump(tester, result);

    expect(find.text('전선 붕괴: 없음'), findsOneWidget);
  });
}
