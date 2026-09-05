import 'dart:ui';

import 'package:flame/components.dart';

import '../../battle/constants.dart';
import '../../battle/entity/battle_entity.dart';
import '../../battle/tag/tag_query.dart';
import '../render_constants.dart';

/// 09_MILESTONES.md T-22: 아트 없이 색 사각형 하나로 유닛을 표현한다
/// (아군 파랑 / 적 빨강). 애니메이션·클립 매핑은 T-23 스코프.
///
/// 05_FRONTEND.md §4.3 위치 보간: 시뮬은 30Hz, 렌더는 그보다 빠를 수 있어
/// 매 프레임 `_prevSimX`~`_currSimX`를 alpha로 선형 보간한다.
class UnitComponent extends PositionComponent {
  UnitComponent({required BattleEntity entity})
    : _currSimX = entity.x,
      _prevSimX = entity.x,
      _paint = Paint()
        ..color = entity.side == Side.ally
            ? const Color(0xFF3B82F6)
            : const Color(0xFFDC2626),
      super(
        size: Vector2.all(entity.def.base.collisionRadius * 2.0),
        anchor: Anchor.center,
      );

  int _prevSimX;
  int _currSimX;
  final Paint _paint;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
  }

  /// 매 프레임(월드 스텝 여부와 무관하게) 호출 — [alpha]는 `TickClock.alpha`.
  void applyState(BattleEntity e, double alpha) {
    if (e.x != _currSimX) {
      _prevSimX = _currSimX;
      _currSimX = e.x;
    }
    final logicalX = _prevSimX + (_currSimX - _prevSimX) * alpha;
    position.x = logicalX / posScale * pixelsPerLogicalUnit;
    // 레인(y) 개념이 아직 없어(전투 코어는 x만 다룸) 전부 같은 높이에 둔다.
    position.y = viewHeight / 2;
    priority = (position.x * 10).toInt(); // 앞쪽(x가 큰 쪽)이 위로 겹침
  }
}
