import 'package:flutter/material.dart';

import '../../../battle/defs/unit_def.dart';
import '../../../domain/exchange/equipment_def.dart';
import '../../../domain/exchange/equipment_instance.dart';

/// 05_FRONTEND.md §2 `/friends/:id`: "능력치·태그 칩·스킬·장비·이야기·
/// 스킨·음성". 스킬 상세/이야기/스킨/음성은 그 콘텐츠 자체가 아직
/// 없어(에셋 미제작) 능력치·태그·장비만 다룬다 -- 장비 장착/해제는
/// `equipItem`을 그대로 부른다(T-61에서 남겨둔 배선).
class CharacterDetailScreen extends StatelessWidget {
  const CharacterDetailScreen({
    super.key,
    required this.character,
    required this.equipmentById,
    required this.equippedInstance,
    required this.unequippedInstances,
    required this.onEquipTap,
  });

  final UnitDef character;
  final Map<String, EquipmentDef> equipmentById;
  final EquipmentInstance? equippedInstance;

  /// 아직 아무 캐릭터에도 장착되지 않은 보유 장비 -- 장착 후보.
  final List<EquipmentInstance> unequippedInstances;

  /// null을 넘기면 해제(equipItem의 equipmentInstanceId: null과 같은 의미).
  final void Function(String? equipmentInstanceId) onEquipTap;

  @override
  Widget build(BuildContext context) {
    final equipped = equippedInstance;
    return Scaffold(
      appBar: AppBar(title: Text(character.nameKey.isEmpty ? character.id : character.nameKey)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (character.role != null) Text('역할: ${character.role}', key: const ValueKey('character_role')),
          Wrap(
            spacing: 8,
            children: [
              for (final tagId in character.intrinsicTags.keys)
                Chip(label: Text('$tagId Lv${character.intrinsicTags[tagId]}'), key: ValueKey('character_tag_$tagId')),
            ],
          ),
          const SizedBox(height: 12),
          Text('HP ${character.base.maxHp} / 공격력 ${character.base.atk} / 방어력 ${character.base.def}', key: const ValueKey('character_stats')),
          const SizedBox(height: 24),
          const Text('장비', style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            key: const ValueKey('character_equipped'),
            title: Text(equipped == null ? '미장착' : (equipmentById[equipped.equipmentId]?.nameKey ?? equipped.equipmentId)),
            subtitle: equipped == null ? null : Text('+${equipped.enhanceLevel}'),
            trailing: equipped == null
                ? null
                : TextButton(
                    key: const ValueKey('character_unequip'),
                    onPressed: () => onEquipTap(null),
                    child: const Text('해제'),
                  ),
          ),
          if (unequippedInstances.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('장착 가능한 장비'),
            for (final instance in unequippedInstances)
              ListTile(
                key: ValueKey('character_equip_candidate_${instance.id}'),
                title: Text(equipmentById[instance.equipmentId]?.nameKey ?? instance.equipmentId),
                subtitle: Text('+${instance.enhanceLevel}'),
                trailing: TextButton(
                  key: ValueKey('character_equip_${instance.id}'),
                  onPressed: () => onEquipTap(instance.id),
                  child: const Text('장착'),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
