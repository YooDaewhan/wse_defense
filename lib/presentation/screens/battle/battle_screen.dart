import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../../battle/world/battle_world.dart';
import '../../../game/battle_game.dart';

/// 05_FRONTEND.md §4.1: Flame 캔버스 + HUD 오버레이. HUD(T-24)/VFX(T-25)는
/// 아직 없어 `GameWidget`만 얹는다.
class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key, required this.world});

  final BattleWorld world;

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  late final BattleGame _game = BattleGame(battleWorld: widget.world);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: GameWidget(game: _game));
  }
}
