import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/exchange/equipment_instance.dart';

/// firestore.rules: `users/{uid}/{sub=**}` 본인 읽기 허용, 쓰기는 항상
/// Functions만(equipItem/enhanceEquipment). 순수 배관이라
/// (firestore_datapack_version_source.dart와 같은 이유) 단위 테스트하지
/// 않는다.
Stream<List<EquipmentInstance>> watchEquipments(String uid) {
  return FirebaseFirestore.instance.collection('users/$uid/equipments').snapshots().map(
    (snapshot) => [
      for (final doc in snapshot.docs)
        EquipmentInstance(
          id: doc.id,
          equipmentId: doc.data()['equipmentId'] as String,
          enhanceLevel: (doc.data()['enhanceLevel'] as num?)?.toInt() ?? 0,
          equippedTo: doc.data()['equippedTo'] as String?,
        ),
    ],
  );
}
