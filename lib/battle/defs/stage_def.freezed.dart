// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stage_def.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BossTriggerDef {

 String get id; String get enemyId; String get conditionKind; int get warningTicks; int get spawnX;
/// Create a copy of BossTriggerDef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BossTriggerDefCopyWith<BossTriggerDef> get copyWith => _$BossTriggerDefCopyWithImpl<BossTriggerDef>(this as BossTriggerDef, _$identity);

  /// Serializes this BossTriggerDef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BossTriggerDef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BossTriggerDef&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.enemyId, _this.enemyId) || other.enemyId == _this.enemyId)&&(identical(other.conditionKind, _this.conditionKind) || other.conditionKind == _this.conditionKind)&&(identical(other.warningTicks, _this.warningTicks) || other.warningTicks == _this.warningTicks)&&(identical(other.spawnX, _this.spawnX) || other.spawnX == _this.spawnX));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BossTriggerDef;
  return Object.hash(runtimeType,_this.id,_this.enemyId,_this.conditionKind,_this.warningTicks,_this.spawnX);
}

@override
String toString() {
  final _this = this as BossTriggerDef;
  return 'BossTriggerDef(id: ${_this.id}, enemyId: ${_this.enemyId}, conditionKind: ${_this.conditionKind}, warningTicks: ${_this.warningTicks}, spawnX: ${_this.spawnX})';
}


}

/// @nodoc
abstract mixin class $BossTriggerDefCopyWith<$Res>  {
  factory $BossTriggerDefCopyWith(BossTriggerDef value, $Res Function(BossTriggerDef) _then) = _$BossTriggerDefCopyWithImpl;
@useResult
$Res call({
 String id, String enemyId, String conditionKind, int warningTicks, int spawnX
});




}
/// @nodoc
class _$BossTriggerDefCopyWithImpl<$Res>
    implements $BossTriggerDefCopyWith<$Res> {
  _$BossTriggerDefCopyWithImpl(this._self, this._then);

  final BossTriggerDef _self;
  final $Res Function(BossTriggerDef) _then;

/// Create a copy of BossTriggerDef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? enemyId = null,Object? conditionKind = null,Object? warningTicks = null,Object? spawnX = null,}) {
  return _then(BossTriggerDef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,enemyId: null == enemyId ? _self.enemyId : enemyId // ignore: cast_nullable_to_non_nullable
as String,conditionKind: null == conditionKind ? _self.conditionKind : conditionKind // ignore: cast_nullable_to_non_nullable
as String,warningTicks: null == warningTicks ? _self.warningTicks : warningTicks // ignore: cast_nullable_to_non_nullable
as int,spawnX: null == spawnX ? _self.spawnX : spawnX // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BossTriggerDef].
extension BossTriggerDefPatterns on BossTriggerDef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BossTriggerDef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BossTriggerDef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BossTriggerDef value)  $default,){
final _that = this;
switch (_that) {
case _BossTriggerDef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BossTriggerDef value)?  $default,){
final _that = this;
switch (_that) {
case _BossTriggerDef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String enemyId,  String conditionKind,  int warningTicks,  int spawnX)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BossTriggerDef() when $default != null:
return $default(_that.id,_that.enemyId,_that.conditionKind,_that.warningTicks,_that.spawnX);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String enemyId,  String conditionKind,  int warningTicks,  int spawnX)  $default,) {final _that = this;
switch (_that) {
case _BossTriggerDef():
return $default(_that.id,_that.enemyId,_that.conditionKind,_that.warningTicks,_that.spawnX);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String enemyId,  String conditionKind,  int warningTicks,  int spawnX)?  $default,) {final _that = this;
switch (_that) {
case _BossTriggerDef() when $default != null:
return $default(_that.id,_that.enemyId,_that.conditionKind,_that.warningTicks,_that.spawnX);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BossTriggerDef implements BossTriggerDef {
  const _BossTriggerDef({required this.id, required this.enemyId, required this.conditionKind, this.warningTicks = 0, required this.spawnX});
  factory _BossTriggerDef.fromJson(Map<String, dynamic> json) => _$BossTriggerDefFromJson(json);

@override final  String id;
@override final  String enemyId;
@override final  String conditionKind;
@override@JsonKey() final  int warningTicks;
@override final  int spawnX;

/// Create a copy of BossTriggerDef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BossTriggerDefCopyWith<_BossTriggerDef> get copyWith => __$BossTriggerDefCopyWithImpl<_BossTriggerDef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BossTriggerDefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BossTriggerDef&&(identical(other.id, id) || other.id == id)&&(identical(other.enemyId, enemyId) || other.enemyId == enemyId)&&(identical(other.conditionKind, conditionKind) || other.conditionKind == conditionKind)&&(identical(other.warningTicks, warningTicks) || other.warningTicks == warningTicks)&&(identical(other.spawnX, spawnX) || other.spawnX == spawnX));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,enemyId,conditionKind,warningTicks,spawnX);
}

@override
String toString() {
    return 'BossTriggerDef(id: $id, enemyId: $enemyId, conditionKind: $conditionKind, warningTicks: $warningTicks, spawnX: $spawnX)';
}


}

/// @nodoc
abstract mixin class _$BossTriggerDefCopyWith<$Res> implements $BossTriggerDefCopyWith<$Res> {
  factory _$BossTriggerDefCopyWith(_BossTriggerDef value, $Res Function(_BossTriggerDef) _then) = __$BossTriggerDefCopyWithImpl;
@override @useResult
$Res call({
 String id, String enemyId, String conditionKind, int warningTicks, int spawnX
});




}
/// @nodoc
class __$BossTriggerDefCopyWithImpl<$Res>
    implements _$BossTriggerDefCopyWith<$Res> {
  __$BossTriggerDefCopyWithImpl(this._self, this._then);

  final _BossTriggerDef _self;
  final $Res Function(_BossTriggerDef) _then;

/// Create a copy of BossTriggerDef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? enemyId = null,Object? conditionKind = null,Object? warningTicks = null,Object? spawnX = null,}) {
  return _then(_BossTriggerDef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,enemyId: null == enemyId ? _self.enemyId : enemyId // ignore: cast_nullable_to_non_nullable
as String,conditionKind: null == conditionKind ? _self.conditionKind : conditionKind // ignore: cast_nullable_to_non_nullable
as String,warningTicks: null == warningTicks ? _self.warningTicks : warningTicks // ignore: cast_nullable_to_non_nullable
as int,spawnX: null == spawnX ? _self.spawnX : spawnX // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$StageDef {

 String get id; int get index; String get nameKey; int get fieldLength; int get allyBaseX; int get enemyBaseX; int get enemyBaseHp; int get timeLimitSec; int get minClearSec; List<int> get targetClearSec; List<WaveDef> get waves; List<BossTriggerDef> get bossTriggers;
/// Create a copy of StageDef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StageDefCopyWith<StageDef> get copyWith => _$StageDefCopyWithImpl<StageDef>(this as StageDef, _$identity);

  /// Serializes this StageDef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StageDef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StageDef&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.index, _this.index) || other.index == _this.index)&&(identical(other.nameKey, _this.nameKey) || other.nameKey == _this.nameKey)&&(identical(other.fieldLength, _this.fieldLength) || other.fieldLength == _this.fieldLength)&&(identical(other.allyBaseX, _this.allyBaseX) || other.allyBaseX == _this.allyBaseX)&&(identical(other.enemyBaseX, _this.enemyBaseX) || other.enemyBaseX == _this.enemyBaseX)&&(identical(other.enemyBaseHp, _this.enemyBaseHp) || other.enemyBaseHp == _this.enemyBaseHp)&&(identical(other.timeLimitSec, _this.timeLimitSec) || other.timeLimitSec == _this.timeLimitSec)&&(identical(other.minClearSec, _this.minClearSec) || other.minClearSec == _this.minClearSec)&&const DeepCollectionEquality().equals(other.targetClearSec, _this.targetClearSec)&&const DeepCollectionEquality().equals(other.waves, _this.waves)&&const DeepCollectionEquality().equals(other.bossTriggers, _this.bossTriggers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StageDef;
  return Object.hash(runtimeType,_this.id,_this.index,_this.nameKey,_this.fieldLength,_this.allyBaseX,_this.enemyBaseX,_this.enemyBaseHp,_this.timeLimitSec,_this.minClearSec,const DeepCollectionEquality().hash(_this.targetClearSec),const DeepCollectionEquality().hash(_this.waves),const DeepCollectionEquality().hash(_this.bossTriggers));
}

@override
String toString() {
  final _this = this as StageDef;
  return 'StageDef(id: ${_this.id}, index: ${_this.index}, nameKey: ${_this.nameKey}, fieldLength: ${_this.fieldLength}, allyBaseX: ${_this.allyBaseX}, enemyBaseX: ${_this.enemyBaseX}, enemyBaseHp: ${_this.enemyBaseHp}, timeLimitSec: ${_this.timeLimitSec}, minClearSec: ${_this.minClearSec}, targetClearSec: ${_this.targetClearSec}, waves: ${_this.waves}, bossTriggers: ${_this.bossTriggers})';
}


}

/// @nodoc
abstract mixin class $StageDefCopyWith<$Res>  {
  factory $StageDefCopyWith(StageDef value, $Res Function(StageDef) _then) = _$StageDefCopyWithImpl;
@useResult
$Res call({
 String id, int index, String nameKey, int fieldLength, int allyBaseX, int enemyBaseX, int enemyBaseHp, int timeLimitSec, int minClearSec, List<int> targetClearSec, List<WaveDef> waves, List<BossTriggerDef> bossTriggers
});




}
/// @nodoc
class _$StageDefCopyWithImpl<$Res>
    implements $StageDefCopyWith<$Res> {
  _$StageDefCopyWithImpl(this._self, this._then);

  final StageDef _self;
  final $Res Function(StageDef) _then;

/// Create a copy of StageDef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? index = null,Object? nameKey = null,Object? fieldLength = null,Object? allyBaseX = null,Object? enemyBaseX = null,Object? enemyBaseHp = null,Object? timeLimitSec = null,Object? minClearSec = null,Object? targetClearSec = null,Object? waves = null,Object? bossTriggers = null,}) {
  return _then(StageDef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,nameKey: null == nameKey ? _self.nameKey : nameKey // ignore: cast_nullable_to_non_nullable
as String,fieldLength: null == fieldLength ? _self.fieldLength : fieldLength // ignore: cast_nullable_to_non_nullable
as int,allyBaseX: null == allyBaseX ? _self.allyBaseX : allyBaseX // ignore: cast_nullable_to_non_nullable
as int,enemyBaseX: null == enemyBaseX ? _self.enemyBaseX : enemyBaseX // ignore: cast_nullable_to_non_nullable
as int,enemyBaseHp: null == enemyBaseHp ? _self.enemyBaseHp : enemyBaseHp // ignore: cast_nullable_to_non_nullable
as int,timeLimitSec: null == timeLimitSec ? _self.timeLimitSec : timeLimitSec // ignore: cast_nullable_to_non_nullable
as int,minClearSec: null == minClearSec ? _self.minClearSec : minClearSec // ignore: cast_nullable_to_non_nullable
as int,targetClearSec: null == targetClearSec ? _self.targetClearSec : targetClearSec // ignore: cast_nullable_to_non_nullable
as List<int>,waves: null == waves ? _self.waves : waves // ignore: cast_nullable_to_non_nullable
as List<WaveDef>,bossTriggers: null == bossTriggers ? _self.bossTriggers : bossTriggers // ignore: cast_nullable_to_non_nullable
as List<BossTriggerDef>,
  ));
}

}


/// Adds pattern-matching-related methods to [StageDef].
extension StageDefPatterns on StageDef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StageDef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StageDef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StageDef value)  $default,){
final _that = this;
switch (_that) {
case _StageDef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StageDef value)?  $default,){
final _that = this;
switch (_that) {
case _StageDef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int index,  String nameKey,  int fieldLength,  int allyBaseX,  int enemyBaseX,  int enemyBaseHp,  int timeLimitSec,  int minClearSec,  List<int> targetClearSec,  List<WaveDef> waves,  List<BossTriggerDef> bossTriggers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StageDef() when $default != null:
return $default(_that.id,_that.index,_that.nameKey,_that.fieldLength,_that.allyBaseX,_that.enemyBaseX,_that.enemyBaseHp,_that.timeLimitSec,_that.minClearSec,_that.targetClearSec,_that.waves,_that.bossTriggers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int index,  String nameKey,  int fieldLength,  int allyBaseX,  int enemyBaseX,  int enemyBaseHp,  int timeLimitSec,  int minClearSec,  List<int> targetClearSec,  List<WaveDef> waves,  List<BossTriggerDef> bossTriggers)  $default,) {final _that = this;
switch (_that) {
case _StageDef():
return $default(_that.id,_that.index,_that.nameKey,_that.fieldLength,_that.allyBaseX,_that.enemyBaseX,_that.enemyBaseHp,_that.timeLimitSec,_that.minClearSec,_that.targetClearSec,_that.waves,_that.bossTriggers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int index,  String nameKey,  int fieldLength,  int allyBaseX,  int enemyBaseX,  int enemyBaseHp,  int timeLimitSec,  int minClearSec,  List<int> targetClearSec,  List<WaveDef> waves,  List<BossTriggerDef> bossTriggers)?  $default,) {final _that = this;
switch (_that) {
case _StageDef() when $default != null:
return $default(_that.id,_that.index,_that.nameKey,_that.fieldLength,_that.allyBaseX,_that.enemyBaseX,_that.enemyBaseHp,_that.timeLimitSec,_that.minClearSec,_that.targetClearSec,_that.waves,_that.bossTriggers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StageDef implements StageDef {
  const _StageDef({required this.id, required this.index, this.nameKey = '', required this.fieldLength, required this.allyBaseX, required this.enemyBaseX, required this.enemyBaseHp, required this.timeLimitSec, this.minClearSec = 0,  List<int> targetClearSec = const <int>[0, 0],  List<WaveDef> waves = const <WaveDef>[],  List<BossTriggerDef> bossTriggers = const <BossTriggerDef>[]}): _targetClearSec = targetClearSec,_waves = waves,_bossTriggers = bossTriggers;
  factory _StageDef.fromJson(Map<String, dynamic> json) => _$StageDefFromJson(json);

@override final  String id;
@override final  int index;
@override@JsonKey() final  String nameKey;
@override final  int fieldLength;
@override final  int allyBaseX;
@override final  int enemyBaseX;
@override final  int enemyBaseHp;
@override final  int timeLimitSec;
@override@JsonKey() final  int minClearSec;
 final  List<int> _targetClearSec;
@override@JsonKey() List<int> get targetClearSec {
  if (_targetClearSec is EqualUnmodifiableListView) return _targetClearSec;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_targetClearSec);
}

 final  List<WaveDef> _waves;
@override@JsonKey() List<WaveDef> get waves {
  if (_waves is EqualUnmodifiableListView) return _waves;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_waves);
}

 final  List<BossTriggerDef> _bossTriggers;
@override@JsonKey() List<BossTriggerDef> get bossTriggers {
  if (_bossTriggers is EqualUnmodifiableListView) return _bossTriggers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bossTriggers);
}


/// Create a copy of StageDef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StageDefCopyWith<_StageDef> get copyWith => __$StageDefCopyWithImpl<_StageDef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StageDefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StageDef&&(identical(other.id, id) || other.id == id)&&(identical(other.index, index) || other.index == index)&&(identical(other.nameKey, nameKey) || other.nameKey == nameKey)&&(identical(other.fieldLength, fieldLength) || other.fieldLength == fieldLength)&&(identical(other.allyBaseX, allyBaseX) || other.allyBaseX == allyBaseX)&&(identical(other.enemyBaseX, enemyBaseX) || other.enemyBaseX == enemyBaseX)&&(identical(other.enemyBaseHp, enemyBaseHp) || other.enemyBaseHp == enemyBaseHp)&&(identical(other.timeLimitSec, timeLimitSec) || other.timeLimitSec == timeLimitSec)&&(identical(other.minClearSec, minClearSec) || other.minClearSec == minClearSec)&&const DeepCollectionEquality().equals(other.targetClearSec, _targetClearSec)&&const DeepCollectionEquality().equals(other.waves, _waves)&&const DeepCollectionEquality().equals(other.bossTriggers, _bossTriggers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,index,nameKey,fieldLength,allyBaseX,enemyBaseX,enemyBaseHp,timeLimitSec,minClearSec,const DeepCollectionEquality().hash(_targetClearSec),const DeepCollectionEquality().hash(_waves),const DeepCollectionEquality().hash(_bossTriggers));
}

@override
String toString() {
    return 'StageDef(id: $id, index: $index, nameKey: $nameKey, fieldLength: $fieldLength, allyBaseX: $allyBaseX, enemyBaseX: $enemyBaseX, enemyBaseHp: $enemyBaseHp, timeLimitSec: $timeLimitSec, minClearSec: $minClearSec, targetClearSec: $targetClearSec, waves: $waves, bossTriggers: $bossTriggers)';
}


}

/// @nodoc
abstract mixin class _$StageDefCopyWith<$Res> implements $StageDefCopyWith<$Res> {
  factory _$StageDefCopyWith(_StageDef value, $Res Function(_StageDef) _then) = __$StageDefCopyWithImpl;
@override @useResult
$Res call({
 String id, int index, String nameKey, int fieldLength, int allyBaseX, int enemyBaseX, int enemyBaseHp, int timeLimitSec, int minClearSec, List<int> targetClearSec, List<WaveDef> waves, List<BossTriggerDef> bossTriggers
});




}
/// @nodoc
class __$StageDefCopyWithImpl<$Res>
    implements _$StageDefCopyWith<$Res> {
  __$StageDefCopyWithImpl(this._self, this._then);

  final _StageDef _self;
  final $Res Function(_StageDef) _then;

/// Create a copy of StageDef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? index = null,Object? nameKey = null,Object? fieldLength = null,Object? allyBaseX = null,Object? enemyBaseX = null,Object? enemyBaseHp = null,Object? timeLimitSec = null,Object? minClearSec = null,Object? targetClearSec = null,Object? waves = null,Object? bossTriggers = null,}) {
  return _then(_StageDef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,nameKey: null == nameKey ? _self.nameKey : nameKey // ignore: cast_nullable_to_non_nullable
as String,fieldLength: null == fieldLength ? _self.fieldLength : fieldLength // ignore: cast_nullable_to_non_nullable
as int,allyBaseX: null == allyBaseX ? _self.allyBaseX : allyBaseX // ignore: cast_nullable_to_non_nullable
as int,enemyBaseX: null == enemyBaseX ? _self.enemyBaseX : enemyBaseX // ignore: cast_nullable_to_non_nullable
as int,enemyBaseHp: null == enemyBaseHp ? _self.enemyBaseHp : enemyBaseHp // ignore: cast_nullable_to_non_nullable
as int,timeLimitSec: null == timeLimitSec ? _self.timeLimitSec : timeLimitSec // ignore: cast_nullable_to_non_nullable
as int,minClearSec: null == minClearSec ? _self.minClearSec : minClearSec // ignore: cast_nullable_to_non_nullable
as int,targetClearSec: null == targetClearSec ? _self._targetClearSec : targetClearSec // ignore: cast_nullable_to_non_nullable
as List<int>,waves: null == waves ? _self._waves : waves // ignore: cast_nullable_to_non_nullable
as List<WaveDef>,bossTriggers: null == bossTriggers ? _self._bossTriggers : bossTriggers // ignore: cast_nullable_to_non_nullable
as List<BossTriggerDef>,
  ));
}


}

// dart format on
