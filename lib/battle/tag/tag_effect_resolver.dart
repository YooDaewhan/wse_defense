import '../entity/battle_entity.dart';
import '../stat/modifier.dart';
import '../stat/modifier_source.dart';
import '../world/battle_world.dart';
import 'tag_effect_def.dart';
import 'tag_query.dart';
import 'tag_registry.dart';
import 'tag_stack.dart';

/// 02_TAG_SYSTEM.md §8 해석 파이프라인.
class TagEffectResolver {
  TagEffectResolver(this.registry, this.effects);

  final TagRegistry registry;
  final List<TagEffectDef> effects;

  /// 전투 시작 시 1회: 편성 전체의 formationTagLevel을 계산한다 (§2.2).
  /// FORMATION 스코프는 이후 절대 변하지 않는다 — 이 값도, 이걸로 부여된
  /// 모디파이어도 전투 중엔 다시 계산되지 않는다.
  void resolveFormation(BattleWorld w) {
    final stack = TagStack();
    for (final slot in w.formation) {
      // 캐릭터 1명의 intrinsicTags 안에서는 각 태그가 서로 다른 인덱스라
      // 독립적으로 더해진다 — 순회 순서가 결과에 영향을 주지 않는다.
      for (final entry in slot.def.intrinsicTags.entries) {
        final idx = registry.indexOf(entry.key);
        if (idx == -1) continue; // 존재하지 않는 태그 참조 -> 무시
        stack.add(idx, entry.value, maxLevel: registry.defOf(idx).maxTeamLevel);
      }
    }
    w.formationTagLevel = stack;
  }

  /// 유닛 소환 시 1회.
  void resolveUnitOnSpawn(BattleEntity e, BattleWorld w) {
    _rebuildUnitTagStack(e);
    _reapplyUnitScopeEffects(e);
    _reapplyFormationScopeEffects(e, w);
    // FIELD 스코프는 다음 resolveField() 주기에 자동 반영된다.
  }

  /// 유닛의 태그 스택이 바뀌었을 때(버프 획득/만료, 장비 변경). UNIT 스코프만
  /// 재평가한다 — FORMATION은 절대 안 변하고, FIELD는 다음 주기부터.
  void onUnitTagsChanged(BattleEntity e) {
    _rebuildUnitTagStack(e);
    _reapplyUnitScopeEffects(e);
  }

  /// FIELD_SAMPLE_TICKS(60틱=2초)마다 TagResolveSystem이 호출한다.
  /// 살아있는 유닛들의 UNIT 스코프 태그를 합산해 그 side의 fieldTagLevel을
  /// 다시 만들고, FIELD 스코프 효과를 대상 유닛들에 재적용한다.
  void resolveField(BattleWorld w, Side side) {
    final stack = TagStack();
    for (final e in w.entities.ordered) {
      if (e.side != side || !e.isAlive) continue;
      for (final (tagIdx, level) in e.tags.entries()) {
        stack.add(tagIdx, level, maxLevel: registry.defOf(tagIdx).maxTeamLevel);
      }
    }
    if (side == Side.ally) {
      w.allyFieldTagLevel = stack;
    } else {
      w.enemyFieldTagLevel = stack;
    }

    // 항상 재계산 — diff 최적화(바뀐 태그만 건드리기)는 유닛 수가 커지면 추가.
    for (final e in w.entities.ordered) {
      if (e.side != side || !e.isAlive) continue;
      for (final def in effects) {
        if (def.scope != TagScope.field) continue;
        if (!_targetMatches(def, e)) {
          e.stats.removeBySource(ModifierKind.tagField, def.id);
          continue;
        }
        _applyToEntity(e, def, stack.levelOf(def.tagIndex));
      }
    }
  }

  void _rebuildUnitTagStack(BattleEntity e) {
    e.tags = registry.buildStack(e.tagContribs);
  }

  void _reapplyUnitScopeEffects(BattleEntity e) {
    for (final def in effects) {
      if (def.scope != TagScope.unit) continue;
      if (!_targetMatches(def, e)) {
        e.stats.removeBySource(ModifierKind.tagUnit, def.id);
        continue;
      }
      _applyToEntity(e, def, e.tags.levelOf(def.tagIndex));
    }
  }

  void _reapplyFormationScopeEffects(BattleEntity e, BattleWorld w) {
    for (final def in effects) {
      if (def.scope != TagScope.formation) continue;
      if (!_targetMatches(def, e)) {
        e.stats.removeBySource(ModifierKind.tagFormation, def.id);
        continue;
      }
      _applyToEntity(e, def, w.formationTagLevel.levelOf(def.tagIndex));
    }
  }

  bool _targetMatches(TagEffectDef def, BattleEntity e) =>
      def.target == null || def.target!.matches(e, e);

  void _applyToEntity(BattleEntity e, TagEffectDef def, int level) {
    final kind = switch (def.scope) {
      TagScope.unit => ModifierKind.tagUnit,
      TagScope.formation => ModifierKind.tagFormation,
      TagScope.field => ModifierKind.tagField,
    };
    e.stats.removeBySource(kind, def.id); // 재평가 전 항상 지운다 (대칭적 추가/제거)

    final mods = def.mode == TagEffectMode.perLevel
        ? _evalPerLevel(def, level)
        : _evalTier(def, level);
    for (final m in mods) {
      e.stats.addModifier(
        StatModifier(
          stat: m.stat,
          op: m.op,
          value: m.value,
          source: ModifierSource(kind, def.id),
          exclusiveGroup: m.exclusiveGroup,
        ),
      );
    }
  }

  List<StatModDef> _evalPerLevel(TagEffectDef def, int level) {
    final effectiveLevel = level > def.levelCapForEffect
        ? def.levelCapForEffect
        : level;
    if (effectiveLevel <= 0) return const [];
    return [
      for (final m in def.perLevel)
        StatModDef(
          stat: m.stat,
          op: m.op,
          value: m.value * effectiveLevel,
          exclusiveGroup: m.exclusiveGroup,
        ),
    ];
  }

  List<StatModDef> _evalTier(TagEffectDef def, int level) {
    if (def.tierMode == TierMode.cumulative) {
      return [
        for (final tier in def.tiers)
          if (level >= tier.minLevel) ...tier.mods,
      ];
    }

    // HIGHEST: minLevel <= level 중 가장 높은 티어 하나만.
    TagEffectTier? best;
    for (final tier in def.tiers) {
      if (level >= tier.minLevel &&
          (best == null || tier.minLevel > best.minLevel)) {
        best = tier;
      }
    }
    return best == null ? const [] : best.mods;
  }
}
