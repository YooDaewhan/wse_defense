import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import '../battle/constants.dart';
import '../battle/world/battle_world.dart';
import 'anim/animation_bank.dart';
import 'camera_follow.dart';
import 'components/unit_component.dart';
import 'render_constants.dart';
import 'tick_clock.dart';

/// 09_MILESTONES.md T-22/T-23 / 05_FRONTEND.md §4. 아트가 아직 없어(P0~P1
/// 원칙) 색 사각형 플레이스홀더로만 렌더한다 — 배경/베이스/HUD는 이후 티켓.
///
/// `animationBank`는 기본적으로 비어 있다 — 실제 아틀라스/클립 데이터
/// 로더가 아직 없어(캐릭터 데이터에 `art` 필드 자체가 없음) 모든 캐릭터가
/// 항상 플레이스홀더+통짜 attack으로 폴백한다. 나중에 데이터가 생기면
/// 채워진 `AnimationBank`를 주입하기만 하면 된다.
class BattleGame extends FlameGame with DragCallbacks {
  BattleGame({required this.battleWorld, this.speedMultiplier = 1.0, AnimationBank? animationBank})
    : animationBank = animationBank ?? AnimationBank();

  /// `FlameGame.world`(Flame 컴포넌트 트리 루트)와 이름이 겹쳐 별도로 둔다.
  final BattleWorld battleWorld;
  double speedMultiplier;
  final AnimationBank animationBank;

  final TickClock clock = TickClock();
  final CameraFollow cameraFollow = CameraFollow();
  final Map<int, UnitComponent> _units = {};

  /// 한 번 death 클립까지 재생하고 치운 엔티티 id — `BattleWorld.entities`는
  /// 죽은 엔티티를 절대 지우지 않으므로(§1 EntityStore), 이 기록이 없으면
  /// 다음 프레임에 새 컴포넌트가 또 만들어져 죽었다 살아났다를 반복한다.
  final Set<int> _reaped = {};

  /// 테스트/디버그 관찰용 — 현재 살아있는 컴포넌트 매핑을 그대로 노출한다.
  Map<int, UnitComponent> get unitComponents => _units;

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

    _syncUnits(dt);
  }

  /// 08_ASSET_PRODUCTION.md 완료조건: 사망 컴포넌트는 즉시가 아니라
  /// death 클립이 끝난 뒤(`UnitComponent.readyToRemove`) 치운다.
  void _syncUnits(double dt) {
    for (final e in battleWorld.entities.ordered) {
      if (_reaped.contains(e.id)) continue;

      var c = _units[e.id];
      if (c == null) {
        c = UnitComponent(entity: e, animSet: animationBank.of(e.def.id));
        _units[e.id] = c;
        _flameWorld.add(c);
      }
      c.applyState(e, clock.alpha, battleWorld.tick, dt);
      if (c.readyToRemove) {
        _reaped.add(e.id);
        _units.remove(e.id);
        c.removeFromParent();
      }
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    // 손가락을 오른쪽으로 끌면(양수 delta) 화면 기준 왼쪽(이전 장면)을 더
    // 보고 싶다는 뜻이라 카메라 목표 x는 반대로 움직인다.
    cameraFollow.onDragDelta(-event.localDelta.x / pixelsPerLogicalUnit * posScale);
  }
}
