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

/**
 * characters.json의 `intrinsicTags` 서버 사본. 깊은 숲 층별 편성 제한
 * (07_DUNGEON_EXCHANGE.md §8)이 팀의 태그 보유량을 확인해야 해서 필요하다.
 *
 * ponytail: 장비가 부여하는 태그·태그 관계(conflicts/exclusiveGroup)까지
 * 반영하는 전체 태그 해석은 배틀 엔진(Dart, lib/battle/tag)에만 있다.
 * 이 게이트 하나를 위해 그 전부를 서버(TS)로 옮기는 건 과하다 — 여기서는
 * 캐릭터 고유 태그의 단순 합만 본다. 장비 태그까지 서버가 검증해야 할
 * 필요가 생기면 그때 옮긴다.
 */
export const CHARACTER_INTRINSIC_TAGS: Readonly<Record<string, Record<string, number>>> = {
  CHR_ACORN: { TAG_TEMPER_FIELD: 1, TAG_RACE_PLANT: 1 },
  CHR_DROPLET: { TAG_TEMPER_MOON: 1, TAG_ELEM_WATER: 1 },
  CHR_MUSHROOM: { TAG_TEMPER_FIELD: 1, TAG_RACE_PLANT: 1 },
  CHR_BIRD: { TAG_TEMPER_SUN: 1, TAG_RACE_ANIMAL: 1 },
  CHR_BEAR: { TAG_TEMPER_MOON: 1, TAG_RACE_ANIMAL: 1 },
};
