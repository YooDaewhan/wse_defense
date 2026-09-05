// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unit_def.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UnitBaseStats {

 int get summonCost; int get maxHp; int get atk; int get attackPeriod; int get attackWindup; int get attackRecover; int get attackRange; int get moveSpeed; int get hpSegments; int get resummonCooldownSec; int get collisionRadius; int get knockbackDistance; int get knockbackResist; int get def; String get attackMode; int get aoeMaxTargets; String get damageType; String get attackReach;
/// Create a copy of UnitBaseStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnitBaseStatsCopyWith<UnitBaseStats> get copyWith => _$UnitBaseStatsCopyWithImpl<UnitBaseStats>(this as UnitBaseStats, _$identity);

  /// Serializes this UnitBaseStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UnitBaseStats;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnitBaseStats&&(identical(other.summonCost, _this.summonCost) || other.summonCost == _this.summonCost)&&(identical(other.maxHp, _this.maxHp) || other.maxHp == _this.maxHp)&&(identical(other.atk, _this.atk) || other.atk == _this.atk)&&(identical(other.attackPeriod, _this.attackPeriod) || other.attackPeriod == _this.attackPeriod)&&(identical(other.attackWindup, _this.attackWindup) || other.attackWindup == _this.attackWindup)&&(identical(other.attackRecover, _this.attackRecover) || other.attackRecover == _this.attackRecover)&&(identical(other.attackRange, _this.attackRange) || other.attackRange == _this.attackRange)&&(identical(other.moveSpeed, _this.moveSpeed) || other.moveSpeed == _this.moveSpeed)&&(identical(other.hpSegments, _this.hpSegments) || other.hpSegments == _this.hpSegments)&&(identical(other.resummonCooldownSec, _this.resummonCooldownSec) || other.resummonCooldownSec == _this.resummonCooldownSec)&&(identical(other.collisionRadius, _this.collisionRadius) || other.collisionRadius == _this.collisionRadius)&&(identical(other.knockbackDistance, _this.knockbackDistance) || other.knockbackDistance == _this.knockbackDistance)&&(identical(other.knockbackResist, _this.knockbackResist) || other.knockbackResist == _this.knockbackResist)&&(identical(other.def, _this.def) || other.def == _this.def)&&(identical(other.attackMode, _this.attackMode) || other.attackMode == _this.attackMode)&&(identical(other.aoeMaxTargets, _this.aoeMaxTargets) || other.aoeMaxTargets == _this.aoeMaxTargets)&&(identical(other.damageType, _this.damageType) || other.damageType == _this.damageType)&&(identical(other.attackReach, _this.attackReach) || other.attackReach == _this.attackReach));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UnitBaseStats;
  return Object.hash(runtimeType,_this.summonCost,_this.maxHp,_this.atk,_this.attackPeriod,_this.attackWindup,_this.attackRecover,_this.attackRange,_this.moveSpeed,_this.hpSegments,_this.resummonCooldownSec,_this.collisionRadius,_this.knockbackDistance,_this.knockbackResist,_this.def,_this.attackMode,_this.aoeMaxTargets,_this.damageType,_this.attackReach);
}

@override
String toString() {
  final _this = this as UnitBaseStats;
  return 'UnitBaseStats(summonCost: ${_this.summonCost}, maxHp: ${_this.maxHp}, atk: ${_this.atk}, attackPeriod: ${_this.attackPeriod}, attackWindup: ${_this.attackWindup}, attackRecover: ${_this.attackRecover}, attackRange: ${_this.attackRange}, moveSpeed: ${_this.moveSpeed}, hpSegments: ${_this.hpSegments}, resummonCooldownSec: ${_this.resummonCooldownSec}, collisionRadius: ${_this.collisionRadius}, knockbackDistance: ${_this.knockbackDistance}, knockbackResist: ${_this.knockbackResist}, def: ${_this.def}, attackMode: ${_this.attackMode}, aoeMaxTargets: ${_this.aoeMaxTargets}, damageType: ${_this.damageType}, attackReach: ${_this.attackReach})';
}


}

/// @nodoc
abstract mixin class $UnitBaseStatsCopyWith<$Res>  {
  factory $UnitBaseStatsCopyWith(UnitBaseStats value, $Res Function(UnitBaseStats) _then) = _$UnitBaseStatsCopyWithImpl;
@useResult
$Res call({
 int summonCost, int maxHp, int atk, int attackPeriod, int attackWindup, int attackRecover, int attackRange, int moveSpeed, int hpSegments, int resummonCooldownSec, int collisionRadius, int knockbackDistance, int knockbackResist, int def, String attackMode, int aoeMaxTargets, String damageType, String attackReach
});




}
/// @nodoc
class _$UnitBaseStatsCopyWithImpl<$Res>
    implements $UnitBaseStatsCopyWith<$Res> {
  _$UnitBaseStatsCopyWithImpl(this._self, this._then);

  final UnitBaseStats _self;
  final $Res Function(UnitBaseStats) _then;

/// Create a copy of UnitBaseStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? summonCost = null,Object? maxHp = null,Object? atk = null,Object? attackPeriod = null,Object? attackWindup = null,Object? attackRecover = null,Object? attackRange = null,Object? moveSpeed = null,Object? hpSegments = null,Object? resummonCooldownSec = null,Object? collisionRadius = null,Object? knockbackDistance = null,Object? knockbackResist = null,Object? def = null,Object? attackMode = null,Object? aoeMaxTargets = null,Object? damageType = null,Object? attackReach = null,}) {
  return _then(UnitBaseStats(
summonCost: null == summonCost ? _self.summonCost : summonCost // ignore: cast_nullable_to_non_nullable
as int,maxHp: null == maxHp ? _self.maxHp : maxHp // ignore: cast_nullable_to_non_nullable
as int,atk: null == atk ? _self.atk : atk // ignore: cast_nullable_to_non_nullable
as int,attackPeriod: null == attackPeriod ? _self.attackPeriod : attackPeriod // ignore: cast_nullable_to_non_nullable
as int,attackWindup: null == attackWindup ? _self.attackWindup : attackWindup // ignore: cast_nullable_to_non_nullable
as int,attackRecover: null == attackRecover ? _self.attackRecover : attackRecover // ignore: cast_nullable_to_non_nullable
as int,attackRange: null == attackRange ? _self.attackRange : attackRange // ignore: cast_nullable_to_non_nullable
as int,moveSpeed: null == moveSpeed ? _self.moveSpeed : moveSpeed // ignore: cast_nullable_to_non_nullable
as int,hpSegments: null == hpSegments ? _self.hpSegments : hpSegments // ignore: cast_nullable_to_non_nullable
as int,resummonCooldownSec: null == resummonCooldownSec ? _self.resummonCooldownSec : resummonCooldownSec // ignore: cast_nullable_to_non_nullable
as int,collisionRadius: null == collisionRadius ? _self.collisionRadius : collisionRadius // ignore: cast_nullable_to_non_nullable
as int,knockbackDistance: null == knockbackDistance ? _self.knockbackDistance : knockbackDistance // ignore: cast_nullable_to_non_nullable
as int,knockbackResist: null == knockbackResist ? _self.knockbackResist : knockbackResist // ignore: cast_nullable_to_non_nullable
as int,def: null == def ? _self.def : def // ignore: cast_nullable_to_non_nullable
as int,attackMode: null == attackMode ? _self.attackMode : attackMode // ignore: cast_nullable_to_non_nullable
as String,aoeMaxTargets: null == aoeMaxTargets ? _self.aoeMaxTargets : aoeMaxTargets // ignore: cast_nullable_to_non_nullable
as int,damageType: null == damageType ? _self.damageType : damageType // ignore: cast_nullable_to_non_nullable
as String,attackReach: null == attackReach ? _self.attackReach : attackReach // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UnitBaseStats].
extension UnitBaseStatsPatterns on UnitBaseStats {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnitBaseStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnitBaseStats() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnitBaseStats value)  $default,){
final _that = this;
switch (_that) {
case _UnitBaseStats():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnitBaseStats value)?  $default,){
final _that = this;
switch (_that) {
case _UnitBaseStats() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int summonCost,  int maxHp,  int atk,  int attackPeriod,  int attackWindup,  int attackRecover,  int attackRange,  int moveSpeed,  int hpSegments,  int resummonCooldownSec,  int collisionRadius,  int knockbackDistance,  int knockbackResist,  int def,  String attackMode,  int aoeMaxTargets,  String damageType,  String attackReach)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnitBaseStats() when $default != null:
return $default(_that.summonCost,_that.maxHp,_that.atk,_that.attackPeriod,_that.attackWindup,_that.attackRecover,_that.attackRange,_that.moveSpeed,_that.hpSegments,_that.resummonCooldownSec,_that.collisionRadius,_that.knockbackDistance,_that.knockbackResist,_that.def,_that.attackMode,_that.aoeMaxTargets,_that.damageType,_that.attackReach);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int summonCost,  int maxHp,  int atk,  int attackPeriod,  int attackWindup,  int attackRecover,  int attackRange,  int moveSpeed,  int hpSegments,  int resummonCooldownSec,  int collisionRadius,  int knockbackDistance,  int knockbackResist,  int def,  String attackMode,  int aoeMaxTargets,  String damageType,  String attackReach)  $default,) {final _that = this;
switch (_that) {
case _UnitBaseStats():
return $default(_that.summonCost,_that.maxHp,_that.atk,_that.attackPeriod,_that.attackWindup,_that.attackRecover,_that.attackRange,_that.moveSpeed,_that.hpSegments,_that.resummonCooldownSec,_that.collisionRadius,_that.knockbackDistance,_that.knockbackResist,_that.def,_that.attackMode,_that.aoeMaxTargets,_that.damageType,_that.attackReach);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int summonCost,  int maxHp,  int atk,  int attackPeriod,  int attackWindup,  int attackRecover,  int attackRange,  int moveSpeed,  int hpSegments,  int resummonCooldownSec,  int collisionRadius,  int knockbackDistance,  int knockbackResist,  int def,  String attackMode,  int aoeMaxTargets,  String damageType,  String attackReach)?  $default,) {final _that = this;
switch (_that) {
case _UnitBaseStats() when $default != null:
return $default(_that.summonCost,_that.maxHp,_that.atk,_that.attackPeriod,_that.attackWindup,_that.attackRecover,_that.attackRange,_that.moveSpeed,_that.hpSegments,_that.resummonCooldownSec,_that.collisionRadius,_that.knockbackDistance,_that.knockbackResist,_that.def,_that.attackMode,_that.aoeMaxTargets,_that.damageType,_that.attackReach);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UnitBaseStats implements UnitBaseStats {
  const _UnitBaseStats({this.summonCost = 0, required this.maxHp, required this.atk, required this.attackPeriod, required this.attackWindup, required this.attackRecover, required this.attackRange, required this.moveSpeed, this.hpSegments = 1, this.resummonCooldownSec = 0, this.collisionRadius = 24, this.knockbackDistance = 0, this.knockbackResist = 0, this.def = 0, this.attackMode = 'SINGLE', this.aoeMaxTargets = 1, this.damageType = 'PHYSICAL', this.attackReach = 'MELEE'});
  factory _UnitBaseStats.fromJson(Map<String, dynamic> json) => _$UnitBaseStatsFromJson(json);

@override@JsonKey() final  int summonCost;
@override final  int maxHp;
@override final  int atk;
@override final  int attackPeriod;
@override final  int attackWindup;
@override final  int attackRecover;
@override final  int attackRange;
@override final  int moveSpeed;
@override@JsonKey() final  int hpSegments;
@override@JsonKey() final  int resummonCooldownSec;
@override@JsonKey() final  int collisionRadius;
@override@JsonKey() final  int knockbackDistance;
@override@JsonKey() final  int knockbackResist;
@override@JsonKey() final  int def;
@override@JsonKey() final  String attackMode;
@override@JsonKey() final  int aoeMaxTargets;
@override@JsonKey() final  String damageType;
@override@JsonKey() final  String attackReach;

/// Create a copy of UnitBaseStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnitBaseStatsCopyWith<_UnitBaseStats> get copyWith => __$UnitBaseStatsCopyWithImpl<_UnitBaseStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnitBaseStatsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnitBaseStats&&(identical(other.summonCost, summonCost) || other.summonCost == summonCost)&&(identical(other.maxHp, maxHp) || other.maxHp == maxHp)&&(identical(other.atk, atk) || other.atk == atk)&&(identical(other.attackPeriod, attackPeriod) || other.attackPeriod == attackPeriod)&&(identical(other.attackWindup, attackWindup) || other.attackWindup == attackWindup)&&(identical(other.attackRecover, attackRecover) || other.attackRecover == attackRecover)&&(identical(other.attackRange, attackRange) || other.attackRange == attackRange)&&(identical(other.moveSpeed, moveSpeed) || other.moveSpeed == moveSpeed)&&(identical(other.hpSegments, hpSegments) || other.hpSegments == hpSegments)&&(identical(other.resummonCooldownSec, resummonCooldownSec) || other.resummonCooldownSec == resummonCooldownSec)&&(identical(other.collisionRadius, collisionRadius) || other.collisionRadius == collisionRadius)&&(identical(other.knockbackDistance, knockbackDistance) || other.knockbackDistance == knockbackDistance)&&(identical(other.knockbackResist, knockbackResist) || other.knockbackResist == knockbackResist)&&(identical(other.def, def) || other.def == def)&&(identical(other.attackMode, attackMode) || other.attackMode == attackMode)&&(identical(other.aoeMaxTargets, aoeMaxTargets) || other.aoeMaxTargets == aoeMaxTargets)&&(identical(other.damageType, damageType) || other.damageType == damageType)&&(identical(other.attackReach, attackReach) || other.attackReach == attackReach));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,summonCost,maxHp,atk,attackPeriod,attackWindup,attackRecover,attackRange,moveSpeed,hpSegments,resummonCooldownSec,collisionRadius,knockbackDistance,knockbackResist,def,attackMode,aoeMaxTargets,damageType,attackReach);
}

@override
String toString() {
    return 'UnitBaseStats(summonCost: $summonCost, maxHp: $maxHp, atk: $atk, attackPeriod: $attackPeriod, attackWindup: $attackWindup, attackRecover: $attackRecover, attackRange: $attackRange, moveSpeed: $moveSpeed, hpSegments: $hpSegments, resummonCooldownSec: $resummonCooldownSec, collisionRadius: $collisionRadius, knockbackDistance: $knockbackDistance, knockbackResist: $knockbackResist, def: $def, attackMode: $attackMode, aoeMaxTargets: $aoeMaxTargets, damageType: $damageType, attackReach: $attackReach)';
}


}

/// @nodoc
abstract mixin class _$UnitBaseStatsCopyWith<$Res> implements $UnitBaseStatsCopyWith<$Res> {
  factory _$UnitBaseStatsCopyWith(_UnitBaseStats value, $Res Function(_UnitBaseStats) _then) = __$UnitBaseStatsCopyWithImpl;
@override @useResult
$Res call({
 int summonCost, int maxHp, int atk, int attackPeriod, int attackWindup, int attackRecover, int attackRange, int moveSpeed, int hpSegments, int resummonCooldownSec, int collisionRadius, int knockbackDistance, int knockbackResist, int def, String attackMode, int aoeMaxTargets, String damageType, String attackReach
});




}
/// @nodoc
class __$UnitBaseStatsCopyWithImpl<$Res>
    implements _$UnitBaseStatsCopyWith<$Res> {
  __$UnitBaseStatsCopyWithImpl(this._self, this._then);

  final _UnitBaseStats _self;
  final $Res Function(_UnitBaseStats) _then;

/// Create a copy of UnitBaseStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? summonCost = null,Object? maxHp = null,Object? atk = null,Object? attackPeriod = null,Object? attackWindup = null,Object? attackRecover = null,Object? attackRange = null,Object? moveSpeed = null,Object? hpSegments = null,Object? resummonCooldownSec = null,Object? collisionRadius = null,Object? knockbackDistance = null,Object? knockbackResist = null,Object? def = null,Object? attackMode = null,Object? aoeMaxTargets = null,Object? damageType = null,Object? attackReach = null,}) {
  return _then(_UnitBaseStats(
summonCost: null == summonCost ? _self.summonCost : summonCost // ignore: cast_nullable_to_non_nullable
as int,maxHp: null == maxHp ? _self.maxHp : maxHp // ignore: cast_nullable_to_non_nullable
as int,atk: null == atk ? _self.atk : atk // ignore: cast_nullable_to_non_nullable
as int,attackPeriod: null == attackPeriod ? _self.attackPeriod : attackPeriod // ignore: cast_nullable_to_non_nullable
as int,attackWindup: null == attackWindup ? _self.attackWindup : attackWindup // ignore: cast_nullable_to_non_nullable
as int,attackRecover: null == attackRecover ? _self.attackRecover : attackRecover // ignore: cast_nullable_to_non_nullable
as int,attackRange: null == attackRange ? _self.attackRange : attackRange // ignore: cast_nullable_to_non_nullable
as int,moveSpeed: null == moveSpeed ? _self.moveSpeed : moveSpeed // ignore: cast_nullable_to_non_nullable
as int,hpSegments: null == hpSegments ? _self.hpSegments : hpSegments // ignore: cast_nullable_to_non_nullable
as int,resummonCooldownSec: null == resummonCooldownSec ? _self.resummonCooldownSec : resummonCooldownSec // ignore: cast_nullable_to_non_nullable
as int,collisionRadius: null == collisionRadius ? _self.collisionRadius : collisionRadius // ignore: cast_nullable_to_non_nullable
as int,knockbackDistance: null == knockbackDistance ? _self.knockbackDistance : knockbackDistance // ignore: cast_nullable_to_non_nullable
as int,knockbackResist: null == knockbackResist ? _self.knockbackResist : knockbackResist // ignore: cast_nullable_to_non_nullable
as int,def: null == def ? _self.def : def // ignore: cast_nullable_to_non_nullable
as int,attackMode: null == attackMode ? _self.attackMode : attackMode // ignore: cast_nullable_to_non_nullable
as String,aoeMaxTargets: null == aoeMaxTargets ? _self.aoeMaxTargets : aoeMaxTargets // ignore: cast_nullable_to_non_nullable
as int,damageType: null == damageType ? _self.damageType : damageType // ignore: cast_nullable_to_non_nullable
as String,attackReach: null == attackReach ? _self.attackReach : attackReach // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UnitDef {

 String get id; String get nameKey; Map<String, int> get intrinsicTags; UnitBaseStats get base; List<String> get skills; bool get isBoss; int get killPrayerReward; int? get damageCapPerHit;
/// Create a copy of UnitDef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnitDefCopyWith<UnitDef> get copyWith => _$UnitDefCopyWithImpl<UnitDef>(this as UnitDef, _$identity);

  /// Serializes this UnitDef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UnitDef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnitDef&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.nameKey, _this.nameKey) || other.nameKey == _this.nameKey)&&const DeepCollectionEquality().equals(other.intrinsicTags, _this.intrinsicTags)&&(identical(other.base, _this.base) || other.base == _this.base)&&const DeepCollectionEquality().equals(other.skills, _this.skills)&&(identical(other.isBoss, _this.isBoss) || other.isBoss == _this.isBoss)&&(identical(other.killPrayerReward, _this.killPrayerReward) || other.killPrayerReward == _this.killPrayerReward)&&(identical(other.damageCapPerHit, _this.damageCapPerHit) || other.damageCapPerHit == _this.damageCapPerHit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UnitDef;
  return Object.hash(runtimeType,_this.id,_this.nameKey,const DeepCollectionEquality().hash(_this.intrinsicTags),_this.base,const DeepCollectionEquality().hash(_this.skills),_this.isBoss,_this.killPrayerReward,_this.damageCapPerHit);
}

@override
String toString() {
  final _this = this as UnitDef;
  return 'UnitDef(id: ${_this.id}, nameKey: ${_this.nameKey}, intrinsicTags: ${_this.intrinsicTags}, base: ${_this.base}, skills: ${_this.skills}, isBoss: ${_this.isBoss}, killPrayerReward: ${_this.killPrayerReward}, damageCapPerHit: ${_this.damageCapPerHit})';
}


}

/// @nodoc
abstract mixin class $UnitDefCopyWith<$Res>  {
  factory $UnitDefCopyWith(UnitDef value, $Res Function(UnitDef) _then) = _$UnitDefCopyWithImpl;
@useResult
$Res call({
 String id, String nameKey, Map<String, int> intrinsicTags, UnitBaseStats base, List<String> skills, bool isBoss, int killPrayerReward, int? damageCapPerHit
});


$UnitBaseStatsCopyWith<$Res> get base;

}
/// @nodoc
class _$UnitDefCopyWithImpl<$Res>
    implements $UnitDefCopyWith<$Res> {
  _$UnitDefCopyWithImpl(this._self, this._then);

  final UnitDef _self;
  final $Res Function(UnitDef) _then;

/// Create a copy of UnitDef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nameKey = null,Object? intrinsicTags = null,Object? base = null,Object? skills = null,Object? isBoss = null,Object? killPrayerReward = null,Object? damageCapPerHit = freezed,}) {
  return _then(UnitDef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameKey: null == nameKey ? _self.nameKey : nameKey // ignore: cast_nullable_to_non_nullable
as String,intrinsicTags: null == intrinsicTags ? _self.intrinsicTags : intrinsicTags // ignore: cast_nullable_to_non_nullable
as Map<String, int>,base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as UnitBaseStats,skills: null == skills ? _self.skills : skills // ignore: cast_nullable_to_non_nullable
as List<String>,isBoss: null == isBoss ? _self.isBoss : isBoss // ignore: cast_nullable_to_non_nullable
as bool,killPrayerReward: null == killPrayerReward ? _self.killPrayerReward : killPrayerReward // ignore: cast_nullable_to_non_nullable
as int,damageCapPerHit: freezed == damageCapPerHit ? _self.damageCapPerHit : damageCapPerHit // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of UnitDef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UnitBaseStatsCopyWith<$Res> get base {
  
  return $UnitBaseStatsCopyWith<$Res>(_self.base, (value) {
    return _then(_self.copyWith(base: value));
  });
}
}


/// Adds pattern-matching-related methods to [UnitDef].
extension UnitDefPatterns on UnitDef {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnitDef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnitDef() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnitDef value)  $default,){
final _that = this;
switch (_that) {
case _UnitDef():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnitDef value)?  $default,){
final _that = this;
switch (_that) {
case _UnitDef() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nameKey,  Map<String, int> intrinsicTags,  UnitBaseStats base,  List<String> skills,  bool isBoss,  int killPrayerReward,  int? damageCapPerHit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnitDef() when $default != null:
return $default(_that.id,_that.nameKey,_that.intrinsicTags,_that.base,_that.skills,_that.isBoss,_that.killPrayerReward,_that.damageCapPerHit);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nameKey,  Map<String, int> intrinsicTags,  UnitBaseStats base,  List<String> skills,  bool isBoss,  int killPrayerReward,  int? damageCapPerHit)  $default,) {final _that = this;
switch (_that) {
case _UnitDef():
return $default(_that.id,_that.nameKey,_that.intrinsicTags,_that.base,_that.skills,_that.isBoss,_that.killPrayerReward,_that.damageCapPerHit);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nameKey,  Map<String, int> intrinsicTags,  UnitBaseStats base,  List<String> skills,  bool isBoss,  int killPrayerReward,  int? damageCapPerHit)?  $default,) {final _that = this;
switch (_that) {
case _UnitDef() when $default != null:
return $default(_that.id,_that.nameKey,_that.intrinsicTags,_that.base,_that.skills,_that.isBoss,_that.killPrayerReward,_that.damageCapPerHit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UnitDef implements UnitDef {
  const _UnitDef({required this.id, this.nameKey = '',  Map<String, int> intrinsicTags = const <String, int>{}, required this.base,  List<String> skills = const <String>[], this.isBoss = false, this.killPrayerReward = 0, this.damageCapPerHit}): _intrinsicTags = intrinsicTags,_skills = skills;
  factory _UnitDef.fromJson(Map<String, dynamic> json) => _$UnitDefFromJson(json);

@override final  String id;
@override@JsonKey() final  String nameKey;
 final  Map<String, int> _intrinsicTags;
@override@JsonKey() Map<String, int> get intrinsicTags {
  if (_intrinsicTags is EqualUnmodifiableMapView) return _intrinsicTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_intrinsicTags);
}

@override final  UnitBaseStats base;
 final  List<String> _skills;
@override@JsonKey() List<String> get skills {
  if (_skills is EqualUnmodifiableListView) return _skills;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skills);
}

@override@JsonKey() final  bool isBoss;
@override@JsonKey() final  int killPrayerReward;
@override final  int? damageCapPerHit;

/// Create a copy of UnitDef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnitDefCopyWith<_UnitDef> get copyWith => __$UnitDefCopyWithImpl<_UnitDef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnitDefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnitDef&&(identical(other.id, id) || other.id == id)&&(identical(other.nameKey, nameKey) || other.nameKey == nameKey)&&const DeepCollectionEquality().equals(other.intrinsicTags, _intrinsicTags)&&(identical(other.base, base) || other.base == base)&&const DeepCollectionEquality().equals(other.skills, _skills)&&(identical(other.isBoss, isBoss) || other.isBoss == isBoss)&&(identical(other.killPrayerReward, killPrayerReward) || other.killPrayerReward == killPrayerReward)&&(identical(other.damageCapPerHit, damageCapPerHit) || other.damageCapPerHit == damageCapPerHit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,nameKey,const DeepCollectionEquality().hash(_intrinsicTags),base,const DeepCollectionEquality().hash(_skills),isBoss,killPrayerReward,damageCapPerHit);
}

@override
String toString() {
    return 'UnitDef(id: $id, nameKey: $nameKey, intrinsicTags: $intrinsicTags, base: $base, skills: $skills, isBoss: $isBoss, killPrayerReward: $killPrayerReward, damageCapPerHit: $damageCapPerHit)';
}


}

/// @nodoc
abstract mixin class _$UnitDefCopyWith<$Res> implements $UnitDefCopyWith<$Res> {
  factory _$UnitDefCopyWith(_UnitDef value, $Res Function(_UnitDef) _then) = __$UnitDefCopyWithImpl;
@override @useResult
$Res call({
 String id, String nameKey, Map<String, int> intrinsicTags, UnitBaseStats base, List<String> skills, bool isBoss, int killPrayerReward, int? damageCapPerHit
});


@override $UnitBaseStatsCopyWith<$Res> get base;

}
/// @nodoc
class __$UnitDefCopyWithImpl<$Res>
    implements _$UnitDefCopyWith<$Res> {
  __$UnitDefCopyWithImpl(this._self, this._then);

  final _UnitDef _self;
  final $Res Function(_UnitDef) _then;

/// Create a copy of UnitDef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nameKey = null,Object? intrinsicTags = null,Object? base = null,Object? skills = null,Object? isBoss = null,Object? killPrayerReward = null,Object? damageCapPerHit = freezed,}) {
  return _then(_UnitDef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameKey: null == nameKey ? _self.nameKey : nameKey // ignore: cast_nullable_to_non_nullable
as String,intrinsicTags: null == intrinsicTags ? _self._intrinsicTags : intrinsicTags // ignore: cast_nullable_to_non_nullable
as Map<String, int>,base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as UnitBaseStats,skills: null == skills ? _self._skills : skills // ignore: cast_nullable_to_non_nullable
as List<String>,isBoss: null == isBoss ? _self.isBoss : isBoss // ignore: cast_nullable_to_non_nullable
as bool,killPrayerReward: null == killPrayerReward ? _self.killPrayerReward : killPrayerReward // ignore: cast_nullable_to_non_nullable
as int,damageCapPerHit: freezed == damageCapPerHit ? _self.damageCapPerHit : damageCapPerHit // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of UnitDef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UnitBaseStatsCopyWith<$Res> get base {
  
  return $UnitBaseStatsCopyWith<$Res>(_self.base, (value) {
    return _then(_self.copyWith(base: value));
  });
}
}

// dart format on
