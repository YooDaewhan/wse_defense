import 'package:flutter/material.dart';

import '../../../../battle/defs/unit_def.dart';

/// 편성 슬롯 1칸. 아트가 없어(P0~P1 원칙) 이름 텍스트만 보여준다.
class FormationSlotTile extends StatelessWidget {
  const FormationSlotTile({super.key, required this.characterId, required this.def, required this.onTap});

  final String? characterId;
  final UnitDef? def;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        color: characterId == null ? Colors.black12 : Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          def == null ? '빈 슬롯' : (def!.nameKey.isEmpty ? def!.id : def!.nameKey),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11),
        ),
      ),
    );
  }
}
