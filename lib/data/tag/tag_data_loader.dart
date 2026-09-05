import 'dart:convert';

import '../../battle/tag/tag_def.dart';
import '../../battle/tag/tag_effect_def.dart';
import '../../battle/tag/tag_registry.dart';
import '../../battle/tag/tag_relation_rule.dart';
import '../datapack/datapack_loader.dart' show AssetReader;

/// `tags.json` + `tag_effects.json` + `tag_relations.json`을 한 번에 읽는다
/// (T-15/T-16 테스트들이 각자 인라인으로 하던 걸 공용화 — 편성 화면(T-31)도
/// 같은 걸 필요로 한다).
class TagBundle {
  const TagBundle({required this.registry, required this.effects, required this.relations});
  final TagRegistry registry;
  final List<TagEffectDef> effects;
  final List<TagRelationRule> relations;
}

Future<TagBundle> loadTagBundle(AssetReader readJson) async {
  final tagsRaw = jsonDecode(await readJson('tags.json')) as Map<String, Object?>;
  final registry = TagRegistry([
    for (final t in tagsRaw['tags'] as List<Object?>) TagDef.fromJson(t as Map<String, Object?>),
  ]);

  final effectsRaw = jsonDecode(await readJson('tag_effects.json')) as Map<String, Object?>;
  final effects = [
    for (final e in effectsRaw['effects'] as List<Object?>)
      TagEffectDef.fromJson(e as Map<String, Object?>, registry),
  ];

  final relationsRaw = jsonDecode(await readJson('tag_relations.json')) as Map<String, Object?>;
  final relations = [
    for (final r in relationsRaw['rules'] as List<Object?>)
      TagRelationRule.fromJson(r as Map<String, Object?>, registry),
  ];

  return TagBundle(registry: registry, effects: effects, relations: relations);
}
