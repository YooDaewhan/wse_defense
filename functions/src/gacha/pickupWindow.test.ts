import { BannerMeta } from './bannerData';
import { isActivePickupCharacter } from './pickupWindow';

function banner(overrides: Partial<BannerMeta>): BannerMeta {
  return {
    id: 'BNR_TEST',
    kind: 'STANDARD',
    startAtUtc: null,
    endAtUtc: null,
    cost: { single: { item: 'ITM_RECRUIT_TICKET', amount: 1 }, ten: { item: 'ITM_RECRUIT_TICKET', amount: 10 } },
    givesExchangePoint: false,
    rates: [{ rarity: 3, pickup: true, totalPct: 100000, pool: ['CHR_PICKUP'] }],
    duplicateConversion: { rarity3: 30, rarity2: 10, rarity1: 3, item: 'ITM_COLLECT_FRAGMENT' },
    exchangeTargets: [],
    ...overrides,
  };
}

test('true for a character in a pickup pool of an unbounded (always-open) banner', () => {
  expect(isActivePickupCharacter('CHR_PICKUP', Date.now(), [banner({})])).toBe(true);
});

test('false for a character only in a non-pickup pool', () => {
  const b = banner({ rates: [{ rarity: 1, pickup: false, totalPct: 100000, pool: ['CHR_PICKUP'] }] });
  expect(isActivePickupCharacter('CHR_PICKUP', Date.now(), [b])).toBe(false);
});

test('false once the banner window has ended', () => {
  const b = banner({ startAtUtc: '2020-01-01T00:00:00Z', endAtUtc: '2020-01-31T00:00:00Z' });
  expect(isActivePickupCharacter('CHR_PICKUP', Date.parse('2021-01-01T00:00:00Z'), [b])).toBe(false);
});

test('true while inside the banner window', () => {
  const b = banner({ startAtUtc: '2020-01-01T00:00:00Z', endAtUtc: '2020-01-31T00:00:00Z' });
  expect(isActivePickupCharacter('CHR_PICKUP', Date.parse('2020-01-15T00:00:00Z'), [b])).toBe(true);
});
