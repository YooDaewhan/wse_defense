import { RateEntry } from './bannerData';

export interface RolledCharacter {
  characterId: string;
  rarity: number;
  pickup: boolean;
}

/** 04_DATA_SCHEMA.md §12: `rates[]`는 밀리퍼센트 구간을 이어붙인 것
 * (합계 100000) — 누적합 위에서 하나의 구간을 고르고, 그 구간의 pool에서
 * 균등하게 캐릭터 하나를 뽑는다. [rand]는 [0,1) 난수 생성기(테스트는
 * 결정론적 시퀀스, 프로덕션은 crypto 기반). */
export function rollOne(rates: RateEntry[], rand: () => number): RolledCharacter {
  const roll = Math.floor(rand() * 100000);
  let acc = 0;
  for (const entry of rates) {
    acc += entry.totalPct;
    if (roll < acc) return _pickFromPool(entry, rand);
  }
  // rates 합계가 정확히 100000이면 도달하지 않는다(validate_data.dart가
  // 보장) — 부동소수점 경계에 걸리는 극단값 대비 마지막 구간으로 폴백.
  return _pickFromPool(rates[rates.length - 1], rand);
}

function _pickFromPool(entry: RateEntry, rand: () => number): RolledCharacter {
  const idx = Math.floor(rand() * entry.pool.length);
  return { characterId: entry.pool[idx], rarity: entry.rarity, pickup: entry.pickup ?? false };
}

export function rollMany(rates: RateEntry[], count: number, rand: () => number): RolledCharacter[] {
  return Array.from({ length: count }, () => rollOne(rates, rand));
}
