import 'dart:io';

import 'package:wse_defense/data/datapack/datapack_loader.dart';

/// 04_DATA_SCHEMA.md §14: 번들 데이터팩을 로딩해보고 경고가 하나라도
/// 나오면 CI를 깨뜨린다 (참조 무결성 검사는 DatapackLoader가 이미 수행).
Future<void> main() async {
  final warnings = <String>[];
  final loader = DatapackLoader(
    (path) => File('assets/data/v1/$path').readAsString(),
    onWarning: warnings.add,
  );

  final pack = await loader.load();

  if (warnings.isEmpty) {
    stdout.writeln(
      'validate_data: OK '
      '(characters=${pack.characters.length}, '
      'enemies=${pack.enemies.length}, '
      'stages=${pack.stages.length})',
    );
    return;
  }

  for (final w in warnings) {
    stderr.writeln('validate_data: $w');
  }
  stderr.writeln('validate_data: ${warnings.length}개 문제 발견');
  exit(1);
}
