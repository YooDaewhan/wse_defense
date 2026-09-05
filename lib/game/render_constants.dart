/// 05_FRONTEND.md §4.4 논리 좌표 -> 픽셀 변환 상수.
library;

const double viewWidth = 1280; // CameraComponent.withFixedResolution 가로
const double viewHeight = 720;
const double visibleField = 1600; // 화면에 한 번에 보이는 전장 길이(논리 단위)
const double pixelsPerLogicalUnit = viewWidth / visibleField; // 0.8
