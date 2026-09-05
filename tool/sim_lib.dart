import 'dart:convert';
import 'dart:io';

import 'package:wse_defense/battle/constants.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/entity/entity_state.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/battle/world/canonical_systems.dart';
import 'package:wse_defense/battle/world/summon.dart';
import 'package:wse_defense/battle/world/ultimate.dart';

/// tool/headless_sim.dart + tool/balance_sweep.dart 공유 로직
/// (03_BATTLE_ENGINE.md §15).
///
/// 태그/날씨/스킬 데이터 로더는 아직 없어(TagRegistry·skills.json 로딩은
/// T-21 스코프 밖) 반영하지 않는다 — BattleConfig 기본값(빈 태그 레지스트리,
/// 빈 skillDefs)을 그대로 쓴다.
class SimResult {
  const SimResult({
    required this.outcome,
    required this.finalTick,
    required this.allySummons,
    required this.allyDeaths,
    required this.frontlineX,
  });

  final BattleOutcome? outcome;
  final int finalTick;
  final int allySummons;
  final int allyDeaths;

  /// 살아있는 아군의 평균 x(논리 단위). 전멸했으면 모닥불 위치.
  final int frontlineX;

  double get clearSec => finalTick / ticksPerSec;
  bool get isWin => outcome == BattleOutcome.allyWin;
}

/// 실제 플레이어 AI(별도 티켓 스코프)가 아직 없어, 이 도구는 "감당 가능한
/// 슬롯을 편성 순서대로 하나씩, 매 틱 최대 1마리" 소환하고 필살기가 차면
/// 즉시 쓰는 가장 단순한 정책으로 자동 진행한다.
SimResult runHeadlessBattle({
  required StageDef stage,
  required List<UnitDef> formation,
  required Datapack datapack,
  required int seed,
  int allyBaseHp = 10000, // growth.json(T-30) 전까지의 자리 표시자
  void Function(BattleWorld world)? onTick,
}) {
  final config = BattleConfig(stage: stage, allyBaseHp: allyBaseHp, formation: formation);
  final world = BattleWorld(
    config: config,
    rngSeed: seed,
    datapack: datapack,
    systems: canonicalBattleSystems(),
  )..phase = BattlePhase.running;

  final maxTicks = stage.timeLimitSec * ticksPerSec + ticksPerSec; // 시간초과 판정 여유 1초
  while (world.phase == BattlePhase.running && world.tick < maxTicks) {
    for (var slot = 0; slot < world.formation.length; slot++) {
      if (trySummon(world, slot) == SummonResult.ok) break;
    }
    if (world.ultimateStock > 0) castUltimate(world);
    world.step();
    world.drainEvents(); // 이 도구는 이벤트를 쓰지 않는다 -- 그냥 버려서 누적 방지(T-25)
    onTick?.call(world);
  }

  final allySummons = world.entities.ordered.where((e) => e.side == Side.ally).length;
  final allyDeaths = world.entities.ordered
      .where((e) => e.side == Side.ally && e.action == EntityAction.dead)
      .length;
  final aliveAllyXs = [
    for (final e in world.entities.ordered)
      if (e.side == Side.ally && e.isAlive) e.x,
  ];
  final frontlineX = aliveAllyXs.isEmpty
      ? world.allyBase.x ~/ posScale
      : (aliveAllyXs.reduce((a, b) => a + b) ~/ aliveAllyXs.length) ~/ posScale;

  return SimResult(
    outcome: world.outcome,
    finalTick: world.tick,
    allySummons: allySummons,
    allyDeaths: allyDeaths,
    frontlineX: frontlineX,
  );
}

/// 편성 JSON: `["CHR_ACORN", ...]`(id 목록) 또는
/// `{"id": "preset_a", "units": [...]}` 둘 다 받는다.
({String id, List<UnitDef> units}) loadFormationFile(String path, Datapack pack) {
  final raw = jsonDecode(File(path).readAsStringSync());
  final rawIds = raw is List ? raw : (raw as Map<String, Object?>)['units'] as List;
  final id = raw is Map<String, Object?>
      ? (raw['id'] as String? ?? _stemOf(path))
      : _stemOf(path);

  final units = <UnitDef>[];
  for (final rawId in rawIds) {
    final def = pack.characterById(rawId as String);
    if (def == null) {
      stderr.writeln('$path: 알 수 없는 캐릭터 id "$rawId", 건너뜀');
      continue;
    }
    units.add(def);
  }
  return (id: id, units: units);
}

String _stemOf(String path) {
  final base = path.split(Platform.pathSeparator).last.split('/').last;
  final dot = base.lastIndexOf('.');
  return dot == -1 ? base : base.substring(0, dot);
}
