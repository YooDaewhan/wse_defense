import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/data/story/story_loader.dart';
import 'package:wse_defense/domain/story/story_beat.dart';

void main() {
  test('loads the real assets/data/v1/story/prologue.json', () async {
    final beats = await loadStoryBeats(
      (path) => File('assets/data/v1/$path').readAsString(),
      'story/prologue.json',
    );

    expect(beats, isNotEmpty);
    expect(beats.whereType<LineBeat>(), isNotEmpty);
    expect(beats.first, isA<BgBeat>());
  });
}
