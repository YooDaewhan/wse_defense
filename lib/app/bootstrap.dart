import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';

const useFirebaseEmulator = bool.fromEnvironment('USE_EMULATOR');

/// 06_BACKEND.md §10: 앱 시작 시 1회. `--dart-define=USE_EMULATOR=true`이면
/// 로컬 Auth/Functions 에뮬레이터로 연결한다.
Future<void> bootstrapFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (useFirebaseEmulator) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFunctions.instanceFor(region: 'asia-northeast3').useFunctionsEmulator('localhost', 5001);
  }
}

/// 06_BACKEND.md §6.1 "첫 실행 → signInAnonymously()". 이미 로그인된 세션이
/// 있으면(재실행) 그 유저를 그대로 쓴다.
Future<User> signInAnonymouslyIfNeeded() async {
  final current = FirebaseAuth.instance.currentUser;
  if (current != null) return current;
  final credential = await FirebaseAuth.instance.signInAnonymously();
  return credential.user!;
}
