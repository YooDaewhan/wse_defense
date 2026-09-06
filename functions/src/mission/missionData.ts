import { Delta } from '../common/types';

/**
 * 07_DUNGEON_EXCHANGE.md §9 "일일 미션 3개, 접속·전투·성장 행동에 대체
 * 조건 제공. 구매를 완료 조건으로 요구하지 않음" 서버 사본. 각 미션의
 * `triggerKinds`가 그 "대체 조건"이다 -- 나열된 것 중 무엇이 발생하든
 * 같은 진행도를 올린다(특정 스테이지·특정 성장 항목 하나로 못박지
 * 않는다). 구매(purchase) 관련 트리거는 의도적으로 하나도 넣지 않는다.
 */
export interface MissionDef {
  id: string;
  triggerKinds: string[];
  requiredCount: number;
  rewards: Delta[];
}

export const MISSIONS: MissionDef[] = [
  { id: 'MSN_LOGIN', triggerKinds: ['LOGIN'], requiredCount: 1, rewards: [{ item: 'ITM_GOLD', amount: 200 }] },
  { id: 'MSN_BATTLE', triggerKinds: ['BATTLE_WIN'], requiredCount: 1, rewards: [{ item: 'ITM_GOLD', amount: 300 }] },
  {
    id: 'MSN_GROWTH',
    triggerKinds: ['LEVEL_UP', 'ENHANCE_EQUIPMENT'],
    requiredCount: 1,
    rewards: [{ item: 'ITM_GOLD', amount: 300 }],
  },
];

export const MISSIONS_BY_ID: Record<string, MissionDef> = Object.fromEntries(MISSIONS.map((m) => [m.id, m]));
