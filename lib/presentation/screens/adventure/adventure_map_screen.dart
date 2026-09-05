import 'package:flutter/material.dart';

import '../../../battle/defs/stage_def.dart';
import '../../../domain/adventure/stage_node.dart';

/// 05_FRONTEND.md §2 `/adventure`: 장·스테이지 노드, 진행도.
/// 09_MILESTONES.md T-32: "챕터1 10스테이지 노드, 진행도".
class AdventureMapScreen extends StatelessWidget {
  const AdventureMapScreen({
    super.key,
    required this.chapterStages,
    required this.clearedStageIds,
    required this.onStageTap,
  });

  final List<StageDef> chapterStages;
  final Set<String> clearedStageIds;
  final void Function(StageDef stage) onStageTap;

  @override
  Widget build(BuildContext context) {
    final nodes = buildStageNodes(chapterStages, clearedStageIds);
    return Scaffold(
      appBar: AppBar(title: const Text('모험 지도')),
      body: ListView.builder(
        itemCount: nodes.length,
        itemBuilder: (context, i) {
          final node = nodes[i];
          return ListTile(
            key: ValueKey('stage_node_${node.stage.id}'),
            enabled: node.isPlayable,
            leading: _StatusIcon(status: node.status),
            title: Text(node.stage.nameKey.isEmpty ? node.stage.id : node.stage.nameKey),
            subtitle: Text(_statusLabel(node.status)),
            onTap: node.isPlayable ? () => onStageTap(node.stage) : null,
          );
        },
      ),
    );
  }

  String _statusLabel(StageStatus status) => switch (status) {
    StageStatus.cleared => '클리어',
    StageStatus.current => '도전 가능',
    StageStatus.locked => '잠김',
  };
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});
  final StageStatus status;

  @override
  Widget build(BuildContext context) => Icon(
    switch (status) {
      StageStatus.cleared => Icons.check_circle,
      StageStatus.current => Icons.play_circle_fill,
      StageStatus.locked => Icons.lock,
    },
    key: ValueKey('stage_status_icon_${status.name}'),
  );
}
