import 'dart:convert';

import '../../domain/gacha/banner_def.dart';
import '../datapack/datapack_loader.dart' show AssetReader;

Future<BannerCatalog> loadBannerCatalog(AssetReader readJson) async {
  final raw = jsonDecode(await readJson('banners.json')) as Map<String, Object?>;
  return BannerCatalog.fromJson(raw);
}
