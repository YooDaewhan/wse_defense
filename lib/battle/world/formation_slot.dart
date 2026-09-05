import '../defs/unit_def.dart';

/// 편성 한 칸의 전투 중 런타임 상태. `def`는 정적, `cooldownLeft`만 변한다.
class FormationSlot {
  FormationSlot(this.def);

  final UnitDef def;
  int cooldownLeft = 0;
}
