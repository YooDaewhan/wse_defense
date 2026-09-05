import '../constants.dart';
import '../entity/battle_entity.dart';
import '../stat/modifier.dart';
import '../stat/modifier_source.dart';
import '../tag/tag_relation_evaluator.dart';
import '../tag/tag_relation_rule.dart';
import '../tag/tag_relation_state.dart';
import '../world/battle_world.dart';
import 'battle_system.dart';

/// 02_TAG_SYSTEM.md §4.5: RELATION_SAMPLE_TICKS(6틱=0.2초)마다 규칙을
/// 재평가한다. `minActiveTicks`/`offDelayTicks`로 진동을 막는다.
class RelationSystem implements BattleSystem {
  const RelationSystem();

  @override
  void execute(BattleWorld w) {
    if (w.tick % relationSampleTicks != 0) return;

    // rules 리스트 순서 고정(w.config.relationRules) — 여러 규칙이 같은
    // 스탯을 건드려도 결과가 재현 가능해야 한다.
    for (final rule in w.config.relationRules) {
      final subjects = [
        for (final e in w.entities.ordered)
          if (rule.subject.matches(e, e)) e,
      ];

      for (final subject in subjects) {
        final matched = RelationEvaluator.countMatches(rule, subject, w);
        final wantActive = RelationEvaluator.wantActive(rule, matched);
        final state = subject.relationStates.putIfAbsent(
          rule.id,
          () => RelationState(),
        );

        if (wantActive) {
          state.offCounter = 0;
          if (!state.active) {
            state.active = true;
            state.activeSince = w.tick;
          }
          state.scale = RelationEvaluator.computeScale(rule, matched, subject);
        } else if (state.active) {
          if (w.tick - state.activeSince < rule.minActiveTicks) {
            // 최소 유지 시간 이내 -> 계속 켜둔다.
          } else {
            state.offCounter += relationSampleTicks;
            if (state.offCounter >= rule.offDelayTicks) {
              state.active = false;
            }
          }
        }

        _applyOrRemove(subject, rule, state);
      }
    }
  }

  void _applyOrRemove(BattleEntity subject, TagRelationRule rule, RelationState state) {
    subject.stats.removeBySource(ModifierKind.relation, rule.id);
    if (!state.active) return;
    for (final m in rule.mods) {
      subject.stats.addModifier(
        StatModifier(
          stat: m.stat,
          op: m.op,
          value: m.value * state.scale,
          source: ModifierSource(ModifierKind.relation, rule.id),
          exclusiveGroup: m.exclusiveGroup,
        ),
      );
    }
  }
}
