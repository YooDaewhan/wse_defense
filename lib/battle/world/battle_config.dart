import '../defs/stage_def.dart';

/// `BattleWorld`를 세우는 데 필요한 최소 구성. 편성/시작 기도력 등은
/// 아직 소비하는 시스템이 없어 필요해질 때(T-12 등) 추가한다.
///
/// `allyBaseHp`(모닥불 체력)는 stage가 아니라 계정의 캠프 성장치에서
/// 오므로(growth.json, T-30) `StageDef`에 넣지 않고 여기서 따로 받는다.
class BattleConfig {
  const BattleConfig({required this.stage, required this.allyBaseHp});

  final StageDef stage;
  final int allyBaseHp;
}
