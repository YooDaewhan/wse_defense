/// 02_TAG_SYSTEM.md §3.7 전체 목록.
/// 새 스탯 추가는 이 enum과 `StatSheet` 생성 시 넘기는 base 값 한 줄만 있으면 된다.
enum StatKey {
  maxHp,
  atk,
  def,
  attackPeriod,
  attackWindup,
  attackRange,
  moveSpeed,
  hpSegments,
  knockbackResist,
  knockbackDistance,
  summonCost,
  resummonCooldown,
  healPower,
  healReceived,
  dmgDealtVs,
  dmgTakenFrom,
  aoeMaxTargets,
  prayerGainOnKill,
}
