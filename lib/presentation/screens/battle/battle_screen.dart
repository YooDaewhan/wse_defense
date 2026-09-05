import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../battle/entity/battle_entity.dart';
import '../../../battle/world/battle_world.dart';
import '../../../game/battle_game.dart';
import '../../../game/tags/unit_detail_info.dart';
import 'battle_hud.dart';
import 'widgets/unit_detail_panel.dart';

/// 05_FRONTEND.md §4.1: Flame 캔버스 + HUD(Flutter 위젯) 오버레이.
/// VFX(T-25)/튜토리얼 오버레이(이후 티켓)는 아직 없다.
class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key, required this.world});

  final BattleWorld world;

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> with SingleTickerProviderStateMixin {
  late final BattleGame _game = BattleGame(battleWorld: widget.world, onUnitTapped: _onUnitTapped);
  late final Ticker _hudTicker;
  BattleEntity? _selectedEntity;

  @override
  void initState() {
    super.initState();
    // BattleGame(Flame)이 자기 루프에서 world를 진행시키는 동안, HUD(순수
    // Flutter 위젯)는 그 world를 매 프레임 다시 읽기만 하면 되므로 별도
    // Ticker로 setState만 걸어준다 — Riverpod 스트림(T-30+)이 생기기 전
    // 임시 연결.
    _hudTicker = createTicker((_) => setState(() {}))..start();
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
        ],
      ),
    );
  }
}
