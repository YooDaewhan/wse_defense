import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/stat/modifier.dart';
import 'package:wse_defense/battle/stat/modifier_source.dart';
import 'package:wse_defense/battle/stat/stat_key.dart';
import 'package:wse_defense/battle/stat/stat_sheet.dart';

const _src = ModifierSource(ModifierKind.skill, 'SKL_TEST');

void main() {
  test('FLAT_ADD -> PCT_ADD -> MULT -> clamp order', () {
    final sheet = StatSheet({StatKey.atk: 100});
    sheet.addModifier(
      const StatModifier(stat: StatKey.atk, op: ModOp.flatAdd, value: 50, source: _src),
    );
    sheet.addModifier(
      const StatModifier(stat: StatKey.atk, op: ModOp.pctAdd, value: 20000, source: _src),
    );
    sheet.addModifier(
      const StatModifier(stat: StatKey.atk, op: ModOp.mult, value: 200000, source: _src),
    );
    sheet.addModifier(
      const StatModifier(stat: StatKey.atk, op: ModOp.setMax, value: 300, source: _src),
    );

    // (100 + 50) * 1.2 * 2 = 360, clamped to 300.
    expect(sheet.get(StatKey.atk), 300);
  });

  test('removeBySource removes every modifier from that source and restores base', () {
    final sheet = StatSheet({StatKey.atk: 100});
    const source = ModifierSource(ModifierKind.tagUnit, 'TEF_CHUBBY');
    sheet.addModifier(
      const StatModifier(stat: StatKey.atk, op: ModOp.flatAdd, value: 30, source: source),
    );
    sheet.addModifier(
      const StatModifier(stat: StatKey.atk, op: ModOp.pctAdd, value: 50000, source: source),
    );
    expect(sheet.get(StatKey.atk), 195); // (100+30)*1.5

    sheet.removeBySource(ModifierKind.tagUnit, 'TEF_CHUBBY');
    expect(sheet.get(StatKey.atk), 100);
  });

  test('exclusiveGroup keeps only the modifier with the largest absolute value', () {
    final sheet = StatSheet({StatKey.atk: 100});
    sheet.addModifier(
      const StatModifier(
        stat: StatKey.atk,
        op: ModOp.pctAdd,
        value: -10000,
        source: _src,
        exclusiveGroup: 'ATK_DOWN',
      ),
    );
    sheet.addModifier(
      const StatModifier(
        stat: StatKey.atk,
        op: ModOp.pctAdd,
        value: -25000,
        source: _src,
        exclusiveGroup: 'ATK_DOWN',
      ),
    );
    sheet.addModifier(
      const StatModifier(
        stat: StatKey.atk,
        op: ModOp.pctAdd,
        value: -5000,
        source: _src,
        exclusiveGroup: 'ATK_DOWN',
      ),
    );

    // only -25000 (largest |value|) applies: 100 * 0.75 = 75.
    expect(sheet.get(StatKey.atk), 75);
  });

  test('1,000,000 add/remove cycles restore base with zero error', () {
    final sheet = StatSheet({StatKey.atk: 100});
    for (var i = 0; i < 1000000; i++) {
      sheet.addModifier(
        StatModifier(
          stat: StatKey.atk,
          op: ModOp.flatAdd,
          value: 30,
          source: ModifierSource(ModifierKind.skill, 'SKL_BUFF', instanceId: i),
        ),
      );
      sheet.addModifier(
        StatModifier(
          stat: StatKey.atk,
          op: ModOp.pctAdd,
          value: 15000,
          source: ModifierSource(ModifierKind.skill, 'SKL_BUFF', instanceId: i),
        ),
      );
      sheet.removeByInstance(i);
    }
    expect(sheet.get(StatKey.atk), 100);
  });
}
