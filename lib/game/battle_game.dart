import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import '../battle/constants.dart';
import '../battle/world/battle_world.dart';
import 'camera_follow.dart';
import 'components/unit_component.dart';
import 'render_constants.dart';
import 'tick_clock.dart';

/// 09_MILESTONES.md T-22 / 05_FRONTEND.md §4. 아트가 아직 없어(P0~P1 원칙)
/// 색 사각형 플레이스홀더로만 렌더한다 — 배경/베이스/HUD는 이후 티켓.
///
/// 사망 유닛은 (T-23의 사망 클립이 아직 없어) 발견 즉시 컴포넌트를
/// 제거한다 — 클립 종료까지 남겨두는 `_reapDead()`는 애니메이션이 생기는
/// T-23에서 붙인다.
class BattleGame extends FlameGame with DragCallbacks {
  BattleGame({required this.battleWorld, this.speedMultiplier = 1.0});

  /// `FlameGame.world`(Flame 컴포넌트 트리 루트)와 이름이 겹쳐 별도로 둔다.
  final BattleWorld battleWorld;
  double speedMultiplier;

  final TickClock clock = TickClock();
  final CameraFollow cameraFollow = CameraFollow();
  final Map<int, UnitComponent> _units = {};

  late final World _flameWorld;
  late final CameraComponent _camera;

  @override
  Color backgroundColor() => const Color(0xFF87CEEB);

  @override
  Future<void> onLoad() async {
    _flameWorld = World();
    _camera = CameraComponent.withFixedResolution(
      width: viewWidth,
      height: viewHeight,
      world: _flameWorld,
    );
    await addAll([_flameWorld, _camera]);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (battleWorld.phase == BattlePhase.running) {
      final steps = clock.consume(dt, speedMultiplier);
      for (var i = 0; i < steps; i++) {
        battleWorld.step();
      }
    }

    cameraFollow.update(battleWorld, dt);
    _camera.viewfinder.position = Vector2(
      cameraFollow.camX / posScale * pixelsPerLogicalUnit,
      viewHeight / 2,
    );

    _syncUnits();
  }

  void _syncUnits() {
    for (final e in battleWorld.entities.ordered) {
      if (!e.isAlive) {
        _units.remove(e.id)?.removeFromParent();
        continue;
      }
      var c = _units[e.id];
      if (c == null) {
        c = UnitComponent(entity: e);
        _units[e.id] = c;
        _flameWorld.add(c);
      }
      c.applyState(e, clock.alpha);
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    // 손가락을 오른쪽으로 끌면(양수 delta) 화면 기준 왼쪽(이전 장면)을 더
    // 보고 싶다는 뜻이라 카메라 목표 x는 반대로 움직인다.
    cameraFollow.onDragDelta(-event.localDelta.x / pixelsPerLogicalUnit * posScale);
  }
}
