/// 05_FRONTEND.md §11 성능 체크리스트: "데미지 텍스트는 최대 20개 풀,
/// 초과 시 오래된 것 재사용". Flame 의존이 없는 일반 오브젝트 풀이라
/// 순수 로직으로 테스트할 수 있다.
///
/// 링 버퍼로 "가장 오래전에 내준 자리"를 순서대로 돌려쓴다 — 데미지
/// 텍스트처럼 표시 시간이 서로 비슷한 항목에는 "가장 오래된 것"의 좋은
/// 근사다. ponytail: 항목별 실제 남은 표시 시간을 추적해 진짜 최장수
/// 항목을 고르는 정교한 버전은, 필요해지면(표시 시간이 들쭉날쭉해지면) 추가.
class ObjectPool<T> {
  ObjectPool({required this.maxSize, required this.create, required this.reset});

  final int maxSize;
  final T Function() create;
  final void Function(T item) reset;

  final List<T> _items = [];
  int _nextIndex = 0;

  int get size => _items.length;

  /// [maxSize] 미만이면 새로 만들고, 다 찼으면 가장 오래전에 내준 자리를
  /// [reset]해서 재사용한다.
  T acquire() {
    if (_items.length < maxSize) {
      final item = create();
      _items.add(item);
      _nextIndex = _items.length % maxSize;
      return item;
    }
    final item = _items[_nextIndex];
    reset(item);
    _nextIndex = (_nextIndex + 1) % maxSize;
    return item;
  }
}
