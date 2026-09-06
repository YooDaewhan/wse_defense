import { Delta } from '../common/types';

/**
 * 스토어 상품 콘솔(Google Play Console / App Store Connect)의 서버 사본.
 * 스토어 SKU는 게임 밸런스 데이터가 아니라 순수 서버 설정이라 다른
 * *Data.ts(T-40 방식)와 달리 클라 데이터팩(assets/data/v1)에는 없다.
 */
export interface ProductDef {
  id: string; // 스토어 SKU와 동일
  grants: Delta[];
}

export const PRODUCTS: ProductDef[] = [
  { id: 'gem_pack_small', grants: [{ item: 'ITM_GOLD', amount: 1000 }] },
  {
    id: 'gem_pack_large',
    grants: [
      { item: 'ITM_GOLD', amount: 6000 },
      { item: 'ITM_RECRUIT_TICKET', amount: 10 },
    ],
  },
];

export const PRODUCTS_BY_ID: Record<string, ProductDef> = Object.fromEntries(PRODUCTS.map((p) => [p.id, p]));
