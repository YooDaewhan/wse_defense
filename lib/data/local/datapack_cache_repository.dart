import 'package:hive/hive.dart';

/// `DatapackSync`가 실제로 필요로 하는 표면 — Hive 구현과 테스트용 인메모리
/// 구현이 공유한다(다른 Store들과 같은 이유).
abstract class DatapackCacheStore {
  /// 최신 순. 최대 [maxKeptVersions]개만 유지된다.
  List<String> get cachedVersionsNewestFirst;
  Map<String, String>? filesFor(String dataVersion);
  void save(String dataVersion, Map<String, String> files);
}

/// 06_BACKEND.md §5 "클라이언트는 로컬에 이전 버전 캐시를 1개 유지하므로
/// 즉시 복구된다" — 그래서 최신 버전과 그 바로 이전 버전, 총 2개만 남기고
/// 더 오래된 캐시는 지운다.
class DatapackCacheRepository implements DatapackCacheStore {
  DatapackCacheRepository(this._box);

  static const boxName = 'datapackCache';
  static const maxKeptVersions = 2;
  final Box _box;

  @override
  List<String> get cachedVersionsNewestFirst =>
      (_box.get('_order') as List<Object?>?)?.cast<String>() ?? <String>[];

  @override
  Map<String, String>? filesFor(String dataVersion) {
    final raw = _box.get('files:$dataVersion') as Map?;
    return raw == null ? null : Map<String, String>.from(raw);
  }

  @override
  void save(String dataVersion, Map<String, String> files) {
    final order = [dataVersion, ...cachedVersionsNewestFirst.where((v) => v != dataVersion)];
    _box.put('files:$dataVersion', files);
    while (order.length > maxKeptVersions) {
      final dropped = order.removeLast();
      _box.delete('files:$dropped');
    }
    _box.put('_order', order);
  }
}
