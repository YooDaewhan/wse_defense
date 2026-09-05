import 'package:wse_defense/data/local/formation_repository.dart';

/// 위젯 테스트 전용 [FormationStore] 가짜 구현. 실제 디스크 영속성은
/// test/data/local/hive_persistence_test.dart가 진짜 Hive로 이미 검증한다
/// — 여기서는 화면의 상호작용 로직만 확인하면 되므로 순수 인메모리로 충분.
class InMemoryFormationStore implements FormationStore {
  final Map<String, List<String?>> _values = {};

  @override
  List<String?> get current => _read('current');
  @override
  set current(List<String?> ids) => _write('current', ids);

  @override
  List<String?> preset(int index) => _read('preset$index');
  @override
  void savePreset(int index, List<String?> ids) => _write('preset$index', ids);

  List<String?> _read(String key) =>
      _values[key] ?? List<String?>.filled(FormationStore.slotCount, null);

  void _write(String key, List<String?> ids) {
    _values[key] = List<String?>.generate(
      FormationStore.slotCount,
      (i) => i < ids.length ? ids[i] : null,
    );
  }
}
