import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../battle/entity/battle_entity.dart';
import '../../../battle/world/battle_world.dart';
import '../../../domain/tutorial/tutorial_controller.dart';
import '../../../domain/tutorial/tutorial_gate.dart';
import '../../../game/battle_game.dart';
import '../../../game/tags/unit_detail_info.dart';
import '../tutorial/tutorial_overlay.dart';
import 'battle_hud.dart';
import 'widgets/unit_detail_panel.dart';

/// 05_FRONTEND.md §4.1: Flame 캔버스 + HUD(Flutter 위젯) 오버레이.
/// [tutorialController]가 있으면(10_WIRING_PLAN.md T-57 `/tutorial`) 그
/// 위에 [TutorialOverlay]를 얹고 매 프레임 진행시킨다. VFX(T-25)는 아직
/// 없다.
class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key, required this.world, this.tutorialController});

  final BattleWorld world;
  final TutorialController? tutorialController;

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> with SingleTickerProviderStateMixin {
  late final BattleGame _game = BattleGame(battleWorld: widget.world, onUnitTapped: _onUnitTapped);
  late final Ticker _hudTicker;
  BattleEntity? _selectedEntity;

  // TutorialContext가 관측 못 하는(호출부가 직접 추적해야 하는) 상태.
  int? _prevUltimateStock;
  bool _everUsedUltimate = false;
  bool _rewardClaimed = false;

  @override
  void initState() {
    super.initState();
    // BattleGame(Flame)이 자기 루프에서 world를 진행시키는 동안, HUD(순수
    // Flutter 위젯)는 그 world를 매 프레임 다시 읽기만 하면 되므로 별도
    // Ticker로 setState만 걸어준다 — Riverpod 스트림(T-30+)이 생기기 전
    // 임시 연결. 튜토리얼 컨트롤러도 같은 프레임에 같이 진행시킨다.
    _hudTicker = createTicker((_) {
      _tickTutorial();
      setState(() {});
    })..start();
  }

  void _tickTutorial() {
    final controller = widget.tutorialController;
    if (controller == null || controller.isComplete) return;
    final world = widget.world;

    // "필살기를 한 번이라도 썼는가"는 world에 직접 남지 않는다(재고는
    // 다시 차오름) -- 재고가 줄어든 순간을 감지해서 대신 기록한다.
    final stock = world.ultimateStock;
    if (_prevUltimateStock != null && stock < _prevUltimateStock!) _everUsedUltimate = true;
    _prevUltimateStock = stock;

    // 보상 수령은 전투 밖 UI 이벤트지만, 튜토리얼에서는 승리 즉시로
    // 둔다(tutorial_flow_test.dart와 같은 플레이스홀더 규칙).
    if (world.outcome != null) _rewardClaimed = true;

    controller.tick(TutorialContext(world: world, everUsedUltimate: _everUsedUltimate, rewardClaimed: _rewardClaimed));
  }

  @override
  void dispose() {
    _hudTicker.dispose();
    super.dispose();
  }

  void _setSpeed(double speed) => setState(() => _game.speedMultiplier = speed);

  void _togglePause() {
    setState(() {
      _game.paused = !_game.paused;
      if (!_game.paused) _selectedEntity = null; // §6.1: 상세 패널은 일시정지 중에만
    });
  }

  /// §6.1: "유닛 탭 → 상세 패널(일시정지 상태에서만)". 실행 중 탭은 무시한다.
  void _onUnitTapped(BattleEntity entity) {
    if (!_game.paused) return;
    setState(() => _selectedEntity = entity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game),
          BattleHud(world: widget.world, speedMultiplier: _game.speedMultiplier, onSpeedChanged: _setSpeed),
          Positioned(
            top: 8,
            left: 8,
            child: IconButton(
              key: const ValueKey('pause_toggle'),
              icon: Icon(_game.paused ? Icons.play_arrow : Icons.pause),
              onPressed: _togglePause,
            ),
          ),
          if (_game.paused && _selectedEntity != null)
            UnitDetailPanel(
              info: unitDetailInfo(_selectedEntity!, widget.world.tagRegistry),
              onClose: () => setState(() => _selectedEntity = null),
            ),
          if (widget.tutorialController != null) TutorialOverlay(step: widget.tutorialController!.currentStep),
        ],
      ),
    );
  }
}
