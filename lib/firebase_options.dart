import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// 06_BACKEND.md §10 로컬 개발 환경. `demo-` 접두 프로젝트 ID는 Firebase
/// 에뮬레이터 스위트가 "실제 GCP 프로젝트 없이도" 인식하는 특수 값이라,
/// 아래 값들은 전부 에뮬레이터 전용 자리 표시자다 — 실제 배포 전에는
/// `flutterfire configure`로 이 파일을 실제 프로젝트 값으로 덮어써야 한다.
class DefaultFirebaseOptions {
  static const String demoProjectId = 'demo-wse-defense';

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: demoProjectId,
    authDomain: '$demoProjectId.firebaseapp.com',
    storageBucket: '$demoProjectId.appspot.com',
  );
}
