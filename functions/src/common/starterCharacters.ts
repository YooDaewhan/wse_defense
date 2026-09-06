/**
 * 06_BACKEND.md §6.1 "기본 5종 캐릭터". assets/data/v1/characters.json의
 * 현재 전체 캐릭터(5종)와 우연히 일치한다 — 데이터팩이 커지면 이 목록을
 * 실제 "스타터" 플래그가 있는 서버 사본(T-40의 데이터 배포 파이프라인)에서
 * 읽도록 바꿔야 한다.
 */
export const STARTER_CHARACTER_IDS: readonly string[] = [
  'CHR_ACORN',
  'CHR_DROPLET',
  'CHR_MUSHROOM',
  'CHR_BIRD',
  'CHR_BEAR',
];
