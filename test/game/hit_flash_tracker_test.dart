import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/game/anim/hit_flash_tracker.dart';

void main() {
  test('not flashing until hp actually drops', () {
    final t = HitFlashTracker();
    t.update(100, 1 / 60);
    expect(t.isFlashing, isFalse);
    t.update(100, 1 / 60); // 변화 없음
    expect(t.isFlashing, isFalse);
  });

  test('an hp drop starts the flash, which fades out after durationSec', () {
    final t = HitFlashTracker(durationSec: 0.1);
    t.update(100, 0); // 기준치 등록
    t.update(80, 1 / 60); // 피격
    expect(t.isFlashing, isTrue);

    for (var i = 0; i < 5; i++) {
      t.update(80, 1 / 60); // 5프레임 ~= 0.083초, 아직 0.1초 안 지남
    }
    expect(t.isFlashing, isTrue);

    for (var i = 0; i < 5; i++) {
      t.update(80, 1 / 60); // 추가 프레임으로 확실히 0.1초 초과
    }
    expect(t.isFlashing, isFalse);
  });

  test('a second hit while still flashing refreshes the duration', () {
    final t = HitFlashTracker(durationSec: 0.1);
    t.update(100, 0);
    t.update(90, 1 / 60);
    for (var i = 0; i < 4; i++) {
      t.update(90, 1 / 60);
    }
    t.update(70, 1 / 60); // 다시 피격 -> 다시 가득 채워짐
    expect(t.isFlashing, isTrue);
    for (var i = 0; i < 4; i++) {
      t.update(70, 1 / 60); // 총 5프레임(0.083초)만 지남 -- 새로 채워졌으니 아직 유지
    }
    expect(t.isFlashing, isTrue);
  });
}
