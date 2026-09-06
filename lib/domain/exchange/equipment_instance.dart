/// 06_BACKEND.md §2 `users/{uid}/equipments/{instanceId}`의 화면용 사본.
class EquipmentInstance {
  const EquipmentInstance({
    required this.id,
    required this.equipmentId,
    required this.enhanceLevel,
    required this.equippedTo,
  });

  final String id;

  /// `EquipmentDef.id` -- 카탈로그(`equipmentById`) 조회 키.
  final String equipmentId;
  final int enhanceLevel;

  /// 장착 중인 캐릭터 id, 미장착이면 null.
  final String? equippedTo;
}
