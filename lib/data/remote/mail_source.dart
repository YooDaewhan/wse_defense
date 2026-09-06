import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/mail/mail_item.dart';

/// firestore.rules: `users/{uid}/{sub=**}`는 본인 읽기 허용, 쓰기는 항상
/// Functions만(claimMail) -- 이 파일은 그 읽기 절반만 맡는다. 순수
/// 배관이라(firestore_datapack_version_source.dart와 같은 이유) 단위
/// 테스트하지 않는다.
Stream<List<MailItem>> watchMail(String uid) {
  return FirebaseFirestore.instance.collection('users/$uid/mail').snapshots().map(
    (snapshot) => [for (final doc in snapshot.docs) _mailItemFromDoc(doc.id, doc.data())],
  );
}

MailItem _mailItemFromDoc(String id, Map<String, dynamic> data) {
  final expireAtRaw = data['expireAt'];
  return MailItem(
    id: id,
    titleKey: data['titleKey'] as String? ?? '',
    bodyKey: data['bodyKey'] as String? ?? '',
    attachments: [
      for (final a in (data['attachments'] as List? ?? const []))
        (item: (a as Map)['item'] as String, amount: (a['amount'] as num).toInt()),
    ],
    claimed: data['claimedAt'] != null,
    expireAt: expireAtRaw is num ? DateTime.fromMillisecondsSinceEpoch(expireAtRaw.toInt()) : null,
  );
}
