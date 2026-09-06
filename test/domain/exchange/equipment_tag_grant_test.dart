import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/data/tag/tag_data_loader.dart';
import 'package:wse_defense/domain/exchange/equipment_def.dart';
import 'package:wse_defense/domain/exchange/equipment_tag_grant.dart';

const _animalMask = EquipmentDef(
  id: 'EQP_ANIMAL_MASK',
  nameKey: 'eqp.animal_mask',
  originDungeonId: 'DGN_SUN',
  grantTagId: 'TAG_RACE_ANIMAL',
  grantTagBaseLevel: 1,
  tagBonusAtEnhance5: true,
);

const _pureOption = EquipmentDef(id: 'EQP_ACORN_SHIELD', nameKey: 'eqp.acorn_shield', originDungeonId: 'DGN_FIELD');

void main() {
  test('effectiveGrantTags: below +5 grants only the base level', () {
    expect(effectiveGrantTags(_animalMask, 0), {'TAG_RACE_ANIMAL': 1});
    expect(effectiveGrantTags(_animalMask, 4), {'TAG_RACE_ANIMAL': 1});
  });

  test('effectiveGrantTags: 07_DUNGEON_EXCHANGE.md §6.3 "+5 도달 시 태그 +1"', () {
    expect(effectiveGrantTags(_animalMask, 5), {'TAG_RACE_ANIMAL': 2});
    expect(effectiveGrantTags(_animalMask, 10), {'TAG_RACE_ANIMAL': 2}); // 그 이상은 추가 안 됨
  });

  test('a pure-option equipment (no grantTagId) grants nothing at any level', () {
    expect(effectiveGrantTags(_pureOption, 0), isEmpty);
    expect(effectiveGrantTags(_pureOption, 10), isEmpty);
  });

  test('previewEquipTagChange: 07_DUNGEON_EXCHANGE.md §5.1 "팀 동물 레벨이 4 -> 5"', () async {
    final bundle = await loadTagBundle((path) => File('assets/data/v1/$path').readAsString());

    final preview = previewEquipTagChange(
      currentFormationLevels: {'TAG_RACE_ANIMAL': 4},
      candidate: _animalMask,
      enhanceLevel: 0,
      registry: bundle.registry,
    );

    expect(preview, isNotNull);
    expect(preview!.tagId, 'TAG_RACE_ANIMAL');
    expect(preview.beforeLevel, 4);
    expect(preview.afterLevel, 5);
    expect(preview.isTierChange, isTrue);
  });

  test('previewEquipTagChange returns null for equipment that grants no tag', () async {
    final bundle = await loadTagBundle((path) => File('assets/data/v1/$path').readAsString());
    final preview = previewEquipTagChange(
      currentFormationLevels: const {},
      candidate: _pureOption,
      enhanceLevel: 0,
      registry: bundle.registry,
    );
    expect(preview, isNull);
  });

  test('previewEquipTagChange clamps to the tag\'s maxTeamLevel', () async {
    final bundle = await loadTagBundle((path) => File('assets/data/v1/$path').readAsString());
    final cap = bundle.registry.defOf(bundle.registry.indexOf('TAG_RACE_ANIMAL')).maxTeamLevel;

    final preview = previewEquipTagChange(
      currentFormationLevels: {'TAG_RACE_ANIMAL': cap},
      candidate: _animalMask,
      enhanceLevel: 0,
      registry: bundle.registry,
    );
    expect(preview!.afterLevel, cap); // 이미 상한이라 그대로
    expect(preview.isTierChange, isFalse);
  });
}
