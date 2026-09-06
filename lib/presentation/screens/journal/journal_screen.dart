import 'package:flutter/material.dart';

/// 05_FRONTEND.md §9.1 "여행 수첩": 스킵해도 등록되어 다시 볼 수 있는
/// 스토리 목록. `StoryPlayerScreen`은 스스로 재생 가능 여부를 판단하지
/// 않고("replayable 게이트는 호출부가 맡는다") 이 화면이 그 게이트다 --
/// [unlockedSceneIds]에 없는 장면은 다시보기 버튼 자체가 없다.
///
/// 지금은 프롤로그 하나뿐이라(scenes 카탈로그 자체가 story/prologue.json
/// 하나) 목록이 최대 1개다 -- 나중에 장면이 늘면 그 카탈로그(제목 등)를
/// 어디서 읽어올지부터 새로 정해야 한다(데이터 로더 몫, 이 화면의 배선
/// 몫이 아님).
class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key, required this.unlockedSceneIds, required this.onReplayTap});

  final Set<String> unlockedSceneIds;
  final void Function(String sceneId) onReplayTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('여행 수첩')),
      body: unlockedSceneIds.isEmpty
          ? const Center(child: Text('아직 확인한 이야기가 없습니다', key: ValueKey('journal_empty')))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final sceneId in unlockedSceneIds)
                  ListTile(
                    key: ValueKey('journal_scene_$sceneId'),
                    title: Text(sceneId),
                    trailing: TextButton(
                      key: ValueKey('journal_replay_$sceneId'),
                      onPressed: () => onReplayTap(sceneId),
                      child: const Text('다시보기'),
                    ),
                  ),
              ],
            ),
    );
  }
}
