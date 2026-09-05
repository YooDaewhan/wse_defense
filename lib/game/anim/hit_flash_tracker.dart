/// 05_FRONTEND.md §5.2/2.4: 피격은 클립을 바꾸지 않고(공격 모션 중이면
/// 판정 타이밍이 깨지므로) 짧은 흰색 틴트 + 셰이크 오버레이로만 표시한다.
///
/// 이벤트 버스(`DamageDealtEvent`)가 아직 없어(T-25 스코프) hp 감소를 직접
/// 관찰해 트리거한다 — `resolveClip`과 완전히 독립적이라 클립 선택 로직에
/// 전혀 영향을 주지 않는다(그 자체로 "클립을 중단하지 않음"을 보장).
class HitFlashTracker {
  HitFlashTracker({this.durationSec = 0.1});

  final double durationSec;

  int? _prevHp;
  double _remaining = 0;

  bool get isFlashing => _remaining > 0;

  /// 매 프레임 호출. [hp]가 직전보다 줄어 있으면 새로 피격된 것으로 보고
  /// 지속시간을 다시 채운다(공격 중 연속 피격에도 계속 갱신됨).
  void update(int hp, double dtSeconds) {
    if (_prevHp != null && hp < _prevHp!) {
      _remaining = durationSec;
    }
    _prevHp = hp;
    if (_remaining > 0) {
      _remaining -= dtSeconds;
      if (_remaining < 0) _remaining = 0;
    }
  }
}
