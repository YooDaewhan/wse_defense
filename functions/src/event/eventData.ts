/**
 * game_design_final.md "event | 기간, 스테이지·미션·교환소, 종료 처리"
 * 서버 사본. 09_MILESTONES.md T-55 완료조건: "10스테이지 + 교환소 + 기간
 * 종료 처리를 데이터만으로 구성" -- 이 파일이 그 증거다. startBattle의
 * EVENT 모드 진입 자격 확인과 exchangeItems의 상점 기간 확인은 둘 다
 * 이미 있는 일반 로직(기간 창 검사, resetPeriod)을 그대로 쓰고, 이벤트별
 * 코드는 하나도 새로 필요 없다 -- 여기 있는 EventDef 값만 바꾸면 새
 * 이벤트가 된다.
 */
export interface EventDef {
  id: string;
  startAtUtc: string | null;
  endAtUtc: string | null;
  /** §12 "10스테이지 템플릿". */
  stageIds: string[];
  /** exchangeData.ts의 Shop.id -- 이 이벤트 전용 교환소. */
  shopId: string;
}

export const EVENTS: EventDef[] = [
  {
    id: 'EVT_DEMO',
    startAtUtc: null,
    endAtUtc: null,
    stageIds: Array.from({ length: 10 }, (_, i) => `STG_EVENT_DEMO_${i + 1}`),
    shopId: 'SHOP_EVENT_DEMO',
  },
];

export const EVENTS_BY_STAGE_ID: Record<string, EventDef> = Object.fromEntries(
  EVENTS.flatMap((e) => e.stageIds.map((stageId) => [stageId, e])),
);

export const EVENTS_BY_SHOP_ID: Record<string, EventDef> = Object.fromEntries(EVENTS.map((e) => [e.shopId, e]));

/** 기간 종료 처리의 핵심: null이면 무제한, 아니면 지금이 그 구간 안인지만 본다. */
export function isEventOpen(event: EventDef, nowMs: number): boolean {
  if (event.startAtUtc && nowMs < Date.parse(event.startAtUtc)) return false;
  if (event.endAtUtc && nowMs > Date.parse(event.endAtUtc)) return false;
  return true;
}
