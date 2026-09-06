import 'dart:convert';

import '../../domain/exchange/exchange_def.dart';
import '../datapack/datapack_loader.dart' show AssetReader;

Future<ExchangeConfig> loadExchangeConfig(AssetReader readJson) async {
  final raw = jsonDecode(await readJson('exchange.json')) as Map<String, Object?>;
  return ExchangeConfig.fromJson(raw);
}
