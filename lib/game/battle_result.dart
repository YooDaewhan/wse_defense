import '../battle/constants.dart';
import '../battle/defs/unit_def.dart';
import '../battle/entity/entity_state.dart';
import '../battle/tag/tag_query.dart';
import '../battle/world/battle_world.dart';

/// game_design_final.md §7 "패배 화면": 전선 붕괴 시점·주요 적·사용한
/// 편성을 보여주고, **전투 기록으로 실제로 확인되는 원인에 한해서만**
/// 짧은 힌트를 준다 — 추측성 조언(예: "다음엔 이걸 써보세요")은 만들지
/// 않는다. `BattleWorld`가 끝난 뒤(EntityStore가 죽은 엔티티도 그대로
/// 들고 있으므로) 이 요약은 순수하게 그 최종 상태만 읽어서 계산한다.
class BattleResultSummary {
  const BattleResultSummary({
    required this.outcome,
    required this.frontlineCollapseTick,
    required this.mainEnemy,
    required this.formationUsed,
    required this.hints,
    required this.clearSec,
    required this.summons,
    required this.kills,
  });

  final BattleOutcome? outcome;

  /// 마지막 아군이 쓰러진 tick — 아군 사망이 한 번도 없었으면 null.
  final int? frontlineCollapseTick;

  /// 보스가 등장했으면 보스, 아니면 붕괴 시점에 아군 기지에 가장 가까이
  /// 있던(가장 위협적인) 살아있는 적.
  final UnitDef? mainEnemy;

  final List<UnitDef> formationUsed;

  /// 전투 기록에서 실제로 확인된 원인에 한해서만 채워진다(추측 없음).
  final List<String> hints;

  final double clearSec;
  final int summons;
  final int kills;

  bool get isWin => outcome == BattleOutcome.allyWin;
}

/// 교대 소환 부족 판단 기준 — 문서에 구체적 수치가 없어 임의로 30초로
/// 잡는다(밸런스 조정 시 바뀔 수 있는 값이라 상수로 분리).
const int _staggerGapWarningTicks = 30 * ticksPerSec;

BattleResultSummary computeBattleResult(BattleWorld w) {
  final formationUsed = [for (final slot in w.formation) slot.def];
  final entities = w.entities.ordered.toList();

  final allyDeaths = [
    for (final e in entities)
      if (e.side == Side.ally && e.action == EntityAction.dead) e,
  ];
  int? collapseTick;
  for (final e in allyDeaths) {
    final t = e.deathTick;
    if (t != null && (collapseTick == null || t > collapseTick)) collapseTick = t;
  }

  UnitDef? boss;
  for (final e in entities) {
    if (e.side == Side.enemy && e.def.isBoss) {
      boss = e.def;
      break;
    }
  }

  var mainEnemy = boss;
  if (mainEnemy == null) {
    final aliveEnemies = [
      for (final e in entities)
        if (e.side == Side.enemy && e.isAlive) e,
    ]..sort((a, b) => a.x.compareTo(b.x)); // 아군 기지는 x가 작은 쪽 -> 가장 가까운 적이 가장 위협적
    if (aliveEnemies.isNotEmpty) mainEnemy = aliveEnemies.first.def;
  }

  // game_design_final.md §7: 힌트는 "패배 화면"의 몫 — 이겼으면 애초에
  // 원인을 짚을 이유가 없다.
  final hints = <String>[];
  if (w.outcome != BattleOutcome.allyWin) {
    if (!formationUsed.any((d) => d.role == 'ROLE_DEFENDER')) {
      hints.add('편성에 방어형이 없습니다.');
    }
    if (mainEnemy != null) {
      final maxFormationRange = formationUsed.isEmpty
          ? 0
          : formationUsed.map((d) => d.base.attackRange).reduce((a, b) => a > b ? a : b);
      if (mainEnemy.base.attackRange > maxFormationRange) {
        hints.add('상대(${mainEnemy.nameKey})의 사거리가 편성의 최대 사거리보다 깁니다.');
      }
    }
    final allySpawnTicks = [
      for (final e in entities)
        if (e.side == Side.ally) e.spawnTick,
    ]..sort();
    for (var i = 1; i < allySpawnTicks.length; i++) {
      if (allySpawnTicks[i] - allySpawnTicks[i - 1] > _staggerGapWarningTicks) {
        hints.add('소환 사이 공백이 길었습니다. 교대 소환을 활용하세요.');
        break;
      }
    }
  }

  final summons = entities.where((e) => e.side == Side.ally).length;
  final kills = entities.where((e) => e.side == Side.enemy && e.action == EntityAction.dead).length;

  return BattleResultSummary(
    outcome: w.outcome,
    frontlineCollapseTick: collapseTick,
    mainEnemy: mainEnemy,
    formationUsed: formationUsed,
    hints: hints,
    clearSec: w.tick / ticksPerSec,
    summons: summons,
    kills: kills,
  );
}
