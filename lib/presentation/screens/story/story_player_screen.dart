import 'package:flutter/material.dart';

import '../../../data/local/journal_repository.dart';
import '../../../domain/story/story_beat.dart';

/// 05_FRONTEND.md §9.1 프롤로그(및 일반 스토리 beat) 재생기.
/// "정적 일러 + 카메라 이동 + 파티클"은 아트가 없어(P0~P1) 텍스트만
/// 순차 재생한다 — BG/BGM/SFX/FADE는 실제 연출 자원이 없어 텍스트 없이
/// 즉시 다음 beat로 넘어간다(자리 표시자).
///
/// "스킵해도 journal에 등록되어 다시 볼 수 있다"(§9.1) — 끝까지 봐도,
/// 스킵해도 결과는 같다: [sceneId]가 [journalStore]에 등록되고
/// [onFinished]가 불린다. `replayable` 게이트는 이 화면이 아니라
/// 호출부(여행 수첩)가 맡는다 — 이 화면 자체는 언제든 다시 재생 가능하다.
class StoryPlayerScreen extends StatefulWidget {
  const StoryPlayerScreen({
    super.key,
    required this.sceneId,
    required this.beats,
    required this.journalStore,
    required this.onFinished,
  });

  final String sceneId;
  final List<StoryBeat> beats;
  final JournalStore journalStore;
  final VoidCallback onFinished;

  @override
  State<StoryPlayerScreen> createState() => _StoryPlayerScreenState();
}

class _StoryPlayerScreenState extends State<StoryPlayerScreen> {
  late int _index = _firstLineOrEnd(0);

  /// BG/BGM/SFX/FADE는 보여줄 텍스트가 없어 즉시 통과 — 다음 LINE beat나
  /// 끝에 도달할 때까지 건너뛴다.
  int _firstLineOrEnd(int from) {
    var i = from;
    while (i < widget.beats.length && widget.beats[i] is! LineBeat) {
      i++;
    }
    return i;
  }

  LineBeat? get _currentLine => _index < widget.beats.length ? widget.beats[_index] as LineBeat : null;

  void _advance() {
    if (_index >= widget.beats.length) {
      _finish();
      return;
    }
    final next = _firstLineOrEnd(_index + 1);
    if (next >= widget.beats.length) {
      setState(() => _index = next);
      _finish();
    } else {
      setState(() => _index = next);
    }
  }

  void _finish() {
    widget.journalStore.markUnlocked(widget.sceneId);
    widget.onFinished();
  }

  void _skip() {
    setState(() => _index = widget.beats.length);
    _finish();
  }

  @override
  Widget build(BuildContext context) {
    final line = _currentLine;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              key: const ValueKey('story_tap_area'),
              behavior: HitTestBehavior.opaque,
              onTap: _advance,
              child: SizedBox.expand(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: line == null
                        ? const SizedBox.shrink()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (line.speakerKey != null)
                                Text(
                                  line.speakerKey!,
                                  key: const ValueKey('story_speaker'),
                                  style: const TextStyle(color: Colors.amber),
                                ),
                              Text(
                                line.textKey,
                                key: const ValueKey('story_text'),
                                style: const TextStyle(color: Colors.white, fontSize: 18),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 16,
              child: TextButton(
                key: const ValueKey('story_skip'),
                onPressed: _skip,
                child: const Text('스킵', style: TextStyle(color: Colors.white70)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
