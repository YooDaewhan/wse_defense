import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../local/datapack_cache_repository.dart';
import 'datapack_manifest.dart';

typedef RemoteDatapackVersion = ({String dataVersion, String minAppVersion});
typedef RemoteVersionFetcher = Future<RemoteDatapackVersion?> Function();
typedef ManifestFetcher = Future<DatapackManifest> Function(String dataVersion);
typedef RemoteFileFetcher = Future<List<int>> Function(String dataVersion, String relativePath);

class DatapackSyncResult {
  const DatapackSyncResult({required this.dataVersion, required this.useBundledAssets});

  /// 실제로 써야 할 데이터 버전 — 번들 버전이거나, 성공적으로 검증된 원격
  /// 버전(새로 받았거나 이미 캐시에 있던 것)이다.
  final String dataVersion;

  /// true면 [dataVersion]을 기존 `AssetReader`(rootBundle)로 읽으면 된다.
  /// 원격이 번들과 같은 버전이라 받을 게 없었던 경우와, 다운로드/검증에
  /// 실패해 번들로 폴백한 경우를 둘 다 포함한다 — 어느 쪽이든 호출부가
  /// 할 일은 같다(번들을 쓴다).
  final bool useBundledAssets;
}

/// 06_BACKEND.md §5. 원격 `gameData/current`와 번들 버전을 비교해서:
/// - 같으면 아무것도 하지 않는다(번들이 곧 최신).
/// - 이미 캐시에 있는 버전이면(롤백으로 이전 버전으로 되돌아간 경우 포함)
///   재다운로드 없이 그 캐시를 즉시 쓴다.
/// - 다르고 캐시에도 없으면 manifest를 받아 파일별로 다운로드+sha256
///   검증하고, 하나라도 실패하면(다운로드 오류든 해시 불일치든) 전부
///   버리고 번들로 폴백한다 — 부분 적용 없음.
class DatapackSync {
  DatapackSync({
    required this.fetchRemoteVersion,
    required this.fetchManifest,
    required this.fetchFile,
    required this.cache,
    required this.bundledDataVersion,
  });

  final RemoteVersionFetcher fetchRemoteVersion;
  final ManifestFetcher fetchManifest;
  final RemoteFileFetcher fetchFile;
  final DatapackCacheStore cache;
  final String bundledDataVersion;

  Future<DatapackSyncResult> sync() async {
    final RemoteDatapackVersion? remote;
    try {
      remote = await fetchRemoteVersion();
    } catch (_) {
      return DatapackSyncResult(dataVersion: bundledDataVersion, useBundledAssets: true);
    }

    if (remote == null || remote.dataVersion == bundledDataVersion) {
      return DatapackSyncResult(dataVersion: bundledDataVersion, useBundledAssets: true);
    }

    if (cache.filesFor(remote.dataVersion) != null) {
      return DatapackSyncResult(dataVersion: remote.dataVersion, useBundledAssets: false);
    }

    try {
      final manifest = await fetchManifest(remote.dataVersion);
      final files = <String, String>{};
      for (final entry in manifest.files.entries) {
        final bytes = await fetchFile(remote.dataVersion, entry.key);
        final actualHash = sha256.convert(bytes).toString();
        if (actualHash != entry.value) {
          throw StateError('sha256 mismatch: ${entry.key}');
        }
        files[entry.key] = utf8.decode(bytes);
      }
      cache.save(remote.dataVersion, files);
      return DatapackSyncResult(dataVersion: remote.dataVersion, useBundledAssets: false);
    } catch (_) {
      return DatapackSyncResult(dataVersion: bundledDataVersion, useBundledAssets: true);
    }
  }

  /// [sync]가 돌려준 dataVersion이 캐시된 원격 버전일 때 그 파일 내용을
  /// 읽는다. 번들 폴백이면 null(호출부가 기존 `AssetReader`를 쓴다).
  Map<String, String>? cachedFiles(String dataVersion) => cache.filesFor(dataVersion);
}
