import 'dart:io';

/// 01_ARCHITECTURE.md §1 규칙 1: lib/battle/**는 package:flutter,
/// package:flame, dart:ui, dart:io를 import할 수 없다.
/// (import_lint 대신 순수 dart:io 스크립트로 검사 — freezed 4.x가 요구하는
/// analyzer >=13.0.0과 import_lint의 analyzer ^12.1.0 고정이 충돌해서 교체함.)
const _forbidden = [
  "package:flutter/",
  "package:flame/",
  'dart:ui',
  'dart:io',
];

Future<void> main() async {
  final dir = Directory('lib/battle');
  if (!dir.existsSync()) {
    stdout.writeln('check_battle_imports: lib/battle 없음, 통과');
    return;
  }

  final violations = <String>[];
  await for (final entity in dir.list(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final lines = await entity.readAsLines();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (!line.startsWith('import ')) continue;
      for (final banned in _forbidden) {
        if (line.contains(banned)) {
          violations.add('${entity.path}:${i + 1}: $line');
        }
      }
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('check_battle_imports: OK');
    return;
  }

  for (final v in violations) {
    stderr.writeln('check_battle_imports: 금지된 import - $v');
  }
  exit(1);
}
