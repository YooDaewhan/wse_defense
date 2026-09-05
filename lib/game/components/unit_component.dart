import 'dart:ui';

import 'package:flame/components.dart';

import '../../battle/constants.dart';
import '../../battle/entity/battle_entity.dart';
import '../../battle/tag/tag_query.dart';
import '../anim/character_anim_set.dart';
import '../anim/clip_resolver.dart';
import '../anim/hit_flash_tracker.dart';
import '../render_constants.dart';

/// 09_MILESTONES.md T-22/T-23: 아트가 없어(P0~P1 원칙) 색 사각형 하나로
/// 유닛을 표현한다(아군 파랑 / 적 빨강). `animSet`이 없어도(아틀라스 없음)
/// 절대 크래시하지 않고 그대로 플레이스홀더를 그린다.
///
/// 05_FRONTEND.md §4.3 위치 보간: 시뮬은 30Hz, 렌더는 그보다 빠를 수 있어
/// 매 프레임 `_prevSimX`~`_currSimX`를 alpha로 선형 보간한다.
///
/// §5.2/§2.4 피격 처리: [HitFlashTracker]가 hp 감소를 직접 관찰해 틴트+3px
/// 셰이크만 표시하고 클립 선택([resolveClip])에는 전혀 관여하지 않는다.
class UnitComponent extends PositionComponent {
  UnitComponent({required BattleEntity entity, this.animSet})
    : _currSimX = entity.x,
      _prevSimX = entity.x,
      _basePaint = Paint()
        ..color = entity.side == Side.ally
            ? const Color(0xFF3B82F6)
            : const Color(0xFFDC2626),
      _flashPaint = Paint()..color = const Color(0xFFFFFFFF),
      super(
        size: Vector2.all(entity.def.base.collisionRadius * 2.0),
        anchor: Anchor.center,
      );

  /// 08_ASSET_PRODUCTION.md §2.1 `death`(6프레임/12fps) 기본값 — 캐릭터별
  /// 클립 데이터가 없을 때(아틀라스 미제작)도 사망 컴포넌트가 영원히 남지
  /// 않도록 하는 폴백 길이.
  static const double _fallbackDeathDurationSec = 0.5;
  static const double _shakePixels = 3;

  final CharacterAnimSet? animSet;
  final Paint _basePaint;
  final Paint _flashPaint;
  final HitFlashTracker _hitFlash = HitFlashTracker();

  int _prevSimX;
  int _currSimX;
  double? _deathElapsedSec;

  ResolvedFrame _frame = const ResolvedFrame(clipName: 'idle');
  ResolvedFrame get frame => _frame; // 테스트/디버그 관찰용

  double get _deathDurationSec => animSet?.clip('death')?.durationSec ?? _fallbackDeathDurationSec;

  /// `death` 클립이 끝났는가 — 08_ASSET_PRODUCTION.md 완료조건
  /// "사망 클립이 끝난 뒤 컴포넌트 제거"의 신호.
  bool get readyToRemove => _deathElapsedSec != null && _deathElapsedSec! >= _deathDurationSec;

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    if (_hitFlash.isFlashing) {
      canvas.save();
      canvas.translate(_shakePixels, 0);
      canvas.drawRect(rect, _flashPaint);
      canvas.restore();
    } else {
      canvas.drawRect(rect, _basePaint);
    }
  }

  /// 매 프레임 호출(월드가 이번 프레임에 틱을 밟았는지와 무관하게).
  /// [alpha]는 `TickClock.alpha`, [currentTick]/[dtSeconds]는 스폰 판정과
  /// 피격/사망 타이머에 쓰인다.
  void applyState(BattleEntity e, double alpha, int currentTick, double dtSeconds) {
    if (e.x != _currSimX) {
      _prevSimX = _currSimX;
      _currSimX = e.x;
    }
    final logicalX = _prevSimX + (_currSimX - _prevSimX) * alpha;
    position.x = logicalX / posScale * pixelsPerLogicalUnit;
    // 레인(y) 개념이 아직 없어(전투 코어는 x만 다룸) 전부 같은 높이에 둔다.
    position.y = viewHeight / 2;
    priority = (position.x * 10).toInt(); // 앞쪽(x가 큰 쪽)이 위로 겹침

    _hitFlash.update(e.hp, dtSeconds);
    _frame = resolveClip(e, animSet, currentTick);
    if (_frame.clipName == 'death') {
      _deathElapsedSec = (_deathElapsedSec ?? 0) + dtSeconds;
    }
  }
}
