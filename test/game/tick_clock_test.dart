import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/game/tick_clock.dart';

void main() {
  test('60fps for 1 real second at speed 1 consumes exactly 30 ticks', () {
    final clock = TickClock();
    var total = 0;
    for (var i = 0; i < 60; i++) {
      total += clock.consume(1 / 60, 1);
    }
    expect(total, 30);
  });

  test('same wall-clock frames at speed 2 consume exactly double the ticks', () {
    final clock1x = TickClock();
    final clock2x = TickClock();
    var total1x = 0;
    var total2x = 0;
    for (var i = 0; i < 120; i++) {
      total1x += clock1x.consume(1 / 60, 1);
      total2x += clock2x.consume(1 / 60, 2);
    }
    expect(total2x, total1x * 2);
  });

  test('uneven per-frame dt with the same total elapsed time consumes the same total ticks as fixed dt', () {
    final fixed = TickClock();
    final jittery = TickClock();
    var fixedTotal = 0;
    var jitteryTotal = 0;

    const frames = 300; // 5 실시간초 분량(60fps 기준)
    for (var i = 0; i < frames; i++) {
      fixedTotal += fixed.consume(1 / 60, 1);
      // 프레임마다 들쭉날쭉해도(평균은 여전히 1/60): (1/40 + 1/120)/2 == 1/60,
      // 흘려보낸 총 실시간은 fixed와 동일하다.
      final jitterDt = (i % 2 == 0) ? 1 / 40 : 1 / 120;
      jitteryTotal += jittery.consume(jitterDt, 1);
    }

    expect(fixedTotal, 150); // 5초 x 30틱/초
    expect(jitteryTotal, fixedTotal);
  });

  test('alpha stays within [0, 1) and reflects leftover accumulator', () {
    final clock = TickClock();
    clock.consume(1 / 60, 1); // 1/60초 누적, 1/30초 미만이라 아직 0틱
    expect(clock.alpha, closeTo(0.5, 0.001)); // (1/60) / (1/30) = 0.5
  });
}
