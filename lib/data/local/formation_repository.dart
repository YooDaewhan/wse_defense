import 'package:hive/hive.dart';

/// `FormationScreen`이 실제로 필요로 하는 읽기/쓰기 표면. Hive 구현
/// ([FormationRepository])과 테스트용 인메모리 구현이 이 인터페이스 하나를
/// 공유한다 — 위젯 테스트가 실제 Hive 박스 없이도 화면을 조립할 수 있다.
abstract class FormationStore {
  static const slotCount = 10;

  List<String?> get current;
  set current(List<String?> ids);
  List<String?> preset(int index);
  void savePreset(int index, List<String?> ids);
}

/// 05_FRONTEND.md §8 `formations` 박스: `preset0..2`, `current`. 각 값은
/// 10칸(5+5) 편성 슬롯의 캐릭터 id 목록 — 빈 슬롯은 null.
class FormationRepository implements FormationStore {
  FormationRepository(this._box);

  static const boxName = 'formations';
  static const slotCount = FormationStore.slotCount;
  final Box _box;

  @override
  List<String?> get current => _read('current');
  @override
  set current(List<String?> ids) => _write('current', ids);

  @override
  List<String?> preset(int index) => _read('preset$index');
  @override
  void savePreset(int index, List<String?> ids) => _write('preset$index', ids);

  List<String?> _read(String key) {
    final raw = _box.get(key) as List<Object?>?;
    if (raw == null) return List<String?>.filled(slotCount, null);
    return List<String?>.generate(slotCount, (i) => i < raw.length ? raw[i] as String? : null);
  }

  void _write(String key, List<String?> ids) {
    final padded = List<String?>.generate(slotCount, (i) => i < ids.length ? ids[i] : null);
    _box.put(key, padded);
  }
}
