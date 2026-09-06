/**
 * assets/data/v1/characters.json의 `base.resummonCooldownSec` 서버 사본.
 * V7(소환 간격 검증)이 슬롯의 캐릭터별 쿨다운을 알아야 해서 필요하다.
 * starterCharacters.ts와 같은 이유로 임시 상수 — T-40 데이터 배포 파이프라인이
 * 서버 사본(stagesMeta류)을 실제로 동기화하게 되면 그쪽에서 읽도록 바꾼다.
 */
export const CHARACTER_RESUMMON_COOLDOWN_SEC: Readonly<Record<string, number>> = {
  CHR_ACORN: 4,
  CHR_DROPLET: 8,
  CHR_MUSHROOM: 12,
  CHR_BIRD: 18,
  CHR_BEAR: 30,
};
