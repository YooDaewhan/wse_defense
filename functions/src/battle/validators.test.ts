import { CHARACTER_RESUMMON_COOLDOWN_SEC } from './characterData';
import { TICKS_PER_SEC } from './constants';
import { BattleInput } from './inputLog';
import { BattleSummary, FormationSnapshot, StageMeta } from './types';
import {
  computeV12Checksum,
  isOutlierResult,
  validateV10FormationOnlySummons,
  validateV12Checksum,
  validateV3Outcome,
  validateV4MinClearTime,
  validateV5MaxClearTime,
  validateV6PrayerBudget,
  validateV7SummonCadence,
  validateV8UltimateBudget,
  validateV9KillCount,
} from './validators';

const meta: StageMeta = {
  timeLimitSec: 300,
  minClearSec: 60,
  maxWaveEnemies: 40,
  maxKillPrayer: 500,
  enemyBaseHp: 5000,
  startingPrayerPower: 200,
  focusBaseRegen: 18,
  maxWeatherBonus: 1,
  firstRewards: [],
  repeatRewards: [],
};

function emptySlots(): FormationSnapshot['slots'] {
  return Array.from({ length: 10 }, () => ({ characterId: null, equipmentInstanceId: null }));
}

const formation: FormationSnapshot = {
  presetIndex: 0,
  formationHash: 'hash-1',
  slots: emptySlots().map((s, i) => (i < 2 ? { characterId: i === 0 ? 'CHR_ACORN' : 'CHR_DROPLET', equipmentInstanceId: null } : s)),
};

const baseSummary: BattleSummary = {
  endTick: 90 * TICKS_PER_SEC,
  totalSummons: 2,
  totalPrayerSpent: 1000,
  ultimateUsed: 1,
  focusBoostStage: 0,
  enemiesKilled: 10,
  enemyBaseHpLeft: 0,
  allyBaseHpLeft: 5000,
  maxFrontlineX: 2000,
  checksum: '',
};

test('V3: known outcome values pass, unknown values are rejected', () => {
  expect(validateV3Outcome('ALLY_WIN')).toBe(true);
  expect(validateV3Outcome('GARBAGE')).toBe(false);
});

test('V4: a clear at or after minClearSec passes, an implausibly fast clear is rejected', () => {
  expect(validateV4MinClearTime(meta.minClearSec * TICKS_PER_SEC, meta)).toBe(true);
  expect(validateV4MinClearTime(meta.minClearSec * TICKS_PER_SEC - 1, meta)).toBe(false);
});

test('V5: a clear within the time limit (+2s grace) passes, a clear past it is rejected', () => {
  expect(validateV5MaxClearTime((meta.timeLimitSec + 2) * TICKS_PER_SEC, meta)).toBe(true);
  expect(validateV5MaxClearTime((meta.timeLimitSec + 3) * TICKS_PER_SEC, meta)).toBe(false);
});

test('V6: prayer spend within the regen+kill budget passes, spend beyond it is rejected', () => {
  const clearSec = baseSummary.endTick / TICKS_PER_SEC;
  const maxAvailable = meta.startingPrayerPower + Math.ceil(meta.focusBaseRegen * clearSec) + meta.maxKillPrayer;
  expect(validateV6PrayerBudget({ ...baseSummary, totalPrayerSpent: maxAvailable }, meta)).toBe(true);
  expect(validateV6PrayerBudget({ ...baseSummary, totalPrayerSpent: maxAvailable + 1 }, meta)).toBe(false);
});

test('V7: summons spaced past the cooldown pass, back-to-back summons of the same slot are rejected', () => {
  const cooldownTicks = CHARACTER_RESUMMON_COOLDOWN_SEC.CHR_ACORN * TICKS_PER_SEC;
  const spaced: BattleInput[] = [
    { type: 'SUMMON', tick: 0, slotIndex: 0 },
    { type: 'SUMMON', tick: cooldownTicks, slotIndex: 0 },
  ];
  expect(validateV7SummonCadence(spaced, 2, formation, CHARACTER_RESUMMON_COOLDOWN_SEC)).toBe(true);

  const tooFast: BattleInput[] = [
    { type: 'SUMMON', tick: 0, slotIndex: 0 },
    { type: 'SUMMON', tick: cooldownTicks - 1, slotIndex: 0 },
  ];
  expect(validateV7SummonCadence(tooFast, 2, formation, CHARACTER_RESUMMON_COOLDOWN_SEC)).toBe(false);
});

test('V7: claimed totalSummons must match the actual number of SummonInput entries', () => {
  const inputs: BattleInput[] = [{ type: 'SUMMON', tick: 0, slotIndex: 0 }];
  expect(validateV7SummonCadence(inputs, 1, formation, CHARACTER_RESUMMON_COOLDOWN_SEC)).toBe(true);
  expect(validateV7SummonCadence(inputs, 2, formation, CHARACTER_RESUMMON_COOLDOWN_SEC)).toBe(false);
});

test('V8: ultimates within the earn-rate budget pass, more than that is rejected', () => {
  const clearSec = baseSummary.endTick / TICKS_PER_SEC;
  const maxUltimates = Math.floor((clearSec - 30) / 60) + 1;
  expect(validateV8UltimateBudget({ ...baseSummary, ultimateUsed: maxUltimates })).toBe(true);
  expect(validateV8UltimateBudget({ ...baseSummary, ultimateUsed: maxUltimates + 1 })).toBe(false);
});

test('V9: kills at or under the wave cap pass, more than the cap is rejected', () => {
  expect(validateV9KillCount({ ...baseSummary, enemiesKilled: meta.maxWaveEnemies }, meta)).toBe(true);
  expect(validateV9KillCount({ ...baseSummary, enemiesKilled: meta.maxWaveEnemies + 1 }, meta)).toBe(false);
});

test('V10: summons into a filled slot pass, summons into an empty slot are rejected', () => {
  const filled: BattleInput[] = [{ type: 'SUMMON', tick: 0, slotIndex: 0 }];
  expect(validateV10FormationOnlySummons(filled, formation)).toBe(true);

  const empty: BattleInput[] = [{ type: 'SUMMON', tick: 0, slotIndex: 5 }];
  expect(validateV10FormationOnlySummons(empty, formation)).toBe(false);
});

test('V12: a checksum computed the same way passes, a tampered one is rejected', () => {
  const expected = computeV12Checksum('deadbeef', 42, 'hash-1');
  expect(validateV12Checksum('deadbeef', 42, 'hash-1', expected)).toBe(true);
  expect(validateV12Checksum('deadbeef', 42, 'hash-1', 'tampered')).toBe(false);
});

test('V13: outlier flagging does not reject, it only signals near-cap results', () => {
  expect(isOutlierResult(baseSummary, meta)).toBe(false);
  expect(isOutlierResult({ ...baseSummary, enemiesKilled: meta.maxWaveEnemies }, meta)).toBe(true);
  expect(isOutlierResult({ ...baseSummary, endTick: meta.minClearSec * TICKS_PER_SEC }, meta)).toBe(true);
});
