import 'package:flutter/material.dart';

import '../../../domain/exchange/equipment_def.dart';
import '../../../domain/exchange/equipment_instance.dart';

/// functions/src/inventory/enhanceEquipment.ts의 사본 -- 서버가 진짜
/// 판정 기준이고, 여기서는 버튼을 미리 비활성화하는 용도로만 쓴다.
const maxEnhanceLevel = 10;

/// 05_FRONTEND.md §2 `/inventory`: 보유 장비 목록 + 강화. 장착
/// (equipItem)은 캐릭터를 골라야 하는 동작이라 캐릭터 상세 화면 몫으로
/// 남긴다 -- 여긴 보유 목록 열람과 강화만 다룬다.
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key, required this.instances, required this.equipmentById, required this.onEnhanceTap});

  final List<EquipmentInstance> instances;
  final Map<String, EquipmentDef> equipmentById;
  final void Function(String instanceId) onEnhanceTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('보관함')),
      body: instances.isEmpty
          ? const Center(child: Text('보유한 장비가 없습니다', key: ValueKey('inventory_empty')))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final instance in instances)
                  Card(
                    key: ValueKey('inventory_item_${instance.id}'),
                    child: ListTile(
                      title: Text(equipmentById[instance.equipmentId]?.nameKey ?? instance.equipmentId),
                      subtitle: Text(
                        '+${instance.enhanceLevel}'
                        '${instance.equippedTo == null ? ' (미장착)' : ' (${instance.equippedTo} 장착 중)'}',
                      ),
                      trailing: ElevatedButton(
                        key: ValueKey('inventory_enhance_${instance.id}'),
                        onPressed: instance.enhanceLevel >= maxEnhanceLevel ? null : () => onEnhanceTap(instance.id),
                        child: Text(instance.enhanceLevel >= maxEnhanceLevel ? '최대' : '강화'),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
