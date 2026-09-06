import { createHash } from 'crypto';
import { TICKS_PER_SEC } from './constants';
import { BattleInput } from './inputLog';
import { BATTLE_OUTCOMES, BattleOutcome, BattleSummary, FormationSnapshot, StageMeta } from './types';

/** 06_BACKEND.md §4.4 검증 순서. 각 V*는 순수 함수 — Firestore 접근 없이
 * 단위 테스트로 통과/반려 케이스를 남긴다. 실패 사유는 함수 호출부가
 * 클라이언트에 노출하지 않고 서버 로그로만 남긴다(§4.4 "어떤 검증에
 * 걸렸는지 노출 금지"). */

export function validateV3Outcome(outcome: string): outcome is BattleOutcome {
  return (BATTLE_OUTCOMES as readonly string[]).includes(outcome);
}

export function validateV4MinClearTime(endTick: number, meta: StageMeta): boolean {
  return endTick / TICKS_PER_SEC >= meta.minClearSec;
}

export function validateV5MaxClearTime(endTick: number, meta: StageMeta): boolean {
  return endTick / TICKS_PER_SEC <= meta.timeLimitSec + 2;
}

export function validateV6PrayerBudget(summary: BattleSummary, meta: StageMeta): boolean {
  const clearSec = summary.endTick / TICKS_PER_SEC;
  const maxAvailable =
    meta.startingPrayerPower + Math.ceil(meta.focusBaseRegen * clearSec * meta.maxWeatherBonus) + meta.maxKillPrayer;
  return summary.totalPrayerSpent <= maxAvailable;
}

function summonInputs(inputs: BattleInput[]): Array<BattleInput & { type: 'SUMMON' }> {
  return inputs.filter((i): i is BattleInput & { type: 'SUMMON' } => i.type === 'SUMMON');
}

/** V7: 슬롯별 소환 간격 >= 그 슬롯 캐릭터의 resummonCooldown, 그리고 클라가
 * 주장한 totalSummons가 실제 로그의 SummonInput 개수와 같아야 한다. */
export function validateV7SummonCadence(
  inputs: BattleInput[],
  claimedTotalSummons: number,
  formation: FormationSnapshot,
  resummonCooldownSec: Record<string, number>,
): boolean {
  const summons = summonInputs(inputs);
  if (summons.length !== claimedTotalSummons) return false;

  const lastTickBySlot = new Map<number, number>();
  for (const s of summons) {
    const characterId = formation.slots[s.slotIndex]?.characterId;
    if (!characterId) return false; // V10과 겹치지만 쿨다운 조회 자체가 불가능하므로 여기서도 막는다
    const cooldownTicks = (resummonCooldownSec[characterId] ?? 0) * TICKS_PER_SEC;
    const last = lastTickBySlot.get(s.slotIndex);
    if (last !== undefined && s.tick - last < cooldownTicks) return false;
    lastTickBySlot.set(s.slotIndex, s.tick);
  }
  return true;
}

export function validateV8UltimateBudget(summary: BattleSummary): boolean {
  const clearSec = summary.endTick / TICKS_PER_SEC;
  const maxUltimates = Math.floor((clearSec - 30) / 60) + 1;
  return summary.ultimateUsed <= maxUltimates;
}

export function validateV9KillCount(summary: BattleSummary, meta: StageMeta): boolean {
  return summary.enemiesKilled <= meta.maxWaveEnemies;
}

/** V10: 편성에 실제로 채워진 슬롯만 소환 로그에 등장해야 한다. */
export function validateV10FormationOnlySummons(inputs: BattleInput[], formation: FormationSnapshot): boolean {
  return summonInputs(inputs).every((s) => {
    const slot = formation.slots[s.slotIndex];
    return slot != null && slot.characterId != null;
  });
}

/** V12: 완전 재실행 검증이 아니라 "변조 흔적 탐지" 수준 — inputLog·seed·
 * formationHash로부터 결정론적으로 나오는 sha256 값과 클라가 제출한
 * checksum이 같은지만 본다. */
export function validateV12Checksum(inputLogBase64: string, seed: number, formationHash: string, claimedChecksum: string): boolean {
  const expected = createHash('sha256').update(`${inputLogBase64}:${seed}:${formationHash}`).digest('hex');
  return expected === claimedChecksum;
}

export function computeV12Checksum(inputLogBase64: string, seed: number, formationHash: string): string {
  return createHash('sha256').update(`${inputLogBase64}:${seed}:${formationHash}`).digest('hex');
}

/** V13: 통과는 시키되(반려 아님) 상위 0.1% 급으로 튀는 값이면 사후 검토용
 * 플래그만 남긴다. "상위 0.1%" 실측 분포가 없어 최저 클리어 시간/최대
 * 처치수 근접 여부로 근사한다 — 실제 운영 데이터가 쌓이면 교체한다. */
export function isOutlierResult(summary: BattleSummary, meta: StageMeta): boolean {
  const clearSec = summary.endTick / TICKS_PER_SEC;
  const nearMinClear = clearSec <= meta.minClearSec * 1.05;
  const nearMaxKills = summary.enemiesKilled >= meta.maxWaveEnemies * 0.95;
  return nearMinClear || nearMaxKills;
}
