import 'package:cloud_firestore/cloud_firestore.dart';

import '../datapack/datapack_sync.dart';

/// 06_BACKEND.md §5 "부트스트랩 시 gameData/current 조회". 순수 배관이라
/// (Firebase 플러그인은 flutter test(VM)에서 실제로 못 돌린다 — T-35와
/// 같은 한계) 단위 테스트하지 않는다. 핵심 로직(`DatapackSync`)은 이
/// 함수와 같은 시그니처(`RemoteVersionFetcher`)의 가짜로 충분히 검증한다.
Future<RemoteDatapackVersion?> fetchCurrentDatapackVersionFromFirestore() async {
  final doc = await FirebaseFirestore.instance.doc('gameData/current').get();
  final data = doc.data();
  if (data == null) return null;
  return (dataVersion: data['dataVersion'] as String, minAppVersion: data['minAppVersion'] as String);
}
