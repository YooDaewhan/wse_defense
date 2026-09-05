import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/tag/tag_contribution.dart';
import 'package:wse_defense/battle/tag/tag_def.dart';
import 'package:wse_defense/battle/tag/tag_registry.dart';
import 'package:wse_defense/battle/tag/tag_stack.dart';

List<TagDef> _loadTagDefs() {
  final json =
      jsonDecode(File('assets/data/v1/tags.json').readAsStringSync())
          as Map<String, Object?>;
  return [
    for (final t in json['tags'] as List<Object?>)
      TagDef.fromJson(t as Map<String, Object?>),
  ];
}

void main() {
  test('loads all 39 tags; indexOf/idOf round-trip', () {
    final defs = _loadTagDefs();
    expect(defs.length, 39);

    final registry = TagRegistry(defs);
    expect(registry.length, 39);

    for (final def in defs) {
      final index = registry.indexOf(def.id);
      expect(index, isNot(-1));
      expect(registry.idOf(index), def.id);
    }
  });

  test('TagStack.entries() always iterates in ascending tagIndex order', () {
    final stack = TagStack();
    for (final i in [30, 5, 17, 0, 22, 8]) {
      stack.add(i, 1);
    }

    final order = [for (final e in stack.entries()) e.$1];
    expect(order, [0, 5, 8, 17, 22, 30]);
  });

  test('CANCEL_EQUAL: coward 2 + brave 1 -> coward 1, brave 0', () {
    final registry = TagRegistry(_loadTagDefs());
    final coward = registry.indexOf('TAG_TRAIT_COWARD');
    final brave = registry.indexOf('TAG_TRAIT_BRAVE');

    final stack = TagStack();
    stack.add(coward, 2);
    stack.add(brave, 1);

    registry.resolveConflicts(stack);

    expect(stack.levelOf(coward), 1);
    expect(stack.levelOf(brave), 0);
  });

  test('adding then removing a contribution restores the original level', () {
    final registry = TagRegistry(_loadTagDefs());
    final animal = registry.indexOf('TAG_RACE_ANIMAL');

    final baseContributions = [
      TagContribution(
        tagIndex: animal,
        amount: 2,
        kind: TagSourceKind.intrinsic,
        sourceId: 'CHR_BEAR',
      ),
    ];
    final originalStack = registry.buildStack(baseContributions);
    expect(originalStack.levelOf(animal), 2);

    final buffed = [
      ...baseContributions,
      TagContribution(
        tagIndex: animal,
        amount: 1,
        kind: TagSourceKind.buff,
        sourceId: 'SKL_TEST_BUFF',
        expireTick: 300,
      ),
    ];
    final buffedStack = registry.buildStack(buffed);
    expect(buffedStack.levelOf(animal), 3);

    // 버프 만료: contribution 제거 후 재계산.
    final restoredStack = registry.buildStack(baseContributions);
    expect(restoredStack.levelOf(animal), originalStack.levelOf(animal));
  });
}
