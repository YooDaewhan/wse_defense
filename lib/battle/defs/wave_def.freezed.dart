// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wave_def.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WaveDef {

 String get enemyId; int get startSec; int get intervalSec; int get count; int get stopSec; int get spawnX;
/// Create a copy of WaveDef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WaveDefCopyWith<WaveDef> get copyWith => _$WaveDefCopyWithImpl<WaveDef>(this as WaveDef, _$identity);

  /// Serializes this WaveDef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WaveDef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WaveDef&&(identical(other.enemyId, _this.enemyId) || other.enemyId == _this.enemyId)&&(identical(other.startSec, _this.startSec) || other.startSec == _this.startSec)&&(identical(other.intervalSec, _this.intervalSec) || other.intervalSec == _this.intervalSec)&&(identical(other.count, _this.count) || other.count == _this.count)&&(identical(other.stopSec, _this.stopSec) || other.stopSec == _this.stopSec)&&(identical(other.spawnX, _this.spawnX) || other.spawnX == _this.spawnX));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WaveDef;
  return Object.hash(runtimeType,_this.enemyId,_this.startSec,_this.intervalSec,_this.count,_this.stopSec,_this.spawnX);
}

@override
String toString() {
  final _this = this as WaveDef;
  return 'WaveDef(enemyId: ${_this.enemyId}, startSec: ${_this.startSec}, intervalSec: ${_this.intervalSec}, count: ${_this.count}, stopSec: ${_this.stopSec}, spawnX: ${_this.spawnX})';
}


}

/// @nodoc
abstract mixin class $WaveDefCopyWith<$Res>  {
  factory $WaveDefCopyWith(WaveDef value, $Res Function(WaveDef) _then) = _$WaveDefCopyWithImpl;
@useResult
$Res call({
 String enemyId, int startSec, int intervalSec, int count, int stopSec, int spawnX
});




}
/// @nodoc
class _$WaveDefCopyWithImpl<$Res>
    implements $WaveDefCopyWith<$Res> {
  _$WaveDefCopyWithImpl(this._self, this._then);

  final WaveDef _self;
  final $Res Function(WaveDef) _then;

/// Create a copy of WaveDef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enemyId = null,Object? startSec = null,Object? intervalSec = null,Object? count = null,Object? stopSec = null,Object? spawnX = null,}) {
  return _then(WaveDef(
enemyId: null == enemyId ? _self.enemyId : enemyId // ignore: cast_nullable_to_non_nullable
as String,startSec: null == startSec ? _self.startSec : startSec // ignore: cast_nullable_to_non_nullable
as int,intervalSec: null == intervalSec ? _self.intervalSec : intervalSec // ignore: cast_nullable_to_non_nullable
as int,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,stopSec: null == stopSec ? _self.stopSec : stopSec // ignore: cast_nullable_to_non_nullable
as int,spawnX: null == spawnX ? _self.spawnX : spawnX // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WaveDef].
extension WaveDefPatterns on WaveDef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WaveDef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WaveDef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WaveDef value)  $default,){
final _that = this;
switch (_that) {
case _WaveDef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WaveDef value)?  $default,){
final _that = this;
switch (_that) {
case _WaveDef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String enemyId,  int startSec,  int intervalSec,  int count,  int stopSec,  int spawnX)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WaveDef() when $default != null:
return $default(_that.enemyId,_that.startSec,_that.intervalSec,_that.count,_that.stopSec,_that.spawnX);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String enemyId,  int startSec,  int intervalSec,  int count,  int stopSec,  int spawnX)  $default,) {final _that = this;
switch (_that) {
case _WaveDef():
return $default(_that.enemyId,_that.startSec,_that.intervalSec,_that.count,_that.stopSec,_that.spawnX);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String enemyId,  int startSec,  int intervalSec,  int count,  int stopSec,  int spawnX)?  $default,) {final _that = this;
switch (_that) {
case _WaveDef() when $default != null:
return $default(_that.enemyId,_that.startSec,_that.intervalSec,_that.count,_that.stopSec,_that.spawnX);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WaveDef implements WaveDef {
  const _WaveDef({required this.enemyId, required this.startSec, required this.intervalSec, this.count = -1, required this.stopSec, required this.spawnX});
  factory _WaveDef.fromJson(Map<String, dynamic> json) => _$WaveDefFromJson(json);

@override final  String enemyId;
@override final  int startSec;
@override final  int intervalSec;
@override@JsonKey() final  int count;
@override final  int stopSec;
@override final  int spawnX;

/// Create a copy of WaveDef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WaveDefCopyWith<_WaveDef> get copyWith => __$WaveDefCopyWithImpl<_WaveDef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WaveDefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WaveDef&&(identical(other.enemyId, enemyId) || other.enemyId == enemyId)&&(identical(other.startSec, startSec) || other.startSec == startSec)&&(identical(other.intervalSec, intervalSec) || other.intervalSec == intervalSec)&&(identical(other.count, count) || other.count == count)&&(identical(other.stopSec, stopSec) || other.stopSec == stopSec)&&(identical(other.spawnX, spawnX) || other.spawnX == spawnX));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enemyId,startSec,intervalSec,count,stopSec,spawnX);
}

@override
String toString() {
    return 'WaveDef(enemyId: $enemyId, startSec: $startSec, intervalSec: $intervalSec, count: $count, stopSec: $stopSec, spawnX: $spawnX)';
}


}

/// @nodoc
abstract mixin class _$WaveDefCopyWith<$Res> implements $WaveDefCopyWith<$Res> {
  factory _$WaveDefCopyWith(_WaveDef value, $Res Function(_WaveDef) _then) = __$WaveDefCopyWithImpl;
@override @useResult
$Res call({
 String enemyId, int startSec, int intervalSec, int count, int stopSec, int spawnX
});




}
/// @nodoc
class __$WaveDefCopyWithImpl<$Res>
    implements _$WaveDefCopyWith<$Res> {
  __$WaveDefCopyWithImpl(this._self, this._then);

  final _WaveDef _self;
  final $Res Function(_WaveDef) _then;

/// Create a copy of WaveDef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enemyId = null,Object? startSec = null,Object? intervalSec = null,Object? count = null,Object? stopSec = null,Object? spawnX = null,}) {
  return _then(_WaveDef(
enemyId: null == enemyId ? _self.enemyId : enemyId // ignore: cast_nullable_to_non_nullable
as String,startSec: null == startSec ? _self.startSec : startSec // ignore: cast_nullable_to_non_nullable
as int,intervalSec: null == intervalSec ? _self.intervalSec : intervalSec // ignore: cast_nullable_to_non_nullable
as int,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,stopSec: null == stopSec ? _self.stopSec : stopSec // ignore: cast_nullable_to_non_nullable
as int,spawnX: null == spawnX ? _self.spawnX : spawnX // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
