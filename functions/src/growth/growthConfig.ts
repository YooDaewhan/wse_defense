/**
 * assets/data/v1/growth.json 서버 사본(골드 비용 공식만). lib/domain/growth/
 * growth_config.dart의 `GoldCostFormula.costForLevelUp`과 같은 계산이다 —
 * T-40 데이터 배포 파이프라인이 실제로 서버에 동기화하기 전까지의 임시
 * 상수(starterCharacters.ts와 같은 이유).
 */
export interface GoldCostFormula {
  base: number;
  growth: number;
}

export function costForLevelUp(formula: GoldCostFormula, currentLevel: number): number {
  return Math.round(formula.base * Math.pow(formula.growth, currentLevel - 1));
}

export const FOCUS_GOLD_COST: GoldCostFormula = { base: 500, growth: 1.18 };
export const CAMP_GOLD_COST: GoldCostFormula = { base: 400, growth: 1.2 };
export const BOND_GOLD_COST: GoldCostFormula = { base: 200, growth: 1.12 };
export const BOND_MAX_LEVEL = 120;
