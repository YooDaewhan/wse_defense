import 'dart:io';
import 'dart:math';

import 'package:wse_defense/data/datapack/datapack_loader.dart';

import 'sim_lib.dart';

/// 03_BATTLE_ENGINE.md §15.
///   dart run tool/balance_sweep.dart --stage STG_1_10 --trials 200 \
///     --formations "formations/*.json" --weather on,off --out reports/stage_1_10.csv
///
/// WeatherSystem은 아직 없어(T-45 스코프) `--weather`는 CSV의 `weather`
/// 컬럼 라벨로만 받아둔다 — on/off가 실제로 다른 결과를 내지는 않는다.
Future<void> main(List<String> args) async {
  final opts = _parseArgs(args);
  final stageId = opts['stage'];
  final trials = int.parse(opts['trials'] ?? '200');
  final formationsGlob = opts['formations'];
  final weatherLabels = (opts['weather'] ?? 'off').split(',');
  final outPath = opts['out'];

  if (stageId == null || formationsGlob == null || outPath == null) {
    stderr.writeln(
      '사용법: dart run tool/balance_sweep.dart --stage <id> --trials <n> '
      '--formations <glob> --weather <a,b> --out <csv경로>',
    );
    exit(64);
  }

  final pack = await DatapackLoader(
    (path) => File('assets/data/v1/$path').readAsString(),
  ).load();
  final stage = pack.stageById(stageId);
  if (stage == null) {
    stderr.writeln('알 수 없는 스테이지: $stageId');
    exit(1);
  }

  final formationPaths = _expandGlob(formationsGlob);
  if (formationPaths.isEmpty) {
    stderr.writeln('편성 파일을 찾지 못함: $formationsGlob');
    exit(1);
  }

  final sw = Stopwatch()..start();
  final rows = <String>[
    'formationId,weather,winRate,avgClearSec,avgSummons,avgFrontlineX,p95ClearSec,deathsPerMin',
  ];

  for (final path in formationPaths) {
    final formation = loadFormationFile(path, pack);
    if (formation.units.isEmpty) continue;

    for (final weather in weatherLabels) {
      final results = [
        for (var i = 0; i < trials; i++)
          runHeadlessBattle(
            stage: stage,
            formation: formation.units,
            datapack: pack,
            seed: i, // 트라이얼마다 다른 시드 -> 서로 다른 스킬 발동 판정 등
          ),
      ];
      rows.add(_summaryRow(formation.id, weather, results));
    }
  }

  File(outPath).parent.createSync(recursive: true);
  File(outPath).writeAsStringSync('${rows.join('\n')}\n');
  stdout.writeln(
    '$outPath 저장 완료 (${rows.length - 1}행, ${sw.elapsedMilliseconds}ms)',
  );
}

String _summaryRow(String formationId, String weather, List<SimResult> results) {
  final n = results.length;
  final wins = results.where((r) => r.isWin).length;
  final clearSecs = [for (final r in results) r.clearSec]..sort();
  final avgClearSec = clearSecs.reduce((a, b) => a + b) / n;
  final avgSummons = results.map((r) => r.allySummons).reduce((a, b) => a + b) / n;
  final avgFrontlineX = results.map((r) => r.frontlineX).reduce((a, b) => a + b) / n;
  final p95ClearSec = clearSecs[min(n - 1, (n * 0.95).floor())];
  final totalDeaths = results.map((r) => r.allyDeaths).reduce((a, b) => a + b);
  final totalMinutes = clearSecs.reduce((a, b) => a + b) / 60;
  final deathsPerMin = totalMinutes == 0 ? 0.0 : totalDeaths / totalMinutes;

  return [
    formationId,
    weather,
    (wins / n).toStringAsFixed(3),
    avgClearSec.toStringAsFixed(1),
    avgSummons.toStringAsFixed(1),
    avgFrontlineX.toStringAsFixed(1),
    p95ClearSec.toStringAsFixed(1),
    deathsPerMin.toStringAsFixed(2),
  ].join(',');
}

/// `dir/*.ext` 형태 하나만 지원한다(문서 예시와 동일) — 그 이상의 glob
/// 문법은 이 도구가 필요로 하지 않는다. `*`가 없으면 콤마로 구분된 여러
/// 경로로 취급한다.
List<String> _expandGlob(String pattern) {
  if (!pattern.contains('*')) return pattern.split(',');

  final slash = pattern.lastIndexOf('/');
  final dir = slash == -1 ? '.' : pattern.substring(0, slash);
  final namePattern = pattern.substring(slash + 1);
  final prefix = namePattern.substring(0, namePattern.indexOf('*'));
  final suffix = namePattern.substring(namePattern.indexOf('*') + 1);

  final d = Directory(dir);
  if (!d.existsSync()) return const [];
  return [
    for (final f in d.listSync())
      if (f is File)
        if (_matchesGlobPart(f.uri.pathSegments.last, prefix, suffix)) f.path,
  ]..sort();
}

bool _matchesGlobPart(String name, String prefix, String suffix) =>
    name.startsWith(prefix) && name.endsWith(suffix);

Map<String, String> _parseArgs(List<String> args) {
  final result = <String, String>{};
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (!a.startsWith('--')) continue;
    final key = a.substring(2);
    final hasValue = i + 1 < args.length && !args[i + 1].startsWith('--');
    result[key] = hasValue ? args[++i] : '1';
  }
  return result;
}
