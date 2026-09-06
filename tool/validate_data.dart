import 'dart:io';

import 'package:wse_defense/data/datapack/datapack_loader.dart';
import 'package:wse_defense/data/gacha/banner_data_loader.dart';

/// 04_DATA_SCHEMA.md §14: 번들 데이터팩을 로딩해보고 경고가 하나라도
/// 나오면 CI를 깨뜨린다 (참조 무결성 검사는 DatapackLoader가 이미 수행).
/// "banner rates 합계 == 100000"도 여기서 같이 검사한다.
Future<void> main() async {
  final warnings = <String>[];
  final readJson = (String path) => File('assets/data/v1/$path').readAsString();
  final loader = DatapackLoader(readJson, onWarning: warnings.add);

  final pack = await loader.load();

  final catalog = await loadBannerCatalog(readJson);
  for (final banner in catalog.banners) {
    final sum = banner.rates.fold<int>(0, (acc, r) => acc + r.totalPct);
    if (sum != 100000) {
      warnings.add('${banner.id}: rates 합계가 100000이 아님 (실제 $sum)');
    }
  }

  if (warnings.isEmpty) {
    stdout.writeln(
      'validate_data: OK '
      '(characters=${pack.characters.length}, '
      'enemies=${pack.enemies.length}, '
      'stages=${pack.stages.length}, '
      'banners=${catalog.banners.length})',
    );
    return;
  }

  for (final w in warnings) {
    stderr.writeln('validate_data: $w');
  }
  stderr.writeln('validate_data: ${warnings.length}개 문제 발견');
  exit(1);
}
