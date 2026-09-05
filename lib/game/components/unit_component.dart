import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart' show TextPainter, TextSpan, TextStyle;

import '../../battle/constants.dart';
import '../../battle/entity/battle_entity.dart';
import '../../battle/tag/tag_query.dart';
import '../../battle/tag/tag_registry.dart';
import '../anim/character_anim_set.dart';
import '../anim/clip_resolver.dart';
import '../anim/hit_flash_tracker.dart';
import '../render_constants.dart';
import '../tags/relation_pop_tracker.dart';
import '../tags/unit_tag_icons.dart';

/// 09_MILESTONES.md T-22/T-23/T-27: 아트가 없어(P0~P1 원칙) 색 사각형
/// 하나로 유닛을 표현한다(아군 파랑 / 적 빨강). `animSet`이 없어도(아틀라스
/// 없음) 절대 크래시하지 않고 그대로 플레이스홀더를 그린다.
///
/// 05_FRONTEND.md §4.3 위치 보간: 시뮬은 30Hz, 렌더는 그보다 빠를 수 있어
/// 매 프레임 `_prevSimX`~`_currSimX`를 alpha로 선형 보간한다.
///
/// §5.2/§2.4 피격 처리: [HitFlashTracker]가 hp 감소를 직접 관찰해 틴트+3px
/// 셰이크만 표시하고 클립 선택([resolveClip])에는 전혀 관여하지 않는다.
///
/// §6.1 전투 중 태그 표현: 발밑 최대 2개 아이콘([unitTagIcons]), 관계
/// 발동/해제 시 0.6초 팝([RelationPopTracker]), 탭하면 [onTap] 콜백(상세
/// 패널 표시는 화면 쪽이 일시정지 여부를 보고 결정한다).
class UnitComponent extends PositionComponent with TapCallbacks {
  UnitComponent({
    required BattleEntity entity,
    required this.tagRegistry,
    this.animSet,
    this.onTap,
  }) : _entity = entity,
       _currSimX = entity.x,
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
  static const double _iconRadius = 4;
  static const double _iconGap = 2;

  final TagRegistry tagRegistry;
  final CharacterAnimSet? animSet;
  final void Function(BattleEntity entity)? onTap;

  final Paint _basePaint;
  final Paint _flashPaint;
  final HitFlashTracker _hitFlash = HitFlashTracker();
  final RelationPopTracker _relationPops = RelationPopTracker();

  BattleEntity _entity;
  int _prevSimX;
  int _currSimX;
  double? _deathElapsedSec;

  List<UnitTagIcon> _icons = const [];
  List<RelationPop> _pops = const [];

  ResolvedFrame _frame = const ResolvedFrame(clipName: 'idle');
  ResolvedFrame get frame => _frame; // 테스트/디버그 관찰용
  List<UnitTagIcon> get icons => _icons; // 테스트/디버그 관찰용
  List<RelationPop> get relationPops => _pops; // 테스트/디버그 관찰용

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

    _renderTagIcons(canvas);
    _renderRelationPops(canvas);
  }

  /// §6.1: 발밑에 최대 2개 소형 아이콘. 아트가 없어 관계는 노랑, 태그는
  /// 하양 원 + 텍스트 라벨로 대체한다.
  void _renderTagIcons(Canvas canvas) {
    if (_icons.isEmpty) return;
    final iconPaintRelation = Paint()..color = const Color(0xFFFFC107);
    final iconPaintTag = Paint()..color = const Color(0xFFFFFFFF);
    var cx = size.x / 2 - (_icons.length - 1) * (_iconRadius * 2 + _iconGap) / 2;
    final cy = size.y + _iconRadius + 2;
    for (final icon in _icons) {
      canvas.drawCircle(Offset(cx, cy), _iconRadius, icon.isRelation ? iconPaintRelation : iconPaintTag);
      cx += _iconRadius * 2 + _iconGap;
    }
  }

  /// §6.1: 관계 발동/해제 시 0.6초짜리 속도 화살표(↑/↓) 팝.
  void _renderRelationPops(Canvas canvas) {
    if (_pops.isEmpty) return;
    for (final pop in _pops) {
      final painter = TextPainter(
        text: TextSpan(
          text: pop.speedUp ? '↑' : '↓',
          style: TextStyle(color: pop.speedUp ? const Color(0xFF4CAF50) : const Color(0xFFF44336), fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, Offset(size.x / 2 - painter.width / 2, -painter.height - 4));
    }
  }

  /// 매 프레임 호출(월드가 이번 프레임에 틱을 밟았는지와 무관하게).
  /// [alpha]는 `TickClock.alpha`, [currentTick]/[dtSeconds]는 스폰 판정과
  /// 피격/사망 타이머에 쓰인다.
  void applyState(BattleEntity e, double alpha, int currentTick, double dtSeconds) {
    _entity = e;
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

    _icons = unitTagIcons(e, tagRegistry);
    _pops = _relationPops.update(e, dtSeconds);
  }

  @override
  void onTapDown(TapDownEvent event) => onTap?.call(_entity);
}
