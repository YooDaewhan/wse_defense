import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/constants.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/system/attack_system.dart';
import 'package:wse_defense/battle/system/damage_system.dart';
import 'package:wse_defense/battle/system/movement_system.dart';
import 'package:wse_defense/battle/system/target_system.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/data/datapack/datapack_loader.dart';

/// 09_MILESTONES.md T-21 완료조건: "기본 5종 수치가 기획서 6-8 대비 DPS
/// ±15% 안에 들어옴을 확인". game_design_final.md §6-8의 "기본 DPS" =
/// 공격력 × 30 / P(공격주기 틱) — 이동·헛침·상호 견제가 전혀 없을 때의
/// 이론치다. 그 조건을 그대로 재현하려고 더미 표적을 사거리 안(겹치는
/// 위치)에 고정해두고, 실측 총 피해량 / 경과 초를 그 이론치와 비교한다.
///
/// 태그/스킬 데이터 로더(TagRegistry/skills.json)는 아직 없어(T-21 스코프
/// 밖) 반영하지 않는다 — 5종 모두 스킬은 보조 효과(멈칫/토닥임 등)라 기본
/// 공격 DPS 자체에는 영향이 없다.
const _measureTicks = 3000; // 100초 — 초기 windup 지연이 15% 오차에 묻힐 만큼 충분히 김

final _dummyDef = const UnitDef(
  id: 'ENM_TEST_DUMMY',
  base: UnitBaseStats(
    maxHp: 100000000,
    atk: 0,
    attackPeriod: 999999,
    attackWindup: 1,
    attackRecover: 1,
    attackRange: 0,
    moveSpeed: 0,
    def: 0,
  ),
);

void main() {
  late Map<String, UnitDef> characters;

  setUpAll(() async {
    final loader = DatapackLoader(
      (path) => File('assets/data/v1/$path').readAsString(),
    );
    characters = (await loader.load()).characters;
  });

  const expectedDps = {
    'CHR_ACORN': 45.0,
    'CHR_DROPLET': 100.0,
    'CHR_MUSHROOM': 105.0,
    'CHR_BIRD': 72.0,
    'CHR_BEAR': 1100 * 30 / 105, // 314.2857...
  };

  for (final entry in expectedDps.entries) {
    test('${entry.key} measured DPS is within +-15% of the design baseline (${entry.value.toStringAsFixed(2)})', () {
      final def = characters[entry.key];
      expect(def, isNotNull, reason: '${entry.key}가 characters.json에 없음');

      final world = BattleWorld(
        config: BattleConfig(
          stage: const StageDef(
            id: 'STG_TEST_DPS',
            index: 1,
            fieldLength: 24000,
            allyBaseX: 0,
            enemyBaseX: 24000,
            enemyBaseHp: 1,
            timeLimitSec: 1 << 20,
          ),
          allyBaseHp: 10000,
        ),
        rngSeed: 1,
        datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
        systems: [TargetSystem(), MovementSystem(), AttackSystem(), DamageSystem()],
      )..phase = BattlePhase.running;

      world.spawnEntity(def!, Side.ally, 0);
      final dummy = world.spawnEntity(_dummyDef, Side.enemy, 0); // 사거리 안(겹침) 고정
      final hpBefore = dummy.hp;

      for (var i = 0; i < _measureTicks; i++) {
        world.step();
      }

      final totalDamage = hpBefore - dummy.hp;
      final measuredDps = totalDamage / (_measureTicks / ticksPerSec);
      final expected = entry.value;

      expect(
        measuredDps,
        inInclusiveRange(expected * 0.85, expected * 1.15),
        reason: '측정 DPS $measuredDps (기대치 $expected ±15%)',
      );
    });
  }
}
