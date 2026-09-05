import '../tag/tag_query.dart';

/// 03_BATTLE_ENGINE.md §2.1: 모닥불(아군)/둥지(적). 이동·공격·태그가 없어
/// `BattleEntity`와 분리해 분기를 줄인다.
class BaseEntity {
  BaseEntity({required this.side, required this.x, required this.maxHp, int? hp})
    : hp = hp ?? maxHp;

  final Side side;
  int hp;
  final int maxHp;
  int x;
  bool damageImmune = false; // 보스 예고 중 무적
  bool destroyed = false;
}
