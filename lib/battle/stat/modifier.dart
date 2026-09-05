import 'modifier_source.dart';
import 'stat_key.dart';

/// 02_TAG_SYSTEM.md §3.6 StatModDef의 런타임 형태.
enum ModOp { flatAdd, pctAdd, mult, setMin, setMax }

class StatModifier {
  const StatModifier({
    required this.stat,
    required this.op,
    required this.value,
    required this.source,
    this.exclusiveGroup,
  });

  final StatKey stat;
  final ModOp op;

  /// FLAT_ADD/SET_MIN/SET_MAX는 원시값, PCT_ADD/MULT는 pctScale 기준
  /// 밀리퍼센트(예: MULT 125000 == ×1.25).
  final int value;
  final ModifierSource source;

  /// 03_BATTLE_ENGINE.md §10.2: 같은 그룹이면 value 절대값이 가장 큰
  /// 모디파이어 1개만 유효 (예: 기죽이기 최강 효과만 적용).
  final String? exclusiveGroup;
}
