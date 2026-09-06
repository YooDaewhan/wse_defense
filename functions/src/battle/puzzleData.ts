import { Delta } from '../common/types';
import { FormationSlotSnapshot } from './types';

/**
 * game_design_final.md "반복 콘텐츠 -- 주간 퍼즐(지정 덱)" 서버 사본.
 * 이번 주 퍼즐은 하나뿐이라(스테이지별 목록이 아니라) dungeonData.ts처럼
 * 여러 항목을 목록화하지 않고 상수 하나로 둔다 -- 로테이션 콘텐츠가
 * 여러 개로 늘면 그때 목록화한다.
 */
export const PUZZLE_STAGE_ID = 'STG_PUZZLE_WEEKLY';

/** "지정 편성" -- 소유 여부와 무관하게 이 캐릭터들로 강제 편성한다
 * (TRIAL의 trialFormationSnapshot과 같은 이유). */
export const PUZZLE_FORMATION: FormationSlotSnapshot[] = [
  { characterId: 'CHR_ACORN', equipmentInstanceId: null },
  { characterId: 'CHR_DROPLET', equipmentInstanceId: null },
];

export const PUZZLE_REWARDS: Delta[] = [{ item: 'ITM_GOLD', amount: 500 }];
