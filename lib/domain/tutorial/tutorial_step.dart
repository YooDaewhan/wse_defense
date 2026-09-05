import 'tutorial_gate.dart';

/// 05_FRONTEND.md §9.2 튜토리얼 단계 데이터.
class TutorialStep {
  const TutorialStep({
    required this.id,
    required this.gate,
    required this.textKey,
    this.highlight,
    this.pauseSim = false,
  });

  final String id;
  final TutorialGate gate;
  final String textKey;

  /// 강조해서 보여줄 UI 요소 이름(예: "PRAYER_GAUGE", "SLOT_0"). 실제
  /// 스포트라이트 렌더링은 아직 없어(HUD 요소별 GlobalKey 배선이 필요,
  /// P0~P1 범위 밖) 이 이름을 그대로 라벨로 보여주는 것까지만 한다.
  final String? highlight;

  final bool pauseSim;
}

/// 05_FRONTEND.md §9.2 예시 7단계 — 수치(기도력 임계값 등)는 문서 예시를
/// 그대로 따르되, "STG_TUTORIAL"이 실제로 존재하지 않아 예시일 뿐이라
/// 이 프로젝트의 실제 튜토리얼 스테이지(아래 tutorial_stage.dart)에 맞춰
/// 값을 조정했다 — 완료조건(60~90초, 게이트 순서대로 진행)은
/// tutorial_flow_test.dart가 실제 시뮬레이션으로 확인한다.
const tutorialSteps = [
  TutorialStep(
    id: 'T1',
    textKey: 'tut.1',
    highlight: 'PRAYER_GAUGE',
    gate: PrayerAtLeastGate(75),
    pauseSim: true,
  ),
  TutorialStep(
    id: 'T2',
    textKey: 'tut.2',
    highlight: 'SLOT_0',
    gate: SummonedGate('CHR_ACORN'),
  ),
  TutorialStep(
    id: 'T3',
    textKey: 'tut.3',
    highlight: 'SLOT_1',
    gate: SummonedGate('CHR_DROPLET'),
  ),
  TutorialStep(
    id: 'T4',
    textKey: 'tut.4',
    highlight: 'SLOT_0',
    gate: FrontlineBelowGate(1800),
  ),
  TutorialStep(
    id: 'T5',
    textKey: 'tut.5',
    highlight: 'ULTIMATE',
    gate: UltimateUsedGate(),
    pauseSim: true,
  ),
  TutorialStep(
    id: 'T6',
    textKey: 'tut.6',
    highlight: 'NEST',
    gate: NestDestroyedGate(),
  ),
  TutorialStep(
    id: 'T7',
    textKey: 'tut.7',
    gate: RewardClaimedGate(),
  ),
];
