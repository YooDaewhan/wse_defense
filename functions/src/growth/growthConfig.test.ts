import { costForLevelUp, FOCUS_GOLD_COST } from './growthConfig';

test('costForLevelUp matches lib/domain/growth/growth_config.dart\'s formula (base * growth^(level-1))', () => {
  expect(costForLevelUp(FOCUS_GOLD_COST, 1)).toBe(500); // 500 * 1.18^0
  expect(costForLevelUp({ base: 500, growth: 1.18 }, 2)).toBe(Math.round(500 * 1.18));
});
