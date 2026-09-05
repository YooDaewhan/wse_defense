/// 02_TAG_SYSTEM.md §4.5. 유닛 하나 x 규칙 하나 당 1개.
/// `BattleEntity.relationStates`에 rule.id로 키를 둬 보관한다.
class RelationState {
  bool active = false;
  int activeSince = 0;
  int offCounter = 0;
  int scale = 1;
}
