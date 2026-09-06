/** items.json의 `type: CURRENCY` 항목 -> users/{uid}.currency 필드 매핑.
 * 06_BACKEND.md §2 스키마의 `currency { gold, recruitTicket, collectFragment,
 * exchangePoint }`는 평범한 필드명이지만, 보상/드랍표/교환은 전부 아이템
 * 카탈로그 ID(`ITM_GOLD` 등)로 표현되므로 여기서 한 번만 변환한다. */
export const CURRENCY_ITEM_FIELD: Record<string, string> = {
  ITM_GOLD: 'gold',
  ITM_RECRUIT_TICKET: 'recruitTicket',
  ITM_COLLECT_FRAGMENT: 'collectFragment',
  ITM_EXCHANGE_POINT: 'exchangePoint',
};
