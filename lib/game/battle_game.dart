import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import '../battle/constants.dart';
import '../battle/entity/battle_entity.dart';
import '../battle/event/battle_event.dart';
import '../battle/world/battle_world.dart';
import 'anim/animation_bank.dart';
import 'camera_follow.dart';
import 'components/unit_component.dart';
import 'render_constants.dart';
import 'tick_clock.dart';
import 'vfx/damage_text_component.dart';
import 'vfx/object_pool.dart';
import 'vfx/sfx_dispatcher.dart';

const int _damageTextPoolSize = 20; // 05_FRONTEND.md §11 성능 체크리스트

/// 09_MILESTONES.md T-22/T-23 / 05_FRONTEND.md §4. 아트가 아직 없어(P0~P1
/// 원칙) 색 사각형 플레이스홀더로만 렌더한다 — 배경/베이스/HUD는 이후 티켓.
///
/// `animationBank`는 기본적으로 비어 있다 — 실제 아틀라스/클립 데이터
/// 로더가 아직 없어(캐릭터 데이터에 `art` 필드 자체가 없음) 모든 캐릭터가
/// 항상 플레이스홀더+통짜 attack으로 폴백한다. 나중에 데이터가 생기면
/// 채워진 `AnimationBank`를 주입하기만 하면 된다.
class BattleGame extends FlameGame with DragCallbacks {
  BattleGame({
    required this.battleWorld,
    this.speedMultiplier = 1.0,
    AnimationBank? animationBank,
    void Function(String soundId)? onPlaySound,
    this.onUnitTapped,
  }) : animationBank = animationBank ?? AnimationBank(),
       sfx = SfxDispatcher(play: onPlaySound ?? (_) {});

  /// §6.1: 유닛 탭 콜백. 일시정지 여부에 따라 상세 패널을 보여줄지는
  /// 호출부(BattleScreen)가 `paused`를 보고 결정한다 — 여기선 그냥 전달만.
  final void Function(BattleEntity entity)? onUnitTapped;

  /// `FlameGame.world`(Flame 컴포넌트 트리 루트)와 이름이 겹쳐 별도로 둔다.
  final BattleWorld battleWorld;
  double speedMultiplier;
  final AnimationBank animationBank;

  /// 실제 오디오 백엔드는 아직 없어(사운드 에셋 없음) 기본은 no-op —
  /// 테스트/향후 flame_audio 연결부가 `onPlaySound`로 관찰·주입한다.
  final SfxDispatcher sfx;
  late final ObjectPool<DamageTextComponent> _damageTextPool;

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

    _damageTextPool = ObjectPool<DamageTextComponent>(
      maxSize: _damageTextPoolSize,
      create: () {
        final c = DamageTextComponent();
        _flameWorld.add(c);
        return c;
      },
      reset: (_) {}, // showAmount()가 text/position/ttl을 전부 다시 채운다
    );
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
    _dispatchEvents();
  }

  /// 05_FRONTEND.md §4.2: 렌더가 매 프레임 `w.events`를 drain해 VFX/SFX/
  /// 데미지 텍스트로 옮긴다 — 이 호출을 통째로 지워도(구독 중단) 위
  /// `battleWorld.step()`의 결과는 전혀 달라지지 않는다(T-25 완료조건,
  /// event_system_test.dart가 배틀 코어 쪽에서 이미 검증).
  void _dispatchEvents() {
    sfx.beginFrame();
    for (final ev in battleWorld.drainEvents()) {
      switch (ev) {
        case AttackFiredEvent():
          sfx.request('sfx_attack');
        case DamageDealtEvent(:final targetId, :final amount):
          sfx.request('sfx_hit');
          final at = _units[targetId]?.position;
          if (at != null) _damageTextPool.acquire().showAmount(amount, at);
        case DeathEvent():
          sfx.request('sfx_death');
        case UltimateCastEvent():
          sfx.request('sfx_ultimate');
      }
    }
  }

  /// 08_ASSET_PRODUCTION.md 완료조건: 사망 컴포넌트는 즉시가 아니라
  /// death 클립이 끝난 뒤(`UnitComponent.readyToRemove`) 치운다.
  void _syncUnits(double dt) {
    for (final e in battleWorld.entities.ordered) {
      if (_reaped.contains(e.id)) continue;

      var c = _units[e.id];
      if (c == null) {
        c = UnitComponent(
          entity: e,
          tagRegistry: battleWorld.tagRegistry,
          animSet: animationBank.of(e.def.id),
          onTap: onUnitTapped,
        );
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
