import 'package:hive/hive.dart';

/// 05_FRONTEND.md §8 `formations` 박스: `preset0..2`, `current`. 각 값은
/// 10칸(5+5) 편성 슬롯의 캐릭터 id 목록 — 빈 슬롯은 null.
class FormationRepository {
  FormationRepository(this._box);

  static const boxName = 'formations';
  static const slotCount = 10;
  final Box _box;

  List<String?> get current => _read('current');
  set current(List<String?> ids) => _write('current', ids);

  List<String?> preset(int index) => _read('preset$index');
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
