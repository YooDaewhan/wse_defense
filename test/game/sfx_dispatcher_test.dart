import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/game/vfx/sfx_dispatcher.dart';

void main() {
  test('the same sound requested twice in one frame plays only once', () {
    final played = <String>[];
    final dispatcher = SfxDispatcher(play: played.add);

    dispatcher.beginFrame();
    dispatcher.request('hit.wav');
    dispatcher.request('hit.wav');
    dispatcher.request('hit.wav');

    expect(played, ['hit.wav']);
  });

  test('different sounds in the same frame all play', () {
    final played = <String>[];
    final dispatcher = SfxDispatcher(play: played.add);

    dispatcher.beginFrame();
    dispatcher.request('hit.wav');
    dispatcher.request('attack.wav');

    expect(played, unorderedEquals(['hit.wav', 'attack.wav']));
  });

  test('the same sound plays again once a new frame begins', () {
    final played = <String>[];
    final dispatcher = SfxDispatcher(play: played.add);

    dispatcher.beginFrame();
    dispatcher.request('hit.wav');
    dispatcher.beginFrame();
    dispatcher.request('hit.wav');

    expect(played, ['hit.wav', 'hit.wav']);
  });
}
