import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/domain/adventure/stage_node.dart';

const _stages = [
  StageDef(id: 'STG_1_1', index: 1, fieldLength: 2400, allyBaseX: 0, enemyBaseX: 2400, enemyBaseHp: 1, timeLimitSec: 1),
  StageDef(id: 'STG_1_2', index: 2, fieldLength: 2400, allyBaseX: 0, enemyBaseX: 2400, enemyBaseHp: 1, timeLimitSec: 1),
  StageDef(id: 'STG_1_3', index: 3, fieldLength: 2400, allyBaseX: 0, enemyBaseX: 2400, enemyBaseHp: 1, timeLimitSec: 1),
];

void main() {
  test('nothing cleared -> the first stage is current, the rest are locked', () {
    final nodes = buildStageNodes(_stages, {});
    expect(nodes.map((n) => n.status), [StageStatus.current, StageStatus.locked, StageStatus.locked]);
  });

  test('clearing the first stage promotes the second to current', () {
    final nodes = buildStageNodes(_stages, {'STG_1_1'});
    expect(nodes.map((n) => n.status), [StageStatus.cleared, StageStatus.current, StageStatus.locked]);
  });

  test('clearing every stage leaves none current or locked', () {
    final nodes = buildStageNodes(_stages, {'STG_1_1', 'STG_1_2', 'STG_1_3'});
    expect(nodes.every((n) => n.status == StageStatus.cleared), isTrue);
  });

  test('only cleared and current stages are playable', () {
    final nodes = buildStageNodes(_stages, {'STG_1_1'});
    expect(nodes.map((n) => n.isPlayable), [true, true, false]);
  });

  test('nodes are always ordered by stage index regardless of input order', () {
    final shuffled = [_stages[2], _stages[0], _stages[1]];
    final nodes = buildStageNodes(shuffled, {});
    expect(nodes.map((n) => n.stage.id), ['STG_1_1', 'STG_1_2', 'STG_1_3']);
  });
}
