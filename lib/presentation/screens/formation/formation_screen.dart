import 'package:flutter/material.dart';

import '../../../battle/defs/datapack.dart';
import '../../../battle/defs/unit_def.dart';
import '../../../battle/tag/tag_def.dart';
import '../../../data/local/formation_repository.dart';
import '../../../data/tag/tag_data_loader.dart';
import '../../../domain/formation/character_filter.dart';
import '../../../domain/formation/team_tag_preview.dart';
import 'widgets/character_filter_bar.dart';
import 'widgets/formation_slot_tile.dart';
import 'widgets/team_tag_panel.dart';

/// 05_FRONTEND.md §3.1 `/formation`: 10칸(5+5), 프리셋 3, 필터, 상세 패널,
/// 팀 태그 패널.
///
/// 캐릭터 선택은 모달 바텀시트 대신 같은 화면 안의 인라인 패널로 처리한다
/// — 별도 라우트/애니메이션이 없어 상태가 훨씬 단순하고, 위젯 테스트에서도
/// 라우트 전환 타이밍에 좌우되지 않는다.
class FormationScreen extends StatefulWidget {
  const FormationScreen({super.key, required this.datapack, required this.tagBundle, required this.repository});

  final Datapack datapack;
  final TagBundle tagBundle;
  final FormationStore repository;

  @override
  State<FormationScreen> createState() => _FormationScreenState();
}

class _FormationScreenState extends State<FormationScreen> {
  late List<String?> _slots = widget.repository.current;
  CharacterFilter _filter = const CharacterFilter();
  int? _editingSlot;

  List<UnitDef> get _assignedDefs => [
    for (final id in _slots)
      if (id != null && widget.datapack.characterById(id) != null) widget.datapack.characterById(id)!,
  ];

  late final List<String> _traitOptions = [
    for (var i = 0; i < widget.tagBundle.registry.length; i++)
      if (widget.tagBundle.registry.defOf(i).category == TagCategory.trait) widget.tagBundle.registry.idOf(i),
  ];

  TeamTagPreview get _preview => computeTeamTagPreview(
    _assignedDefs,
    widget.tagBundle.registry,
    widget.tagBundle.effects,
    widget.tagBundle.relations,
  );

  void _toggleEditing(int slotIndex) =>
      setState(() => _editingSlot = _editingSlot == slotIndex ? null : slotIndex);

  void _assign(String? characterId) {
    final slotIndex = _editingSlot;
    if (slotIndex == null) return;
    setState(() {
      final next = List<String?>.of(_slots);
      next[slotIndex] = characterId;
      _slots = next;
      widget.repository.current = _slots;
      _editingSlot = null;
    });
  }

  void _applyPreset(int index) => setState(() {
    _slots = widget.repository.preset(index);
    widget.repository.current = _slots;
  });

  void _savePreset(int index) => widget.repository.savePreset(index, _slots);

  @override
  Widget build(BuildContext context) {
    final editingSlot = _editingSlot;
    return Scaffold(
      appBar: AppBar(title: const Text('편성')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          CharacterFilterBar(
            filter: _filter,
            onChanged: (f) => setState(() => _filter = f),
            traitOptions: _traitOptions,
          ),
          const SizedBox(height: 12),
          _PresetBar(onApply: _applyPreset, onSave: _savePreset),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < FormationStore.slotCount; i++)
                FormationSlotTile(
                  key: ValueKey('formation_slot_$i'),
                  characterId: _slots[i],
                  def: _slots[i] == null ? null : widget.datapack.characterById(_slots[i]!),
                  onTap: () => _toggleEditing(i),
                ),
            ],
          ),
          if (editingSlot != null) ...[
            const SizedBox(height: 12),
            _CharacterPickerPanel(
              candidates: widget.datapack.characters.values.where(_filter.matches).toList(),
              onPick: _assign,
            ),
          ],
          const SizedBox(height: 16),
          TeamTagPanel(preview: _preview),
        ],
      ),
    );
  }
}

class _CharacterPickerPanel extends StatelessWidget {
  const _CharacterPickerPanel({required this.candidates, required this.onPick});

  final List<UnitDef> candidates;
  final void Function(String? characterId) onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('character_picker_panel'),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(8)),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          ActionChip(key: const ValueKey('slot_clear'), label: const Text('비우기'), onPressed: () => onPick(null)),
          for (final def in candidates)
            ActionChip(
              key: ValueKey('pick_${def.id}'),
              label: Text(def.nameKey.isEmpty ? def.id : def.nameKey),
              onPressed: () => onPick(def.id),
            ),
        ],
      ),
    );
  }
}

class _PresetBar extends StatelessWidget {
  const _PresetBar({required this.onApply, required this.onSave});
  final void Function(int index) onApply;
  final void Function(int index) onSave;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var i = 0; i < 3; i++)
        Expanded(
          child: Column(
            children: [
              Text('프리셋 ${i + 1}'),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    key: ValueKey('preset_apply_$i'),
                    onPressed: () => onApply(i),
                    child: const Text('적용'),
                  ),
                  TextButton(
                    key: ValueKey('preset_save_$i'),
                    onPressed: () => onSave(i),
                    child: const Text('저장'),
                  ),
                ],
              ),
            ],
          ),
        ),
    ],
  );
}
