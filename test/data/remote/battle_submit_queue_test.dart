import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/data/remote/battle_submit_queue.dart';

import 'support/in_memory_pending_submits_store.dart';

/// 09_MILESTONES.md T-38 완료조건: "네트워크 실패 시 pendingSubmits 재시도
/// 큐 동작".
void main() {
  test('a submit that fails is queued instead of throwing', () async {
    final store = InMemoryPendingSubmitsStore();
    final queue = BattleSubmitQueue(
      store: store,
      submit: (_) async => throw Exception('network down'),
    );

    await queue.submitOrQueue({'idempotencyKey': 'k1', 'battleId': 'b1'});

    expect(store.pending, [
      {'idempotencyKey': 'k1', 'battleId': 'b1'},
    ]);
  });

  test('a submit that succeeds is not queued', () async {
    final store = InMemoryPendingSubmitsStore();
    final queue = BattleSubmitQueue(store: store, submit: (_) async {});

    await queue.submitOrQueue({'idempotencyKey': 'k1', 'battleId': 'b1'});

    expect(store.pending, isEmpty);
  });

  test('retryPending re-sends every queued payload with its original idempotencyKey and removes it on success', () async {
    final store = InMemoryPendingSubmitsStore();
    final sentKeys = <String>[];
    final queue = BattleSubmitQueue(
      store: store,
      submit: (payload) async => sentKeys.add(payload['idempotencyKey'] as String),
    );
    store.enqueue({'idempotencyKey': 'k1', 'battleId': 'b1'});
    store.enqueue({'idempotencyKey': 'k2', 'battleId': 'b2'});

    await queue.retryPending();

    expect(sentKeys, ['k1', 'k2']);
    expect(store.pending, isEmpty);
  });

  test('retryPending leaves an item still failing in the queue but clears the ones that succeeded', () async {
    final store = InMemoryPendingSubmitsStore();
    final queue = BattleSubmitQueue(
      store: store,
      submit: (payload) async {
        if (payload['idempotencyKey'] == 'still-broken') throw Exception('network down');
      },
    );
    store.enqueue({'idempotencyKey': 'ok', 'battleId': 'b1'});
    store.enqueue({'idempotencyKey': 'still-broken', 'battleId': 'b2'});

    await queue.retryPending();

    expect(store.pending, [
      {'idempotencyKey': 'still-broken', 'battleId': 'b2'},
    ]);
  });
}
