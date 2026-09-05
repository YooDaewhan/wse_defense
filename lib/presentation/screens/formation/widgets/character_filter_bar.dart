import 'package:flutter/material.dart';

import '../../../../domain/formation/character_filter.dart';

const _roles = ['ROLE_DEFENDER', 'ROLE_ATTACKER', 'ROLE_SUPPORT', 'ROLE_DISRUPTOR'];
const _damageTypes = ['PHYSICAL', 'MAGICAL'];
const _attackReaches = ['MELEE', 'RANGED'];
const _tempers = ['TAG_TEMPER_SUN', 'TAG_TEMPER_MOON', 'TAG_TEMPER_FIELD'];

/// 05_FRONTEND.md §3.1: "역할/물리·마법/근·원거리/기질/특징 필터가 각각
/// 독립 동작". 카테고리별로 별도 [Wrap]을 둬 시각적으로도 분리한다.
/// `traits`는 태그 데이터(tags.json)에서 종류가 많고 계속 늘어날 수 있어
/// 고정 목록 대신 호출부가 [traitOptions]로 넘긴다.
class CharacterFilterBar extends StatelessWidget {
  const CharacterFilterBar({super.key, required this.filter, required this.onChanged, this.traitOptions = const []});

  final CharacterFilter filter;
  final ValueChanged<CharacterFilter> onChanged;
  final List<String> traitOptions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row('역할', _roles, filter.roles, (v) => onChanged(filter.copyWith(roles: v))),
        _row('물리·마법', _damageTypes, filter.damageTypes, (v) => onChanged(filter.copyWith(damageTypes: v))),
        _row('근·원거리', _attackReaches, filter.attackReaches, (v) => onChanged(filter.copyWith(attackReaches: v))),
        _row('기질', _tempers, filter.tempers, (v) => onChanged(filter.copyWith(tempers: v))),
        if (traitOptions.isNotEmpty)
          _row('특징', traitOptions, filter.traits, (v) => onChanged(filter.copyWith(traits: v))),
      ],
    );
  }

  Widget _row(String label, List<String> options, Set<String> selected, ValueChanged<Set<String>> onSet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: [
          SizedBox(width: 64, child: Text(label, style: const TextStyle(fontSize: 12))),
          for (final o in options)
            FilterChip(
              key: ValueKey('filter_${label}_$o'),
              label: Text(o, style: const TextStyle(fontSize: 11)),
              selected: selected.contains(o),
              onSelected: (isSelected) {
                final next = Set<String>.of(selected);
                if (isSelected) {
                  next.add(o);
                } else {
                  next.remove(o);
                }
                onSet(next);
              },
            ),
        ],
      ),
    );
  }
}
