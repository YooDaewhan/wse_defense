import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/account/account_bootstrap.dart';
import '../../domain/account/account_state.dart';
import 'api.dart' as api;

/// 10_WIRING_PLAN.md T-63 준비: 앱 시작 시 `bootstrapAccount`를 불러(계정
/// 문서가 없으면 이때 만들어짐 -- 06_BACKEND.md §6.1) 실제 [AccountState]로
/// 채운다. 지금까지는 이 호출 자체가 어디서도 일어나지 않아
/// `scope.account`가 항상 기본값(gold 0, 캐릭터 0개)에서 시작했다(T-62
/// 조사 중 발견).
///
/// 순수 배관이라(Firebase 플러그인은 flutter test(VM)에서 못 돌림 --
/// firestore_datapack_version_source.dart와 같은 한계) 단위 테스트하지
/// 않는다 -- 매핑 로직은 accountStateFromBootstrap이 이미 검증한다.
Future<AccountState> loadAccountAfterBootstrap(String uid) async {
  final res = await api.bootstrapAccount(appVersion: '1.0.0', dataVersion: api.kDataVersion);
  final data = Map<String, dynamic>.from(res['data'] as Map);
  final charactersSnap = await FirebaseFirestore.instance.collection('users/$uid/characters').get();
  return accountStateFromBootstrap(data, {for (final doc in charactersSnap.docs) doc.id});
}
