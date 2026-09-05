/// 03_BATTLE_ENGINE.md §2.
enum EntityAction {
  idle, // 대기 (표적 없음)
  moving,
  attackWindup, // 선딜 A
  attackRecover, // 후딜 R
  stunned, // 멈칫
  knockback,
  dead,
}
