import 'package:flutter/material.dart';

/// 05_FRONTEND.md `/summon/trial/:id`. 09_MILESTONES.md T-51 완료조건:
/// "미보유 픽업 캐릭터를 지정 레벨로 사용, 보상 없음, 진행도 영향 없음"
/// -- 실제 보상·진행도 미반영은 서버(startBattle/submitBattle)가 보장하고,
/// 이 화면은 그 사실을 안내한 뒤 체험전 시작만 요청한다.
class TrialScreen extends StatelessWidget {
  const TrialScreen({super.key, required this.characterId, required this.onStartTrial});

  final String characterId;
  final VoidCallback onStartTrial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('체험전')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              characterId,
              key: const ValueKey('trial_character_id'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('지정 레벨로 체험합니다. 보상은 없고 진행도에 영향을 주지 않습니다.'),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                key: const ValueKey('trial_start_button'),
                onPressed: onStartTrial,
                child: const Text('체험 시작'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
