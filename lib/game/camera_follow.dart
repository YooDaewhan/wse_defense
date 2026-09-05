import '../battle/tag/tag_query.dart';
import '../battle/world/battle_world.dart';

/// 05_FRONTEND.md §4.4: 카메라는 전선(가장 앞선 아군과 가장 앞선 적의 중간)을
/// 따라간다. 드래그 중엔 수동 모드로 전환하고, 마지막 드래그로부터
/// [autoResumeAfterSec] 지난 뒤 자동 추적으로 복귀한다.
///
/// 좌표는 전부 `BattleEntity.x`와 같은 고정소수점(POS_SCALE) 단위 —
/// 픽셀 변환/뷰포트 클램프는 렌더 레이어(BattleGame)의 몫이라 여기서는
/// 하지 않는다. Flame 의존이 없어 순수 로직으로 테스트한다.
class CameraFollow {
  CameraFollow({this.springFactor = 0.08, this.autoResumeAfterSec = 3.0});

  final double springFactor;
  final double autoResumeAfterSec;

  double camX = 0;
  bool _manual = false;
  double _timeSinceDrag = 0;

  bool get isManual => _manual;

  /// 드래그 입력이 들어올 때마다 호출 — 수동 모드로 전환하고 타이머 리셋.
  void onDragDelta(double dx) {
    camX += dx;
    _manual = true;
    _timeSinceDrag = 0;
  }

  /// 매 프레임 호출. 수동 모드면 [autoResumeAfterSec] 경과를 셀 뿐 카메라를
  /// 직접 움직이지 않는다(드래그로 옮긴 위치 유지). 자동 모드면 전선
  /// 중간으로 스프링 추적한다.
  void update(BattleWorld w, double dtSeconds) {
    if (_manual) {
      _timeSinceDrag += dtSeconds;
      if (_timeSinceDrag >= autoResumeAfterSec) _manual = false;
      return;
    }
    camX += (targetX(w) - camX) * springFactor;
  }

  /// 전선 중간(고정소수점 단위). 한쪽이 전멸했으면 그쪽 기지 위치로 대체.
  static int targetX(BattleWorld w) {
    int? frontAlly;
    int? frontEnemy;
    for (final e in w.entities.ordered) {
      if (!e.isAlive) continue;
      if (e.side == Side.ally) {
        if (frontAlly == null || e.x > frontAlly) frontAlly = e.x;
      } else {
        if (frontEnemy == null || e.x < frontEnemy) frontEnemy = e.x;
      }
    }
    frontAlly ??= w.allyBase.x;
    frontEnemy ??= w.enemyBase.x;
    return (frontAlly + frontEnemy) ~/ 2;
  }
}
