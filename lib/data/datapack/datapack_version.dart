/// 현재 `assets/data/v1/`에 번들된 데이터의 버전. 04_DATA_SCHEMA.md/
/// 06_BACKEND.md §5 파이프라인이 실제로 데이터를 바꿀 때마다 사람이 올린다
/// (자동 계산할 근거 필드가 아직 데이터 파일 안에 없음 — T-40 배포
/// 파이프라인이 CI에서 만드는 `manifest.json`이 그 근거가 될 것).
const bundledDatapackDataVersion = '1.0.0';
