import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';

const _animal = 1;
const _fire = 2;
const _wind = 3;
const _old = 4;

class _FakeEntity implements TagQueryTarget {
  _FakeEntity({
    required this.entityId,
    this.side = Side.ally,
    this.posX = 0,
    this.hp = 100,
    this.isAlive = true,
    this.isKnockback = false,
    this.role,
    this.tags = const {},
  });

  @override
  final int entityId;
  @override
  final Side side;
  @override
  final int posX;
  @override
  final int hp;
  @override
  final bool isAlive;
  @override
  final bool isKnockback;
  @override
  final String? role;
  final Map<int, int> tags;

  @override
  int tagLevel(int tagIndex) => tags[tagIndex] ?? 0;
}

void main() {
  final owner = _FakeEntity(entityId: 0);

  test('hasTags(AND)/anyTags(OR)/notTags/minTagLevel combine correctly', () {
    final matching = _FakeEntity(
      entityId: 1,
      tags: {_animal: 2, _fire: 1},
    );
    final tooLowMinLevel = _FakeEntity(
      entityId: 2,
      tags: {_animal: 1, _fire: 1},
    );
    final hasNotTag = _FakeEntity(
      entityId: 3,
      tags: {_animal: 2, _fire: 1, _old: 1},
    );
    final missingAnyTag = _FakeEntity(entityId: 4, tags: {_animal: 2});
    final missingHasTag = _FakeEntity(entityId: 5, tags: {_fire: 1});

    const query = TagQuery(
      hasTags: [_animal],
      anyTags: [_fire, _wind],
      notTags: [_old],
      minTagLevel: [(_animal, 2)],
    );

    final result = query.select(
      [matching, tooLowMinLevel, hasNotTag, missingAnyTag, missingHasTag],
      owner,
    );

    expect(result.map((e) => e.entityId), [1]);
  });

  test('limit + tie at same distance cuts by ascending entityId', () {
    final tiedFar = [
      _FakeEntity(entityId: 8, posX: 100),
      _FakeEntity(entityId: 5, posX: 100),
      _FakeEntity(entityId: 2, posX: 100),
      _FakeEntity(entityId: 1, posX: 100),
    ];
    final closest = _FakeEntity(entityId: 100, posX: 10);

    const query = TagQuery(sort: QuerySort.nearest, limit: 3);
    final result = query.select([...tiedFar, closest], owner);

    // closest(distance 10) first, then the distance-100 ties broken by
    // ascending entityId (1, 2 before 5, 8), limit cuts to 3.
    expect(result.map((e) => e.entityId), [100, 1, 2]);
  });

  test('excludeKnockback filters out units currently knocked back', () {
    final normal = _FakeEntity(entityId: 1);
    final knockedBack = _FakeEntity(entityId: 2, isKnockback: true);

    const query = TagQuery(excludeKnockback: true);
    final result = query.select([normal, knockedBack], owner);

    expect(result.map((e) => e.entityId), [1]);
  });

  test('side ENEMY only matches the opposing side', () {
    final ally = _FakeEntity(entityId: 1, side: Side.ally);
    final enemy = _FakeEntity(entityId: 2, side: Side.enemy);

    const query = TagQuery(side: QuerySide.enemy);
    expect(query.select([ally, enemy], owner).map((e) => e.entityId), [2]);
  });

  test('aliveOnly (default true) excludes dead units', () {
    final alive = _FakeEntity(entityId: 1);
    final dead = _FakeEntity(entityId: 2, isAlive: false);

    const query = TagQuery();
    expect(query.select([alive, dead], owner).map((e) => e.entityId), [1]);
  });

  test('roles filter matches only listed roles', () {
    final attacker = _FakeEntity(entityId: 1, role: 'ROLE_ATTACKER');
    final defender = _FakeEntity(entityId: 2, role: 'ROLE_DEFENDER');

    const query = TagQuery(roles: ['ROLE_ATTACKER']);
    final result = query.select([attacker, defender], owner);

    expect(result.map((e) => e.entityId), [1]);
  });

  test('LOWEST_HP sort orders ascending by hp', () {
    final high = _FakeEntity(entityId: 1, hp: 300);
    final low = _FakeEntity(entityId: 2, hp: 50);

    const query = TagQuery(sort: QuerySort.lowestHp);
    final result = query.select([high, low], owner);

    expect(result.map((e) => e.entityId), [2, 1]);
  });
}
