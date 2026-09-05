import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../battle/world/battle_world.dart';
import '../../../game/battle_game.dart';
import 'battle_hud.dart';

/// 05_FRONTEND.md §4.1: Flame 캔버스 + HUD(Flutter 위젯) 오버레이.
/// VFX(T-25)/일시정지·튜토리얼 오버레이(이후 티켓)는 아직 없다.
class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key, required this.world});

  final BattleWorld world;

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> with SingleTickerProviderStateMixin {
  late final BattleGame _game = BattleGame(battleWorld: widget.world);
  late final Ticker _hudTicker;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game),
          BattleHud(world: widget.world, speedMultiplier: _game.speedMultiplier, onSpeedChanged: _setSpeed),
        ],
      ),
    );
  }
}
