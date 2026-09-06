import 'package:wse_defense/data/local/datapack_cache_repository.dart';

class InMemoryDatapackCacheStore implements DatapackCacheStore {
  final Map<String, Map<String, String>> _files = {};
  final List<String> _order = [];

  @override
  List<String> get cachedVersionsNewestFirst => List.of(_order);

  @override
  Map<String, String>? filesFor(String dataVersion) => _files[dataVersion];

  @override
  void save(String dataVersion, Map<String, String> files) {
    _files[dataVersion] = files;
    _order
      ..removeWhere((v) => v == dataVersion)
      ..insert(0, dataVersion);
    while (_order.length > DatapackCacheRepository.maxKeptVersions) {
      final dropped = _order.removeLast();
      _files.remove(dropped);
    }
  }
}
