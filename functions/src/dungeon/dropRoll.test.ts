import { DropEntry } from './dungeonData';
import { aggregateRolls, rollDrops } from './dropRoll';

function sequence(values: number[]): () => number {
  let i = 0;
  return () => values[i++ % values.length];
}

const entry = (over: Partial<DropEntry> & Pick<DropEntry, 'item' | 'min' | 'max'>): DropEntry => ({
  chancePct: 100000,
  bonusDayOnly: false,
  ...over,
});

test('rolls an amount within [min, max] using the injected rng', () => {
  const drops = [entry({ item: 'ITM_GOLD', min: 800, max: 1200 })];
  const result = rollDrops(drops, false, sequence([0])); // rand()=0 -> min
  expect(result).toEqual([{ item: 'ITM_GOLD', amount: 800 }]);

  const resultMax = rollDrops(drops, false, sequence([0.999999]));
  expect(resultMax).toEqual([{ item: 'ITM_GOLD', amount: 1200 }]);
});

test('chancePct gates whether the entry drops at all', () => {
  const drops = [entry({ item: 'ITM_AFFINITY_TREAT', min: 1, max: 1, chancePct: 30000 })];

  const belowThreshold = rollDrops(drops, false, sequence([0.29999, 0]));
  expect(belowThreshold).toEqual([{ item: 'ITM_AFFINITY_TREAT', amount: 1 }]);

  const atThreshold = rollDrops(drops, false, sequence([0.3, 0]));
  expect(atThreshold).toEqual([]);
});

test('bonusDayOnly entries only appear on a bonus day', () => {
  const drops = [entry({ item: 'ITM_SHARD_SUN_T3', min: 1, max: 1, bonusDayOnly: true })];
  expect(rollDrops(drops, false, sequence([0]))).toEqual([]);
  expect(rollDrops(drops, true, sequence([0]))).toEqual([{ item: 'ITM_SHARD_SUN_T3', amount: 1 }]);
});

test('on a bonus day, gold and T1/T2 shards scale by x1.5 (floored), but T3 does not', () => {
  const drops = [
    entry({ item: 'ITM_GOLD', min: 1000, max: 1000 }),
    entry({ item: 'ITM_SHARD_SUN_T1', min: 4, max: 4 }),
    entry({ item: 'ITM_SHARD_SUN_T3', min: 1, max: 1 }),
  ];
  const result = rollDrops(drops, true, sequence([0]));
  expect(result).toEqual([
    { item: 'ITM_GOLD', amount: 1500 },
    { item: 'ITM_SHARD_SUN_T1', amount: 6 }, // floor(4*1.5)=6
    { item: 'ITM_SHARD_SUN_T3', amount: 1 }, // 배율 미적용
  ]);
});

test('aggregateRolls sums amounts per item across multiple rolls (e.g. a 6x sweep)', () => {
  const rolls = [
    [{ item: 'ITM_GOLD', amount: 1000 }, { item: 'ITM_SHARD_SUN_T1', amount: 4 }],
    [{ item: 'ITM_GOLD', amount: 900 }],
  ];
  expect(aggregateRolls(rolls)).toEqual(
    expect.arrayContaining([
      { item: 'ITM_GOLD', amount: 1900 },
      { item: 'ITM_SHARD_SUN_T1', amount: 4 },
    ]),
  );
});
