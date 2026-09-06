import { BannerMeta } from './bannerData';

/**
 * 06_BACKEND.md §4.3 TRIAL 입장 자격 "픽업 기간 확인" -- characterId가
 * 지금 이 순간 어떤 배너에서든 pickup:true 구간에 있는지 본다(배너 시작·
 * 종료 시각은 서버 시각 기준).
 */
export function isActivePickupCharacter(characterId: string, nowMs: number, banners: BannerMeta[]): boolean {
  return banners.some((banner) => {
    if (banner.startAtUtc && nowMs < Date.parse(banner.startAtUtc)) return false;
    if (banner.endAtUtc && nowMs > Date.parse(banner.endAtUtc)) return false;
    return banner.rates.some((rate) => rate.pickup && rate.pool.includes(characterId));
  });
}
