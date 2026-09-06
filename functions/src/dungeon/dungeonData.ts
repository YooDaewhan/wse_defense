/**
 * assets/data/v1/dungeons.json 서버 사본 — starterCharacters.ts/growthConfig.ts
 * 와 같은 이유로 만든 임시 상수(T-40류 동기화 파이프라인이 아직 이 데이터
 * 클래스까지는 안 감). 드랍표 등 게임플레이에 영향을 주는 숫자는 반드시
 * 여기(서버)에만 있어야 하고, 클라이언트 값을 신뢰해서는 안 된다.
 */
export interface DropEntry {
  item: string;
  min: number;
  max: number;
  chancePct: number; // 100000 = 100%
  bonusDayOnly: boolean;
}

export interface DungeonDifficultyMeta {
  level: number;
  stageId: string;
  drops: DropEntry[];
}

export interface DungeonMeta {
  id: string;
  bonusWeekdays: number[];
  difficulties: DungeonDifficultyMeta[];
}

export const DAILY_RUN_LIMIT = 6;

function drops(entries: Array<Partial<DropEntry> & Pick<DropEntry, 'item' | 'min' | 'max'>>): DropEntry[] {
  return entries.map((e) => ({ chancePct: 100000, bonusDayOnly: false, ...e }));
}

function shardDifficulties(family: string, stagePrefix: string): DungeonDifficultyMeta[] {
  const T1 = `ITM_SHARD_${family}_T1`;
  const T2 = `ITM_SHARD_${family}_T2`;
  const T3 = `ITM_SHARD_${family}_T3`;
  return [
    { level: 1, stageId: `${stagePrefix}_1`, drops: drops([{ item: 'ITM_GOLD', min: 800, max: 1200 }, { item: T1, min: 3, max: 4 }]) },
    { level: 2, stageId: `${stagePrefix}_2`, drops: drops([{ item: 'ITM_GOLD', min: 1400, max: 2000 }, { item: T1, min: 5, max: 6 }]) },
    {
      level: 3,
      stageId: `${stagePrefix}_3`,
      drops: drops([
        { item: 'ITM_GOLD', min: 2400, max: 3200 },
        { item: T1, min: 6, max: 8 },
        { item: T2, min: 1, max: 2 },
      ]),
    },
    {
      level: 4,
      stageId: `${stagePrefix}_4`,
      drops: drops([
        { item: 'ITM_GOLD', min: 3600, max: 4800 },
        { item: T1, min: 4, max: 6 },
        { item: T2, min: 3, max: 4 },
      ]),
    },
    {
      level: 5,
      stageId: `${stagePrefix}_5`,
      drops: drops([
        { item: 'ITM_GOLD', min: 5000, max: 7000 },
        { item: T2, min: 4, max: 6 },
        { item: T3, min: 1, max: 1 },
        { item: T3, min: 1, max: 1, bonusDayOnly: true },
      ]),
    },
  ];
}

export const DUNGEONS: DungeonMeta[] = [
  { id: 'DGN_SUN', bonusWeekdays: [1, 4], difficulties: shardDifficulties('SUN', 'STG_DGN_SUN') },
  { id: 'DGN_MOON', bonusWeekdays: [2, 5], difficulties: shardDifficulties('MOON', 'STG_DGN_MOON') },
  { id: 'DGN_FIELD', bonusWeekdays: [3, 6], difficulties: shardDifficulties('FIELD', 'STG_DGN_FIELD') },
];

export const DUNGEONS_BY_ID: Record<string, DungeonMeta> = Object.fromEntries(DUNGEONS.map((d) => [d.id, d]));

export interface StageDungeonRef {
  dungeonId: string;
  level: number;
}

/** submitBattle이 stageId만 보고 "이건 어느 던전 몇 난이도인가"를 알아야
 * dailyCounters 차감/클리어 기록/드랍표 선택을 할 수 있다. */
export const STAGE_ID_TO_DUNGEON: Record<string, StageDungeonRef> = Object.fromEntries(
  DUNGEONS.flatMap((d) => d.difficulties.map((diff) => [diff.stageId, { dungeonId: d.id, level: diff.level }])),
);
