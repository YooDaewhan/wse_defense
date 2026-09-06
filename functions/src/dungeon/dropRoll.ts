import { Delta } from '../common/types';
import { DropEntry } from './dungeonData';

export type RolledItem = Delta;

/** 07_DUNGEON_EXCHANGE.md §3.2 요일 보너스: 골드/T1/T2는 ×1.5(내림), T3는
 * 별도 `bonusDayOnly` 행으로 확정 지급(이미 드랍표에 포함) — 그래서 여기서
 * T3에는 배율을 곱하지 않는다. */
function isWeekdayBonusScaled(item: string): boolean {
  return item === 'ITM_GOLD' || item.endsWith('_T1') || item.endsWith('_T2');
}

/** 한 판(또는 소탕 1회분)의 드랍을 굴린다. [rand]는 [0,1) 난수 생성기 —
 * 프로덕션은 crypto 기반, 테스트는 결정론적 시퀀스를 주입한다. */
export function rollDrops(drops: DropEntry[], bonusDay: boolean, rand: () => number): RolledItem[] {
  const results: RolledItem[] = [];
  for (const entry of drops) {
    if (entry.bonusDayOnly && !bonusDay) continue;
    if (entry.chancePct < 100000) {
      const roll = Math.floor(rand() * 100000);
      if (roll >= entry.chancePct) continue;
    }
    let amount = entry.min + Math.floor(rand() * (entry.max - entry.min + 1));
    if (bonusDay && isWeekdayBonusScaled(entry.item)) {
      amount = Math.floor(amount * 1.5);
    }
    if (amount > 0) results.push({ item: entry.item, amount });
  }
  return results;
}

/** 소탕 N회처럼 여러 번 굴린 결과를 아이템별로 합산한다. */
export function aggregateRolls(rolls: RolledItem[][]): RolledItem[] {
  const totals = new Map<string, number>();
  for (const roll of rolls) {
    for (const { item, amount } of roll) {
      totals.set(item, (totals.get(item) ?? 0) + amount);
    }
  }
  return [...totals.entries()].map(([item, amount]) => ({ item, amount }));
}
