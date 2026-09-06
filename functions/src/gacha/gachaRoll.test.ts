import { RateEntry } from './bannerData';
import { rollMany, rollOne } from './gachaRoll';

function sequence(values: number[]): () => number {
  let i = 0;
  return () => values[i++ % values.length];
}

const rates: RateEntry[] = [
  { rarity: 3, pickup: true, totalPct: 1500, pool: ['CHR_PICKUP'] },
  { rarity: 3, pickup: false, totalPct: 1500, pool: ['CHR_OTHER3'] },
  { rarity: 2, totalPct: 17000, pool: ['CHR_A2', 'CHR_B2'] },
  { rarity: 1, totalPct: 80000, pool: ['CHR_A1'] },
];

test('picks the first (pickup) tier at roll=0', () => {
  const result = rollOne(rates, sequence([0, 0]));
  expect(result).toEqual({ characterId: 'CHR_PICKUP', rarity: 3, pickup: true });
});

test('picks the last tier at roll just under 100000 (upper boundary)', () => {
  const result = rollOne(rates, sequence([0.999999, 0]));
  expect(result).toEqual({ characterId: 'CHR_A1', rarity: 1, pickup: false });
});

test('picks uniformly within a pool of more than one character', () => {
  // roll lands in the rarity-2 tier (1500+1500=3000 .. 20000), then the
  // second rand() call picks the pool index.
  const rollFrac = 3000 / 100000;
  const first = rollOne(rates, sequence([rollFrac, 0]));
  expect(first.characterId).toBe('CHR_A2');
  const second = rollOne(rates, sequence([rollFrac, 0.999999]));
  expect(second.characterId).toBe('CHR_B2');
});

test('rollMany produces exactly `count` results', () => {
  const results = rollMany(rates, 10, sequence([0.999999, 0]));
  expect(results).toHaveLength(10);
  expect(results.every((r) => r.characterId === 'CHR_A1')).toBe(true);
});
