import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/game/vfx/object_pool.dart';

void main() {
  test('creates new items up to maxSize', () {
    var created = 0;
    final pool = ObjectPool<int>(maxSize: 20, create: () => created++, reset: (_) {});

    for (var i = 0; i < 20; i++) {
      pool.acquire();
    }
    expect(created, 20);
    expect(pool.size, 20);
  });

  test('the 21st acquire reuses the oldest slot instead of creating a new one', () {
    var created = 0;
    final resetCalls = <int>[];
    final pool = ObjectPool<int>(
      maxSize: 20,
      create: () => created++,
      reset: (item) => resetCalls.add(item),
    );

    final first = <int>[];
    for (var i = 0; i < 20; i++) {
      first.add(pool.acquire());
    }
    final reused = pool.acquire();

    expect(created, 20); // 새로 만들지 않았다
    expect(pool.size, 20);
    expect(reused, first[0]); // 가장 먼저 내준(가장 오래된) 자리를 돌려썼다
    expect(resetCalls, [first[0]]);
  });

  test('reuse cycles through every slot in order', () {
    var created = 0;
    final pool = ObjectPool<int>(maxSize: 3, create: () => created++, reset: (_) {});
    final acquired = [for (var i = 0; i < 3; i++) pool.acquire()]; // [0, 1, 2]

    expect(pool.acquire(), acquired[0]);
    expect(pool.acquire(), acquired[1]);
    expect(pool.acquire(), acquired[2]);
    expect(pool.acquire(), acquired[0]); // 한 바퀴 돌아 다시 처음부터
  });
}
