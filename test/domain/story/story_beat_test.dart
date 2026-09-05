import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/domain/story/story_beat.dart';

void main() {
  test('parses every beat type', () {
    expect((StoryBeat.fromJson({'type': 'BG', 'key': 'bg_a'}) as BgBeat).key, 'bg_a');
    expect((StoryBeat.fromJson({'type': 'BGM', 'key': 'bgm_a'}) as BgmBeat).key, 'bgm_a');
    expect((StoryBeat.fromJson({'type': 'SFX', 'key': 'sfx_a'}) as SfxBeat).key, 'sfx_a');

    final line = StoryBeat.fromJson({
      'type': 'LINE',
      'speakerKey': 'spk.girl',
      'textKey': 'story.l1',
      'portraitKey': 'por_girl',
    }) as LineBeat;
    expect(line.speakerKey, 'spk.girl');
    expect(line.textKey, 'story.l1');
    expect(line.portraitKey, 'por_girl');

    final fade = StoryBeat.fromJson({'type': 'FADE', 'to': 'BLACK', 'durationMs': 800}) as FadeBeat;
    expect(fade.to, 'BLACK');
    expect(fade.durationMs, 800);
  });

  test('a LINE beat without a speaker or portrait is fine (narration)', () {
    final line = StoryBeat.fromJson({'type': 'LINE', 'textKey': 'story.narration'}) as LineBeat;
    expect(line.speakerKey, isNull);
    expect(line.portraitKey, isNull);
  });

  test('an unknown beat type throws rather than silently producing something wrong', () {
    expect(() => StoryBeat.fromJson({'type': 'UNKNOWN'}), throwsFormatException);
  });
}
