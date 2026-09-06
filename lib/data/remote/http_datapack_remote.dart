import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../firebase_options.dart';
import '../datapack/datapack_manifest.dart';

/// 06_BACKEND.md §5: `gs://<bucket>/datapack/<version>/*`, storage.rules상
/// 공개 읽기(`allow read: if true`)라 인증 없이 Firebase Storage의 공개
/// 다운로드 URL로 바로 받는다. firebase_storage 플러그인 대신 이미 쓰고
/// 있는 `http` 패키지로 충분하다.
Uri _datapackFileUrl(String dataVersion, String relativePath) {
  final objectPath = Uri.encodeComponent('datapack/$dataVersion/$relativePath');
  return Uri.parse(
    'https://firebasestorage.googleapis.com/v0/b/${DefaultFirebaseOptions.web.storageBucket}/o/$objectPath?alt=media',
  );
}

/// [DatapackSync]와 같은 이유로 단위 테스트하지 않는 실제 네트워크 배관.
Future<DatapackManifest> fetchDatapackManifestHttp(String dataVersion) async {
  final res = await http.get(_datapackFileUrl(dataVersion, 'manifest.json'));
  if (res.statusCode != 200) throw StateError('manifest.json 다운로드 실패: ${res.statusCode}');
  return DatapackManifest.fromJson(jsonDecode(res.body) as Map<String, Object?>);
}

Future<List<int>> fetchDatapackFileHttp(String dataVersion, String relativePath) async {
  final res = await http.get(_datapackFileUrl(dataVersion, relativePath));
  if (res.statusCode != 200) throw StateError('$relativePath 다운로드 실패: ${res.statusCode}');
  return res.bodyBytes;
}
