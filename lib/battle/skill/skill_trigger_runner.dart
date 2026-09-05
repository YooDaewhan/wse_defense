import '../constants.dart';
import '../effect/effect_registry.dart';
import '../entity/battle_entity.dart';
import '../rng/deterministic_rng.dart';
import '../stat/modifier_source.dart';
import '../stat/stat_key.dart';
import '../world/battle_world.dart';
import 'skill_trigger_def.dart';

/// 03_BATTLE_ENGINE.md §11. 각 시스템(AttackSystem/DeathSystem/DamageSystem/
/// TagEffectResolver, BattleWorld.spawnEntity)이 알맞은 순간에 이 static
/// 메서드들을 호출한다 — 이 클래스 자체는 언제 불릴지 모른다.
class SkillTriggerRunner {
  const SkillTriggerRunner._();

  /// §4.1 완료된 기본 공격 동작 기준(범위로 몇 명을 맞혔든 1회, 넉백으로
  /// 취소된 공격은 애초에 `completedAttacks`가 안 늘어서 안 불림 — T-09).
  static void onAttackCompleted(BattleWorld w, BattleEntity e) {
    for (final skillId in e.def.skills) {
      final skill = w.config.skillDefs[skillId];
      if (skill == null) continue;
      switch (skill.triggerKind) {
        case TriggerKind.onNthAttack:
          if (skill.n > 0 && e.completedAttacks % skill.n == 0) _fire(w, e, skill);
        case TriggerKind.onChance:
          _rollChance(w, e, skill);
        default:
          break;
      }
    }
  }

  /// 등장 — 인스턴스 1회.
  static void onSpawn(BattleWorld w, BattleEntity e) => _fireOnce(w, e, TriggerKind.onSpawn);

  /// 사망 — 최종 사망(부활 없음, isFinal)만.
  static void onDeath(BattleWorld w, BattleEntity e, bool isFinal) {
    if (!isFinal) return;
    _fireOnce(w, e, TriggerKind.onDeath);
  }

  /// HP 임계 — 생애 1회. `before > 임계 >= after`로 아래로 가로지른 순간만 잡는다.
  static void onHpChanged(BattleWorld w, BattleEntity e, int before, int after) {
    for (final skillId in e.def.skills) {
      final skill = w.config.skillDefs[skillId];
      if (skill == null || skill.triggerKind != TriggerKind.onHpThreshold) continue;
      if (e.firedOnceTriggers.contains(skill.id)) continue;

      final maxHp = e.stats.get(StatKey.maxHp);
      final thresholdHp = maxHp * skill.hpThresholdPct ~/ pctScale;
      if (before > thresholdHp && after <= thresholdHp) {
        e.firedOnceTriggers.add(skill.id);
        _fire(w, e, skill);
      }
    }
  }

  /// 태그 레벨 — UNIT 스코프 한정(FIELD는 이 훅이 안 불림). 조건이 꺼지면
  /// STAT_BUFF(durationTicks:0, "조건부 상시")를 직접 걷어낸다.
  static void onTagsChanged(BattleWorld w, BattleEntity e) {
    for (final skillId in e.def.skills) {
      final skill = w.config.skillDefs[skillId];
      if (skill == null || skill.triggerKind != TriggerKind.onTagLevel) continue;

      final level = e.tags.levelOf(skill.tagIndex);
      final source = ModifierSource(ModifierKind.skill, skill.id);
      if (level >= skill.minLevel) {
        _fire(w, e, skill);
      } else {
        e.stats.removeBySource(source.kind, source.id);
      }
    }
  }

  static void _fireOnce(BattleWorld w, BattleEntity e, TriggerKind kind) {
    for (final skillId in e.def.skills) {
      final skill = w.config.skillDefs[skillId];
      if (skill == null || skill.triggerKind != kind) continue;
      if (e.firedOnceTriggers.contains(skill.id)) continue;
      e.firedOnceTriggers.add(skill.id);
      _fire(w, e, skill);
    }
  }

  /// §11 "판정은 rng.stream(RngStream.skillProc).roll(p)". PER_TARGET은
  /// 이번 판정에서 맞은 대상 수만큼 독립 판정하는 간이 구현 — 어떤
  /// 완료 조건도 PER_TARGET 세부 동작을 요구하지 않아 최소로만 둔다.
  static void _rollChance(BattleWorld w, BattleEntity e, SkillTriggerDef skill) {
    final rng = w.rng.stream(RngStream.skillProc);
    if (skill.chanceUnit == ChanceUnit.perAttack) {
      if (rng.roll(skill.chance)) _fire(w, e, skill);
      return;
    }
    for (var i = 0; i < e.lastHitTargetIds.length; i++) {
      if (rng.roll(skill.chance)) {
        _fire(w, e, skill);
        return;
      }
    }
  }

  static void _fire(BattleWorld w, BattleEntity e, SkillTriggerDef skill) {
    final targets = skill.target == null
        ? [e]
        : skill.target!.select(w.entities.ordered, e);
    final source = ModifierSource(ModifierKind.skill, skill.id);
    for (final target in targets) {
      for (final action in skill.actions) {
        EffectRegistry.of(action.type)?.apply(w, target, action.params, source);
      }
    }
  }
}
