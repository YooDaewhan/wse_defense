import 'dart:io';

import 'package:wse_defense/battle/constants.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/data/datapack/datapack_loader.dart';

import 'sim_lib.dart';

/// 03_BATTLE_ENGINE.md §15.
///   dart run tool/headless_sim.dart --stage STG_1_10 --formation formations/preset_a.json --seed 12345 [-v]
Future<void> main(List<String> args) async {
  final opts = _parseArgs(args);
  final stageId = opts['stage'];
  final formationPath = opts['formation'];
  final seedRaw = opts['seed'];
  final verbose = opts.containsKey('v');

  if (stageId == null || formationPath == null || seedRaw == null) {
    stderr.writeln(
      '사용법: dart run tool/headless_sim.dart --stage <id> --formation <json경로> --seed <n> [-v]',
    );
    exit(64);
  }
  final seed = int.parse(seedRaw);

  final pack = await DatapackLoader(
    (path) => File('assets/data/v1/$path').readAsString(),
  ).load();

  final stage = pack.stageById(stageId);
  if (stage == null) {
    stderr.writeln('알 수 없는 스테이지: $stageId');
    exit(1);
  }

  final formation = loadFormationFile(formationPath, pack);
  if (formation.units.isEmpty) {
    stderr.writeln('편성이 비어있음: $formationPath');
    exit(1);
  }

  final result = runHeadlessBattle(
    stage: stage,
    formation: formation.units,
    datapack: pack,
    seed: seed,
    onTick: verbose ? _verboseTick : null,
  );

  stdout.writeln(
    'stage=$stageId formation=${formation.id} seed=$seed '
    'outcome=${result.outcome?.name ?? "timeout"} '
    'clearSec=${result.clearSec.toStringAsFixed(1)} '
    'summons=${result.allySummons} deaths=${result.allyDeaths} '
    'frontlineX=${result.frontlineX}',
  );
}

void _verboseTick(BattleWorld w) {
  if (w.tick % ticksPerSec != 0) return;
  stdout.writeln(
    '  t=${w.tick ~/ ticksPerSec}s ally=${w.allyAliveCount} enemy=${w.enemyAliveCount} '
    'prayer=${w.prayerPower} ultStock=${w.ultimateStock}',
  );
}

Map<String, String> _parseArgs(List<String> args) {
  final result = <String, String>{};
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (!a.startsWith('--')) {
      if (a == '-v') result['v'] = '1';
      continue;
    }
    final key = a.substring(2);
    final hasValue = i + 1 < args.length && !args[i + 1].startsWith('-');
    result[key] = hasValue ? args[++i] : '1';
  }
  return result;
}
