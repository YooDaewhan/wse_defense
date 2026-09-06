import '../local/pending_submits_repository.dart';

typedef SubmitBattlePayload = Map<String, dynamic>;
typedef SubmitBattleFn = Future<void> Function(SubmitBattlePayload payload);

/// 06_BACKEND.md §6.2: 전투 결과 제출은 네트워크 실패에 관용적이어야 한다.
/// `submit`이 실패하면(네트워크 끊김 등) 예외를 다시 던지지 않고
/// [PendingSubmitsStore]에 넣어 두고, 앱이 복귀했을 때 [retryPending]으로
/// 순서 상관없이 밀어넣는다 — 각 payload가 자기 `idempotencyKey`를 그대로
/// 들고 있어 서버(`withIdempotency`)가 중복 적용을 막아준다.
class BattleSubmitQueue {
  BattleSubmitQueue({required this.store, required this.submit});

  final PendingSubmitsStore store;
  final SubmitBattleFn submit;

  Future<void> submitOrQueue(SubmitBattlePayload payload) async {
    try {
      await submit(payload);
    } catch (_) {
      store.enqueue(payload);
    }
  }

  /// 큐에 남은 항목을 전부 재시도한다. 성공한 것만 큐에서 지운다.
  Future<void> retryPending() async {
    for (final payload in List<SubmitBattlePayload>.of(store.pending)) {
      try {
        await submit(payload);
        store.remove(payload['idempotencyKey'] as String);
      } catch (_) {
        // 아직도 실패 -> 큐에 남겨둔다.
      }
    }
  }
}
