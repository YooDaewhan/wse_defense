import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/constants.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/entity/battle_entity.dart';
import 'package:wse_defense/battle/entity/entity_state.dart';
import 'package:wse_defense/battle/system/attack_system.dart';
import 'package:wse_defense/battle/system/target_system.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/game/anim/anim_clip_def.dart';
import 'package:wse_defense/game/anim/character_anim_set.dart';
import 'package:wse_defense/game/anim/clip_resolver.dart';

const _attackDef = UnitDef(
  id: 'T',
  base: UnitBaseStats(
    maxHp: 1000,
    atk: 10,
    attackPeriod: 60, // P
    attackWindup: 12, // A
    attackRecover: 48, // R = P - A
    attackRange: 100,
    moveSpeed: 0,
  ),
);

const _attackAnimSet = CharacterAnimSet({
  'attack': AnimClipDef(
    name: 'attack',
    frameCount: 8,
    fps: 0, // 3분할은 틱 기반이라 fps를 안 씀
    windupFrames: 3,
    recoverFrames: 4,
  ),
});

BattleEntity _entity({
  EntityAction action = EntityAction.idle,
  int actionTimer = 0,
  int spawnTick = 0,
  int knockbackTicksLeft = 0,
}) => BattleEntity(id: 1, side: Side.ally, def: _attackDef, spawnTick: spawnTick, x: 0)
  ..action = action
  ..actionTimer = actionTimer
  ..knockbackTicksLeft = knockbackTicksLeft;

void main() {
  group('state priority', () {
    test('dead beats everything, including being freshly spawned', () {
      final e = _entity(action: EntityAction.dead, spawnTick: 5);
      expect(resolveClip(e, null, 6).clipName, 'death');
    });

    test('freshly spawned shows spawn for spawnWindowTicks, then falls through', () {
      final e = _entity(spawnTick: 100);
      expect(resolveClip(e, null, 100).clipName, 'spawn');
      expect(resolveClip(e, null, 100 + spawnWindowTicks - 1).clipName, 'spawn');
      expect(resolveClip(e, null, 100 + spawnWindowTicks).clipName, isNot('spawn'));
    });

    test('knockback beats stun/attack/idle', () {
      final e = _entity(spawnTick: -1000, knockbackTicksLeft: 5, action: EntityAction.attackWindup);
      expect(resolveClip(e, null, 0).clipName, 'knockback');
    });

    test('stunned maps to stun', () {
      final e = _entity(spawnTick: -1000, action: EntityAction.stunned);
      expect(resolveClip(e, null, 0).clipName, 'stun');
    });

    test('moving vs idle', () {
      final moving = _entity(spawnTick: -1000, action: EntityAction.moving);
      final idle = _entity(spawnTick: -1000);
      expect(resolveClip(moving, null, 0).clipName, 'move');
      expect(resolveClip(idle, null, 0).clipName, 'idle');
    });
  });

  group('attack 3-split (08_ASSET_PRODUCTION.md §2.2)', () {
    test('without clip data, falls back to a plain attack clip (no crash, no impact claim)', () {
      final e = _entity(spawnTick: -1000, action: EntityAction.attackWindup, actionTimer: 12);
      final r = resolveClip(e, null, 0);
      expect(r.clipName, 'attack');
      expect(r.isImpact, isFalse);
    });

    test('windup frame index rises monotonically from 0 toward windupFrames-1', () {
      final e = _entity(spawnTick: -1000, action: EntityAction.attackWindup, actionTimer: 12);
      expect(resolveClip(e, _attackAnimSet, 0).frameIndex, 0); // 막 진입(elapsed 0)

      e.actionTimer = 1; // elapsed = 11 (마지막으로 관측되는 windup 틱)
      expect(resolveClip(e, _attackAnimSet, 0).frameIndex, 2); // windupFrames-1
    });

    test('the instant recover begins (elapsed 0) is exactly the impact frame', () {
      final e = _entity(spawnTick: -1000, action: EntityAction.attackRecover, actionTimer: 48);
      final r = resolveClip(e, _attackAnimSet, 0);
      expect(r.isImpact, isTrue);
    });

    test('recover frame index reaches recoverFrames-1 on the last observed recover tick', () {
      final e = _entity(spawnTick: -1000, action: EntityAction.attackRecover, actionTimer: 1);
      final r = resolveClip(e, _attackAnimSet, 0);
      expect(r.isImpact, isFalse);
      expect(r.frameIndex, 3); // recoverFrames-1
    });
  });

  group('impact frame lines up with the actual judgement tick end-to-end', () {
    test('the tick right after AttackSystem resolves a hit reports isImpact', () {
      final w = BattleWorld(
        config: const BattleConfig(
          stage: StageDef(
            id: 'STG_TEST',
            index: 1,
            fieldLength: 2400,
            allyBaseX: 0,
            enemyBaseX: 2400,
            enemyBaseHp: 1000,
            timeLimitSec: 300,
          ),
          allyBaseHp: 1000,
        ),
        rngSeed: 1,
        datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
        systems: [TargetSystem(), AttackSystem()],
      )..phase = BattlePhase.running;

      final attacker = w.spawnEntity(_attackDef, Side.ally, 0);
      w.spawnEntity(_attackDef, Side.enemy, 50 * posScale); // 사거리(100) 안

      var judged = false;
      for (var i = 0; i < 20; i++) {
        final before = attacker.completedAttacks;
        w.step();
        if (attacker.completedAttacks > before) {
          judged = true;
          // 판정이 일어난 바로 그 스텝 직후 상태 -> impact여야 한다.
          expect(resolveClip(attacker, _attackAnimSet, w.tick).isImpact, isTrue);
          break;
        }
      }
      expect(judged, isTrue, reason: '20틱 안에 판정이 일어나지 않음(테스트 전제 오류)');
    });
  });
}
