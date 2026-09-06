import { Delta } from '../common/types';

/**
 * 07_DUNGEON_EXCHANGE.md §8 "깊은 숲(deepForest)" 서버 사본 -- dungeonData.ts
 * 와 같은 이유의 임시 상수. 아직 별도 deepforest.json 데이터팩은 없다(층
 * 편성 제한·보상은 이 게이트 하나를 위해 클라 데이터팩까지 만들 필요는
 * 없는 서버 전용 값).
 */
export interface DeepForestFloorMeta {
  floor: number;
  stageId: string;
  /** tagId -> 편성 전체 intrinsicTags 합의 최소치. 빈 객체면 제한 없음. */
  requiredTags: Record<string, number>;
  rewards: Delta[];
}

export const DEEP_FOREST_FLOORS: DeepForestFloorMeta[] = [
  {
    floor: 1,
    stageId: 'STG_DEEPFOREST_1',
    requiredTags: {},
    rewards: [{ item: 'ITM_SHARD_SUN_T2', amount: 5 }],
  },
  {
    floor: 2,
    stageId: 'STG_DEEPFOREST_2',
    requiredTags: {},
    rewards: [{ item: 'ITM_SHARD_MOON_T2', amount: 5 }],
  },
  {
    // §8 예시("12층 = 동물 태그 3 이상 필수")를 이 저장소의 축소된 캐릭터
    // 5종(동물 태그 보유는 CHR_BIRD/CHR_BEAR 둘뿐)에 맞춰 재현했다.
    floor: 3,
    stageId: 'STG_DEEPFOREST_3',
    requiredTags: { TAG_RACE_ANIMAL: 2 },
    rewards: [{ item: 'ITM_SHARD_FIELD_T3', amount: 3 }],
  },
];

export const DEEP_FOREST_FLOORS_BY_STAGE: Record<string, DeepForestFloorMeta> = Object.fromEntries(
  DEEP_FOREST_FLOORS.map((f) => [f.stageId, f]),
);

export const DEEP_FOREST_FLOORS_BY_NUMBER: Record<number, DeepForestFloorMeta> = Object.fromEntries(
  DEEP_FOREST_FLOORS.map((f) => [f.floor, f]),
);
