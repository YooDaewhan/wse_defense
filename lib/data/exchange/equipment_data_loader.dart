import 'dart:convert';

import '../../domain/exchange/equipment_def.dart';
import '../datapack/datapack_loader.dart' show AssetReader;

Future<EquipmentCatalog> loadEquipmentCatalog(AssetReader readJson) async {
  final raw = jsonDecode(await readJson('equipments.json')) as Map<String, Object?>;
  return EquipmentCatalog.fromJson(raw);
}
