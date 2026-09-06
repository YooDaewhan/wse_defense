import 'package:wse_defense/data/local/pending_submits_repository.dart';

class InMemoryPendingSubmitsStore implements PendingSubmitsStore {
  final Map<String, Map<String, dynamic>> _values = {};

  @override
  List<Map<String, dynamic>> get pending => _values.values.toList();

  @override
  void enqueue(Map<String, dynamic> payload) => _values[payload['idempotencyKey'] as String] = payload;

  @override
  void remove(String idempotencyKey) => _values.remove(idempotencyKey);
}
