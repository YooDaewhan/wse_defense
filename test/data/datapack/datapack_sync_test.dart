import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/data/datapack/datapack_manifest.dart';
import 'package:wse_defense/data/datapack/datapack_sync.dart';

import 'support/in_memory_datapack_cache_store.dart';

const _bundled = '1.0.0';

DatapackSync _sync({
  required InMemoryDatapackCacheStore cache,
  required RemoteVersionFetcher fetchRemoteVersion,
  ManifestFetcher? fetchManifest,
  RemoteFileFetcher? fetchFile,
}) => DatapackSync(
  fetchRemoteVersion: fetchRemoteVersion,
  fetchManifest: fetchManifest ?? (_) async => throw UnimplementedError(),
  fetchFile: fetchFile ?? (_, _) async => throw UnimplementedError(),
  cache: cache,
  bundledDataVersion: _bundled,
);

/// 09_MILESTONES.md T-40 완료조건: "버전 불일치 시 다운로드+sha256 검증,
/// 실패 시 번들 폴백, 롤백 즉시 반영".
void main() {
  test('when the remote version matches the bundle, nothing is downloaded', () async {
    var manifestCalls = 0;
    final sync = _sync(
      cache: InMemoryDatapackCacheStore(),
      fetchRemoteVersion: () async => (dataVersion: _bundled, minAppVersion: '1.0.0'),
      fetchManifest: (_) async {
        manifestCalls++;
        throw UnimplementedError();
      },
    );

    final res = await sync.sync();

    expect(res.dataVersion, _bundled);
    expect(res.useBundledAssets, isTrue);
    expect(manifestCalls, 0);
  });

  test('when the remote is offline (returns null), falls back to the bundle', () async {
    final sync = _sync(cache: InMemoryDatapackCacheStore(), fetchRemoteVersion: () async => null);
    final res = await sync.sync();
    expect(res.dataVersion, _bundled);
    expect(res.useBundledAssets, isTrue);
  });

  test('a new remote version downloads, verifies sha256, and is cached', () async {
    final fileBytes = utf8.encode('{"characters":[]}');
    final hash = sha256.convert(fileBytes).toString();
    final manifest = DatapackManifest(dataVersion: '1.0.1', files: {'characters.json': hash});
    final cache = InMemoryDatapackCacheStore();

    final sync = _sync(
      cache: cache,
      fetchRemoteVersion: () async => (dataVersion: '1.0.1', minAppVersion: '1.0.0'),
      fetchManifest: (v) async => manifest,
      fetchFile: (v, path) async => fileBytes,
    );

    final res = await sync.sync();

    expect(res.dataVersion, '1.0.1');
    expect(res.useBundledAssets, isFalse);
    expect(sync.cachedFiles('1.0.1'), {'characters.json': '{"characters":[]}'});
  });

  test('a sha256 mismatch discards everything and falls back to the bundle', () async {
    final fileBytes = utf8.encode('{"tampered":true}');
    final manifest = DatapackManifest(dataVersion: '1.0.1', files: {'characters.json': 'expected-hash-that-wont-match'});
    final cache = InMemoryDatapackCacheStore();

    final sync = _sync(
      cache: cache,
      fetchRemoteVersion: () async => (dataVersion: '1.0.1', minAppVersion: '1.0.0'),
      fetchManifest: (v) async => manifest,
      fetchFile: (v, path) async => fileBytes,
    );

    final res = await sync.sync();

    expect(res.dataVersion, _bundled);
    expect(res.useBundledAssets, isTrue);
    expect(cache.filesFor('1.0.1'), isNull);
  });

  test('a download failure falls back to the bundle without caching anything', () async {
    final cache = InMemoryDatapackCacheStore();
    final sync = _sync(
      cache: cache,
      fetchRemoteVersion: () async => (dataVersion: '1.0.1', minAppVersion: '1.0.0'),
      fetchManifest: (v) async => throw Exception('network down'),
    );

    final res = await sync.sync();

    expect(res.dataVersion, _bundled);
    expect(res.useBundledAssets, isTrue);
  });

  test('rollback: a remote version already in the cache is used immediately without re-downloading', () async {
    final cache = InMemoryDatapackCacheStore()..save('1.0.1', {'characters.json': 'old-content'});
    var manifestCalls = 0;

    final sync = _sync(
      cache: cache,
      fetchRemoteVersion: () async => (dataVersion: '1.0.1', minAppVersion: '1.0.0'),
      fetchManifest: (version) async {
        manifestCalls++;
        throw UnimplementedError();
      },
    );

    final res = await sync.sync();

    expect(res.dataVersion, '1.0.1');
    expect(res.useBundledAssets, isFalse);
    expect(manifestCalls, 0); // 이미 캐시에 있으므로 재다운로드하지 않는다
    expect(sync.cachedFiles('1.0.1'), {'characters.json': 'old-content'});
  });

  test('the cache keeps at most the current and previous version (rollback safety net)', () {
    final cache = InMemoryDatapackCacheStore()
      ..save('1.0.0', {'a': '1'})
      ..save('1.0.1', {'a': '2'})
      ..save('1.0.2', {'a': '3'});

    expect(cache.filesFor('1.0.0'), isNull); // 가장 오래된 건 밀려남
    expect(cache.filesFor('1.0.1'), isNotNull);
    expect(cache.filesFor('1.0.2'), isNotNull);
  });
}
