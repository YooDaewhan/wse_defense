import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/data/tag/tag_data_loader.dart';
import 'package:wse_defense/domain/formation/team_tag_preview.dart';

const _animal1 = UnitDef(
  id: 'CHR_ANIMAL_1',
  role: 'ROLE_ATTACKER',
  intrinsicTags: {'TAG_RACE_ANIMAL': 2},
  base: UnitBaseStats(
    maxHp: 100,
    atk: 10,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 100,
    moveSpeed: 0,
  ),
);

const _animal2 = UnitDef(
  id: 'CHR_ANIMAL_2',
  role: 'ROLE_DEFENDER',
  intrinsicTags: {'TAG_RACE_ANIMAL': 2},
  base: UnitBaseStats(
    maxHp: 100,
    atk: 10,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 100,
    moveSpeed: 0,
  ),
);

const _plant = UnitDef(
  id: 'CHR_PLANT',
  intrinsicTags: {'TAG_RACE_PLANT': 1},
  base: UnitBaseStats(
    maxHp: 100,
    atk: 10,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 100,
    moveSpeed: 0,
  ),
);

const _coward = UnitDef(
  id: 'CHR_COWARD',
  intrinsicTags: {'TAG_TRAIT_COWARD': 1},
  base: UnitBaseStats(
    maxHp: 100,
    atk: 10,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 100,
    moveSpeed: 0,
  ),
);

const _brave = UnitDef(
  id: 'CHR_BRAVE',
  intrinsicTags: {'TAG_TRAIT_BRAVE': 1},
  base: UnitBaseStats(
    maxHp: 100,
    atk: 10,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 100,
    moveSpeed: 0,
  ),
);

void main() {
  late final tagBundle = loadTagBundle((path) => File('assets/data/v1/$path').readAsString());

  test('formation levels sum unit intrinsic tags and clamp to maxTeamLevel', () async {
    final bundle = await tagBundle;
    // TAG_RACE_ANIMAL의 maxTeamLevel은 tags.json에 없어 TagDef 기본값(20).
    final preview = computeTeamTagPreview([_animal1, _animal2], bundle.registry, bundle.effects, bundle.relations);
    expect(preview.formationLevels['TAG_RACE_ANIMAL'], 4); // 2 + 2
  });

  test('reaches the first animal tier (Lv3) exactly at level 3, not before', () async {
    final bundle = await tagBundle;
    // 레벨 2(동물 1마리)로는 아직 티어 3 미만.
    final below = computeTeamTagPreview([_animal1], bundle.registry, bundle.effects, bundle.relations);
    expect(below.activeTiers, isEmpty);
    expect(below.nextTierHints.single.nextTierMinLevel, 3);
    expect(below.nextTierHints.single.levelsNeeded, 1);

    // 두 마리(레벨 4)면 Lv3 티어가 활성화된다.
    final above = computeTeamTagPreview([_animal1, _animal2], bundle.registry, bundle.effects, bundle.relations);
    expect(above.activeTiers.map((t) => t.minLevel), [3]);
    expect(above.nextTierHints.single.nextTierMinLevel, 6); // 다음 목표는 Lv6
    expect(above.nextTierHints.single.levelsNeeded, 2);
  });

  test('a formation with none of the relevant tag at all has no active tiers, and the hint reports the full gap', () async {
    final bundle = await tagBundle;
    final preview = computeTeamTagPreview([_plant], bundle.registry, bundle.effects, bundle.relations);
    expect(preview.activeTiers, isEmpty);
    expect(preview.nextTierHints.single.currentLevel, 0);
    expect(preview.nextTierHints.single.levelsNeeded, 3); // 첫 티어(Lv3)까지 전부 남음
  });

  test('relation feasibility requires both subject and other tag groups present', () async {
    final bundle = await tagBundle;

    // 겁쟁이만 있고 용감이 없으면 두 겁쟁이/용감 관계 다 발동 불가능.
    final cowardOnly = computeTeamTagPreview([_coward, _plant], bundle.registry, bundle.effects, bundle.relations);
    expect(cowardOnly.relationHints.map((h) => h.ruleId), isNot(contains('TRL_COWARD_SLOWED_BY_BRAVE_AHEAD')));

    // 겁쟁이 + 용감이 둘 다 있으면 서로 관련된 두 관계 모두 예고된다.
    final both = computeTeamTagPreview([_coward, _brave], bundle.registry, bundle.effects, bundle.relations);
    final ruleIds = both.relationHints.map((h) => h.ruleId).toSet();
    expect(ruleIds, containsAll(['TRL_COWARD_SLOWED_BY_BRAVE_AHEAD', 'TRL_BRAVE_BOOSTED_BY_COWARD_BEHIND']));
  });

  test('a single-unit formation can never feasibly trigger a relation (needs 2)', () async {
    final bundle = await tagBundle;
    final preview = computeTeamTagPreview([_coward], bundle.registry, bundle.effects, bundle.relations);
    expect(preview.relationHints, isEmpty);
  });

  test(
    'T-44: 02_TAG_SYSTEM.md §2.2 "장비로 받은 태그도 UNIT 레벨에 포함" — equipmentGrantsPerSlot이 즉시 반영된다',
    () async {
      final bundle = await tagBundle;
      final withoutGear = computeTeamTagPreview([_plant], bundle.registry, bundle.effects, bundle.relations);
      expect(withoutGear.formationLevels['TAG_RACE_PLANT'], 1);

      final withGear = computeTeamTagPreview(
        [_plant],
        bundle.registry,
        bundle.effects,
        bundle.relations,
        equipmentGrantsPerSlot: [
          {'TAG_RACE_PLANT': 1},
        ],
      );
      expect(withGear.formationLevels['TAG_RACE_PLANT'], 2); // 1(고유) + 1(장비) -- 재계산은 순수 함수라 "즉시" 반영
    },
  );
}
