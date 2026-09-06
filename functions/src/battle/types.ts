import { AccountPatch, BaseRequest } from '../common/types';

export type BattleMode = 'STORY' | 'DUNGEON' | 'DEEP_FOREST' | 'PUZZLE' | 'TRIAL' | 'EVENT';
export type BattleOutcome = 'ALLY_WIN' | 'ENEMY_WIN' | 'DRAW' | 'TIMEOUT';

export const BATTLE_OUTCOMES: readonly BattleOutcome[] = ['ALLY_WIN', 'ENEMY_WIN', 'DRAW', 'TIMEOUT'];

export interface StartBattleReq extends BaseRequest {
  mode: BattleMode;
  stageId: string;
  presetIndex: number;
  difficulty?: number;
}

export interface FormationSlotSnapshot {
  characterId: string | null;
  equipmentInstanceId: string | null;
}

export interface FormationSnapshot {
  presetIndex: number;
  slots: FormationSlotSnapshot[];
  formationHash: string;
}

export interface StartBattleRes {
  battleId: string;
  seed: number;
  dataVersion: string;
  serverTimeMs: number;
  expireAtMs: number;
  formationSnapshot: FormationSnapshot;
}

export interface BattleSummary {
  endTick: number;
  totalSummons: number;
  totalPrayerSpent: number;
  ultimateUsed: number;
  focusBoostStage: number;
  enemiesKilled: number;
  enemyBaseHpLeft: number;
  allyBaseHpLeft: number;
  maxFrontlineX: number;
  checksum: string;
}

export interface SubmitBattleReq extends BaseRequest {
  battleId: string;
  outcome: BattleOutcome;
  summary: BattleSummary;
  inputLog: string; // base64(varint delta encoded), input_log.ts 포맷
  formationHash: string;
}

export interface SubmitBattleRes {
  accepted: boolean;
  rewards: Array<{ item: string; amount: number }>;
  firstClear: boolean;
  patch: AccountPatch;
}

/** 06_BACKEND.md §2 stagesMeta — 서버 검증용 최소 필드 + V6 예산 계산에
 * 필요한 필드(startingPrayerPower/focusBaseRegen/maxWeatherBonus)를 더했다. */
export interface StageMeta {
  timeLimitSec: number;
  minClearSec: number;
  maxWaveEnemies: number;
  maxKillPrayer: number;
  enemyBaseHp: number;
  startingPrayerPower: number;
  focusBaseRegen: number;
  maxWeatherBonus: number;
  firstRewards: Array<{ item: string; amount: number }>;
  repeatRewards: Array<{ item: string; amount: number }>;
}

export interface BattleDoc {
  stageId: string;
  mode: BattleMode;
  seed: number;
  dataVersion: string;
  formationHash: string;
  formationSnapshot: FormationSnapshot;
  issuedAt: number;
  expireAt: number;
  state: 'issued' | 'submitted' | 'abandoned' | 'expired';
  result: unknown | null;
}
