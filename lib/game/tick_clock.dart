/// 05_FRONTEND.md §4.3: 시뮬은 30Hz 고정, 렌더는 60Hz(또는 그 이상) 가변.
/// 프레임마다 경과 실시간(dt)을 누적해뒀다가, 한 틱 분량이 쌓일 때마다
/// `world.step()`을 한 번씩 호출해야 하는 횟수를 알려준다.
///
/// 배속(speedMultiplier)은 dt에 곱해 누적할 뿐 — 실제로 몇 틱을 밟을지는
/// 오직 "누적된 시뮬 시간 / 틱 길이"로만 정해진다. 그래서 2배속으로
/// 프레임을 더 듬성듬성 밟아도(realDt가 커도) 같은 실시간이 지나면 정확히
/// 같은 총 틱 수가 나온다 — 순수 정수 tick 기반인 BattleWorld는 그 틱이
/// 어떤 프레임 분포로 도착했는지 전혀 모르므로 결과가 배속과 무관해진다.
class TickClock {
  TickClock({this.ticksPerSecond = 30});

  final int ticksPerSecond;
  double get tickDurationSec => 1 / ticksPerSecond;

  double _accumulator = 0;

  /// 실시간 [dtSeconds] x [speedMultiplier]만큼 누적하고, 그만큼 소비해야
  /// 할 정수 틱 수를 반환한다. 호출부는 반환값만큼 `world.step()`을 부른다.
  int consume(double dtSeconds, double speedMultiplier) {
    _accumulator += dtSeconds * speedMultiplier;
    var steps = 0;
    while (_accumulator >= tickDurationSec) {
      _accumulator -= tickDurationSec;
      steps++;
    }
    return steps;
  }

  /// 다음 틱까지 남은 시간의 비율 [0, 1) — 렌더 위치 보간용 alpha.
  double get alpha => (_accumulator / tickDurationSec).clamp(0.0, 1.0);
}
