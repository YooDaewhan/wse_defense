import '../../battle/defs/stage_def.dart';

enum StageStatus { cleared, current, locked }

/// 05_FRONTEND.md §2 `/adventure`: 스테이지 노드 하나(진행도 포함).
///
/// "current"(다음에 도전할 스테이지) = 순서상 첫 번째 미클리어 스테이지.
/// 그보다 뒤는 전부 locked, 그 전은 전부 cleared — 챕터를 순서대로만
/// 진행한다는 단순한 선형 규칙(기획서에 별도 분기 조건이 없음).
class StageNode {
  const StageNode({required this.stage, required this.status});
  final StageDef stage;
  final StageStatus status;

  bool get isPlayable => status != StageStatus.locked;
}

List<StageNode> buildStageNodes(List<StageDef> chapterStages, Set<String> clearedStageIds) {
  final sorted = [...chapterStages]..sort((a, b) => a.index.compareTo(b.index));
  var reachedCurrent = false;
  final nodes = <StageNode>[];
  for (final stage in sorted) {
    if (clearedStageIds.contains(stage.id)) {
      nodes.add(StageNode(stage: stage, status: StageStatus.cleared));
    } else if (!reachedCurrent) {
      nodes.add(StageNode(stage: stage, status: StageStatus.current));
      reachedCurrent = true;
    } else {
      nodes.add(StageNode(stage: stage, status: StageStatus.locked));
    }
  }
  return nodes;
}
