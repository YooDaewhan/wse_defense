import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/rng/deterministic_rng.dart';

void main() {
  test('same seed produces identical 10,000-draw sequence', () {
    final a = DeterministicRng(42);
    final b = DeterministicRng(42);
    final seqA = List.generate(10000, (_) => a.nextInt(1000000));
    final seqB = List.generate(10000, (_) => b.nextInt(1000000));
    expect(seqA, equals(seqB));
  });

  test('streams are isolated from each other', () {
    final untouched = DeterministicRng(7).stream(RngStream.skillProc);
    final baselineSkillProc = List.generate(500, (_) => untouched.nextInt(1000));

    final rng = DeterministicRng(7);
    final skillProc = rng.stream(RngStream.skillProc);
    final critical = rng.stream(RngStream.critical);

    final interleavedSkillProc = <int>[];
    for (var i = 0; i < 500; i++) {
      interleavedSkillProc.add(skillProc.nextInt(1000));
      critical.nextInt(1000); // draws from a different stream in between
    }

    expect(interleavedSkillProc, equals(baselineSkillProc));
  });

  test('roll(50000) lands within 49.5%~50.5% over 1,000,000 trials', () {
    final rng = DeterministicRng(1234);
    var hits = 0;
    for (var i = 0; i < 1000000; i++) {
      if (rng.roll(50000)) hits++;
    }
    expect(hits, greaterThanOrEqualTo(495000));
    expect(hits, lessThanOrEqualTo(505000));
  });
}
