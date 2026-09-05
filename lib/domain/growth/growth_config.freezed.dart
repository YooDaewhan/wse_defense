// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'growth_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GoldCostFormula {

 int get base; double get growth;
/// Create a copy of GoldCostFormula
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoldCostFormulaCopyWith<GoldCostFormula> get copyWith => _$GoldCostFormulaCopyWithImpl<GoldCostFormula>(this as GoldCostFormula, _$identity);

  /// Serializes this GoldCostFormula to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GoldCostFormula;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoldCostFormula&&(identical(other.base, _this.base) || other.base == _this.base)&&(identical(other.growth, _this.growth) || other.growth == _this.growth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GoldCostFormula;
  return Object.hash(runtimeType,_this.base,_this.growth);
}

@override
String toString() {
  final _this = this as GoldCostFormula;
  return 'GoldCostFormula(base: ${_this.base}, growth: ${_this.growth})';
}


}

/// @nodoc
abstract mixin class $GoldCostFormulaCopyWith<$Res>  {
  factory $GoldCostFormulaCopyWith(GoldCostFormula value, $Res Function(GoldCostFormula) _then) = _$GoldCostFormulaCopyWithImpl;
@useResult
$Res call({
 int base, double growth
});




}
/// @nodoc
class _$GoldCostFormulaCopyWithImpl<$Res>
    implements $GoldCostFormulaCopyWith<$Res> {
  _$GoldCostFormulaCopyWithImpl(this._self, this._then);

  final GoldCostFormula _self;
  final $Res Function(GoldCostFormula) _then;

/// Create a copy of GoldCostFormula
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? base = null,Object? growth = null,}) {
  return _then(GoldCostFormula(
base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as int,growth: null == growth ? _self.growth : growth // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [GoldCostFormula].
extension GoldCostFormulaPatterns on GoldCostFormula {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoldCostFormula value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoldCostFormula() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoldCostFormula value)  $default,){
final _that = this;
switch (_that) {
case _GoldCostFormula():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoldCostFormula value)?  $default,){
final _that = this;
switch (_that) {
case _GoldCostFormula() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int base,  double growth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoldCostFormula() when $default != null:
return $default(_that.base,_that.growth);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int base,  double growth)  $default,) {final _that = this;
switch (_that) {
case _GoldCostFormula():
return $default(_that.base,_that.growth);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int base,  double growth)?  $default,) {final _that = this;
switch (_that) {
case _GoldCostFormula() when $default != null:
return $default(_that.base,_that.growth);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoldCostFormula extends GoldCostFormula {
  const _GoldCostFormula({required this.base, required this.growth}): super._();
  factory _GoldCostFormula.fromJson(Map<String, dynamic> json) => _$GoldCostFormulaFromJson(json);

@override final  int base;
@override final  double growth;

/// Create a copy of GoldCostFormula
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoldCostFormulaCopyWith<_GoldCostFormula> get copyWith => __$GoldCostFormulaCopyWithImpl<_GoldCostFormula>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoldCostFormulaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoldCostFormula&&(identical(other.base, base) || other.base == base)&&(identical(other.growth, growth) || other.growth == growth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,base,growth);
}

@override
String toString() {
    return 'GoldCostFormula(base: $base, growth: $growth)';
}


}

/// @nodoc
abstract mixin class _$GoldCostFormulaCopyWith<$Res> implements $GoldCostFormulaCopyWith<$Res> {
  factory _$GoldCostFormulaCopyWith(_GoldCostFormula value, $Res Function(_GoldCostFormula) _then) = __$GoldCostFormulaCopyWithImpl;
@override @useResult
$Res call({
 int base, double growth
});




}
/// @nodoc
class __$GoldCostFormulaCopyWithImpl<$Res>
    implements _$GoldCostFormulaCopyWith<$Res> {
  __$GoldCostFormulaCopyWithImpl(this._self, this._then);

  final _GoldCostFormula _self;
  final $Res Function(_GoldCostFormula) _then;

/// Create a copy of GoldCostFormula
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? base = null,Object? growth = null,}) {
  return _then(_GoldCostFormula(
base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as int,growth: null == growth ? _self.growth : growth // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$FocusKeyframe {

 int get level; int get regenPerSec; int get cap; int get startAmount;
/// Create a copy of FocusKeyframe
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FocusKeyframeCopyWith<FocusKeyframe> get copyWith => _$FocusKeyframeCopyWithImpl<FocusKeyframe>(this as FocusKeyframe, _$identity);

  /// Serializes this FocusKeyframe to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FocusKeyframe;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FocusKeyframe&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.regenPerSec, _this.regenPerSec) || other.regenPerSec == _this.regenPerSec)&&(identical(other.cap, _this.cap) || other.cap == _this.cap)&&(identical(other.startAmount, _this.startAmount) || other.startAmount == _this.startAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FocusKeyframe;
  return Object.hash(runtimeType,_this.level,_this.regenPerSec,_this.cap,_this.startAmount);
}

@override
String toString() {
  final _this = this as FocusKeyframe;
  return 'FocusKeyframe(level: ${_this.level}, regenPerSec: ${_this.regenPerSec}, cap: ${_this.cap}, startAmount: ${_this.startAmount})';
}


}

/// @nodoc
abstract mixin class $FocusKeyframeCopyWith<$Res>  {
  factory $FocusKeyframeCopyWith(FocusKeyframe value, $Res Function(FocusKeyframe) _then) = _$FocusKeyframeCopyWithImpl;
@useResult
$Res call({
 int level, int regenPerSec, int cap, int startAmount
});




}
/// @nodoc
class _$FocusKeyframeCopyWithImpl<$Res>
    implements $FocusKeyframeCopyWith<$Res> {
  _$FocusKeyframeCopyWithImpl(this._self, this._then);

  final FocusKeyframe _self;
  final $Res Function(FocusKeyframe) _then;

/// Create a copy of FocusKeyframe
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? level = null,Object? regenPerSec = null,Object? cap = null,Object? startAmount = null,}) {
  return _then(FocusKeyframe(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,regenPerSec: null == regenPerSec ? _self.regenPerSec : regenPerSec // ignore: cast_nullable_to_non_nullable
as int,cap: null == cap ? _self.cap : cap // ignore: cast_nullable_to_non_nullable
as int,startAmount: null == startAmount ? _self.startAmount : startAmount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FocusKeyframe].
extension FocusKeyframePatterns on FocusKeyframe {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FocusKeyframe value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FocusKeyframe() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FocusKeyframe value)  $default,){
final _that = this;
switch (_that) {
case _FocusKeyframe():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FocusKeyframe value)?  $default,){
final _that = this;
switch (_that) {
case _FocusKeyframe() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int level,  int regenPerSec,  int cap,  int startAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FocusKeyframe() when $default != null:
return $default(_that.level,_that.regenPerSec,_that.cap,_that.startAmount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int level,  int regenPerSec,  int cap,  int startAmount)  $default,) {final _that = this;
switch (_that) {
case _FocusKeyframe():
return $default(_that.level,_that.regenPerSec,_that.cap,_that.startAmount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int level,  int regenPerSec,  int cap,  int startAmount)?  $default,) {final _that = this;
switch (_that) {
case _FocusKeyframe() when $default != null:
return $default(_that.level,_that.regenPerSec,_that.cap,_that.startAmount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FocusKeyframe implements FocusKeyframe {
  const _FocusKeyframe({required this.level, required this.regenPerSec, required this.cap, required this.startAmount});
  factory _FocusKeyframe.fromJson(Map<String, dynamic> json) => _$FocusKeyframeFromJson(json);

@override final  int level;
@override final  int regenPerSec;
@override final  int cap;
@override final  int startAmount;

/// Create a copy of FocusKeyframe
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FocusKeyframeCopyWith<_FocusKeyframe> get copyWith => __$FocusKeyframeCopyWithImpl<_FocusKeyframe>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FocusKeyframeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FocusKeyframe&&(identical(other.level, level) || other.level == level)&&(identical(other.regenPerSec, regenPerSec) || other.regenPerSec == regenPerSec)&&(identical(other.cap, cap) || other.cap == cap)&&(identical(other.startAmount, startAmount) || other.startAmount == startAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,level,regenPerSec,cap,startAmount);
}

@override
String toString() {
    return 'FocusKeyframe(level: $level, regenPerSec: $regenPerSec, cap: $cap, startAmount: $startAmount)';
}


}

/// @nodoc
abstract mixin class _$FocusKeyframeCopyWith<$Res> implements $FocusKeyframeCopyWith<$Res> {
  factory _$FocusKeyframeCopyWith(_FocusKeyframe value, $Res Function(_FocusKeyframe) _then) = __$FocusKeyframeCopyWithImpl;
@override @useResult
$Res call({
 int level, int regenPerSec, int cap, int startAmount
});




}
/// @nodoc
class __$FocusKeyframeCopyWithImpl<$Res>
    implements _$FocusKeyframeCopyWith<$Res> {
  __$FocusKeyframeCopyWithImpl(this._self, this._then);

  final _FocusKeyframe _self;
  final $Res Function(_FocusKeyframe) _then;

/// Create a copy of FocusKeyframe
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? level = null,Object? regenPerSec = null,Object? cap = null,Object? startAmount = null,}) {
  return _then(_FocusKeyframe(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,regenPerSec: null == regenPerSec ? _self.regenPerSec : regenPerSec // ignore: cast_nullable_to_non_nullable
as int,cap: null == cap ? _self.cap : cap // ignore: cast_nullable_to_non_nullable
as int,startAmount: null == startAmount ? _self.startAmount : startAmount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CampKeyframe {

 int get level; int get hp;
/// Create a copy of CampKeyframe
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CampKeyframeCopyWith<CampKeyframe> get copyWith => _$CampKeyframeCopyWithImpl<CampKeyframe>(this as CampKeyframe, _$identity);

  /// Serializes this CampKeyframe to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CampKeyframe;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CampKeyframe&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.hp, _this.hp) || other.hp == _this.hp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CampKeyframe;
  return Object.hash(runtimeType,_this.level,_this.hp);
}

@override
String toString() {
  final _this = this as CampKeyframe;
  return 'CampKeyframe(level: ${_this.level}, hp: ${_this.hp})';
}


}

/// @nodoc
abstract mixin class $CampKeyframeCopyWith<$Res>  {
  factory $CampKeyframeCopyWith(CampKeyframe value, $Res Function(CampKeyframe) _then) = _$CampKeyframeCopyWithImpl;
@useResult
$Res call({
 int level, int hp
});




}
/// @nodoc
class _$CampKeyframeCopyWithImpl<$Res>
    implements $CampKeyframeCopyWith<$Res> {
  _$CampKeyframeCopyWithImpl(this._self, this._then);

  final CampKeyframe _self;
  final $Res Function(CampKeyframe) _then;

/// Create a copy of CampKeyframe
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? level = null,Object? hp = null,}) {
  return _then(CampKeyframe(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,hp: null == hp ? _self.hp : hp // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CampKeyframe].
extension CampKeyframePatterns on CampKeyframe {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CampKeyframe value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CampKeyframe() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CampKeyframe value)  $default,){
final _that = this;
switch (_that) {
case _CampKeyframe():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CampKeyframe value)?  $default,){
final _that = this;
switch (_that) {
case _CampKeyframe() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int level,  int hp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CampKeyframe() when $default != null:
return $default(_that.level,_that.hp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int level,  int hp)  $default,) {final _that = this;
switch (_that) {
case _CampKeyframe():
return $default(_that.level,_that.hp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int level,  int hp)?  $default,) {final _that = this;
switch (_that) {
case _CampKeyframe() when $default != null:
return $default(_that.level,_that.hp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CampKeyframe implements CampKeyframe {
  const _CampKeyframe({required this.level, required this.hp});
  factory _CampKeyframe.fromJson(Map<String, dynamic> json) => _$CampKeyframeFromJson(json);

@override final  int level;
@override final  int hp;

/// Create a copy of CampKeyframe
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CampKeyframeCopyWith<_CampKeyframe> get copyWith => __$CampKeyframeCopyWithImpl<_CampKeyframe>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CampKeyframeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CampKeyframe&&(identical(other.level, level) || other.level == level)&&(identical(other.hp, hp) || other.hp == hp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,level,hp);
}

@override
String toString() {
    return 'CampKeyframe(level: $level, hp: $hp)';
}


}

/// @nodoc
abstract mixin class _$CampKeyframeCopyWith<$Res> implements $CampKeyframeCopyWith<$Res> {
  factory _$CampKeyframeCopyWith(_CampKeyframe value, $Res Function(_CampKeyframe) _then) = __$CampKeyframeCopyWithImpl;
@override @useResult
$Res call({
 int level, int hp
});




}
/// @nodoc
class __$CampKeyframeCopyWithImpl<$Res>
    implements _$CampKeyframeCopyWith<$Res> {
  __$CampKeyframeCopyWithImpl(this._self, this._then);

  final _CampKeyframe _self;
  final $Res Function(_CampKeyframe) _then;

/// Create a copy of CampKeyframe
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? level = null,Object? hp = null,}) {
  return _then(_CampKeyframe(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,hp: null == hp ? _self.hp : hp // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$FocusBoostStage {

 int get stage; int get regenBonus; int get capBonus; int get cost;
/// Create a copy of FocusBoostStage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FocusBoostStageCopyWith<FocusBoostStage> get copyWith => _$FocusBoostStageCopyWithImpl<FocusBoostStage>(this as FocusBoostStage, _$identity);

  /// Serializes this FocusBoostStage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FocusBoostStage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FocusBoostStage&&(identical(other.stage, _this.stage) || other.stage == _this.stage)&&(identical(other.regenBonus, _this.regenBonus) || other.regenBonus == _this.regenBonus)&&(identical(other.capBonus, _this.capBonus) || other.capBonus == _this.capBonus)&&(identical(other.cost, _this.cost) || other.cost == _this.cost));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FocusBoostStage;
  return Object.hash(runtimeType,_this.stage,_this.regenBonus,_this.capBonus,_this.cost);
}

@override
String toString() {
  final _this = this as FocusBoostStage;
  return 'FocusBoostStage(stage: ${_this.stage}, regenBonus: ${_this.regenBonus}, capBonus: ${_this.capBonus}, cost: ${_this.cost})';
}


}

/// @nodoc
abstract mixin class $FocusBoostStageCopyWith<$Res>  {
  factory $FocusBoostStageCopyWith(FocusBoostStage value, $Res Function(FocusBoostStage) _then) = _$FocusBoostStageCopyWithImpl;
@useResult
$Res call({
 int stage, int regenBonus, int capBonus, int cost
});




}
/// @nodoc
class _$FocusBoostStageCopyWithImpl<$Res>
    implements $FocusBoostStageCopyWith<$Res> {
  _$FocusBoostStageCopyWithImpl(this._self, this._then);

  final FocusBoostStage _self;
  final $Res Function(FocusBoostStage) _then;

/// Create a copy of FocusBoostStage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stage = null,Object? regenBonus = null,Object? capBonus = null,Object? cost = null,}) {
  return _then(FocusBoostStage(
stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as int,regenBonus: null == regenBonus ? _self.regenBonus : regenBonus // ignore: cast_nullable_to_non_nullable
as int,capBonus: null == capBonus ? _self.capBonus : capBonus // ignore: cast_nullable_to_non_nullable
as int,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FocusBoostStage].
extension FocusBoostStagePatterns on FocusBoostStage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FocusBoostStage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FocusBoostStage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FocusBoostStage value)  $default,){
final _that = this;
switch (_that) {
case _FocusBoostStage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FocusBoostStage value)?  $default,){
final _that = this;
switch (_that) {
case _FocusBoostStage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int stage,  int regenBonus,  int capBonus,  int cost)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FocusBoostStage() when $default != null:
return $default(_that.stage,_that.regenBonus,_that.capBonus,_that.cost);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int stage,  int regenBonus,  int capBonus,  int cost)  $default,) {final _that = this;
switch (_that) {
case _FocusBoostStage():
return $default(_that.stage,_that.regenBonus,_that.capBonus,_that.cost);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int stage,  int regenBonus,  int capBonus,  int cost)?  $default,) {final _that = this;
switch (_that) {
case _FocusBoostStage() when $default != null:
return $default(_that.stage,_that.regenBonus,_that.capBonus,_that.cost);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FocusBoostStage implements FocusBoostStage {
  const _FocusBoostStage({required this.stage, required this.regenBonus, required this.capBonus, required this.cost});
  factory _FocusBoostStage.fromJson(Map<String, dynamic> json) => _$FocusBoostStageFromJson(json);

@override final  int stage;
@override final  int regenBonus;
@override final  int capBonus;
@override final  int cost;

/// Create a copy of FocusBoostStage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FocusBoostStageCopyWith<_FocusBoostStage> get copyWith => __$FocusBoostStageCopyWithImpl<_FocusBoostStage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FocusBoostStageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FocusBoostStage&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.regenBonus, regenBonus) || other.regenBonus == regenBonus)&&(identical(other.capBonus, capBonus) || other.capBonus == capBonus)&&(identical(other.cost, cost) || other.cost == cost));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,stage,regenBonus,capBonus,cost);
}

@override
String toString() {
    return 'FocusBoostStage(stage: $stage, regenBonus: $regenBonus, capBonus: $capBonus, cost: $cost)';
}


}

/// @nodoc
abstract mixin class _$FocusBoostStageCopyWith<$Res> implements $FocusBoostStageCopyWith<$Res> {
  factory _$FocusBoostStageCopyWith(_FocusBoostStage value, $Res Function(_FocusBoostStage) _then) = __$FocusBoostStageCopyWithImpl;
@override @useResult
$Res call({
 int stage, int regenBonus, int capBonus, int cost
});




}
/// @nodoc
class __$FocusBoostStageCopyWithImpl<$Res>
    implements _$FocusBoostStageCopyWith<$Res> {
  __$FocusBoostStageCopyWithImpl(this._self, this._then);

  final _FocusBoostStage _self;
  final $Res Function(_FocusBoostStage) _then;

/// Create a copy of FocusBoostStage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stage = null,Object? regenBonus = null,Object? capBonus = null,Object? cost = null,}) {
  return _then(_FocusBoostStage(
stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as int,regenBonus: null == regenBonus ? _self.regenBonus : regenBonus // ignore: cast_nullable_to_non_nullable
as int,capBonus: null == capBonus ? _self.capBonus : capBonus // ignore: cast_nullable_to_non_nullable
as int,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$GrowthConfig {

 List<FocusKeyframe> get focusKeyframes; GoldCostFormula get focusGoldCost; List<CampKeyframe> get campKeyframes; GoldCostFormula get campGoldCost; List<FocusBoostStage> get focusBoost; int get bondMaxLevel; GoldCostFormula get bondGoldCost;
/// Create a copy of GrowthConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GrowthConfigCopyWith<GrowthConfig> get copyWith => _$GrowthConfigCopyWithImpl<GrowthConfig>(this as GrowthConfig, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GrowthConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GrowthConfig&&const DeepCollectionEquality().equals(other.focusKeyframes, _this.focusKeyframes)&&(identical(other.focusGoldCost, _this.focusGoldCost) || other.focusGoldCost == _this.focusGoldCost)&&const DeepCollectionEquality().equals(other.campKeyframes, _this.campKeyframes)&&(identical(other.campGoldCost, _this.campGoldCost) || other.campGoldCost == _this.campGoldCost)&&const DeepCollectionEquality().equals(other.focusBoost, _this.focusBoost)&&(identical(other.bondMaxLevel, _this.bondMaxLevel) || other.bondMaxLevel == _this.bondMaxLevel)&&(identical(other.bondGoldCost, _this.bondGoldCost) || other.bondGoldCost == _this.bondGoldCost));
}


@override
int get hashCode {
  final _this = this as GrowthConfig;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.focusKeyframes),_this.focusGoldCost,const DeepCollectionEquality().hash(_this.campKeyframes),_this.campGoldCost,const DeepCollectionEquality().hash(_this.focusBoost),_this.bondMaxLevel,_this.bondGoldCost);
}

@override
String toString() {
  final _this = this as GrowthConfig;
  return 'GrowthConfig(focusKeyframes: ${_this.focusKeyframes}, focusGoldCost: ${_this.focusGoldCost}, campKeyframes: ${_this.campKeyframes}, campGoldCost: ${_this.campGoldCost}, focusBoost: ${_this.focusBoost}, bondMaxLevel: ${_this.bondMaxLevel}, bondGoldCost: ${_this.bondGoldCost})';
}


}

/// @nodoc
abstract mixin class $GrowthConfigCopyWith<$Res>  {
  factory $GrowthConfigCopyWith(GrowthConfig value, $Res Function(GrowthConfig) _then) = _$GrowthConfigCopyWithImpl;
@useResult
$Res call({
 List<FocusKeyframe> focusKeyframes, GoldCostFormula focusGoldCost, List<CampKeyframe> campKeyframes, GoldCostFormula campGoldCost, List<FocusBoostStage> focusBoost, int bondMaxLevel, GoldCostFormula bondGoldCost
});


$GoldCostFormulaCopyWith<$Res> get focusGoldCost;$GoldCostFormulaCopyWith<$Res> get campGoldCost;$GoldCostFormulaCopyWith<$Res> get bondGoldCost;

}
/// @nodoc
class _$GrowthConfigCopyWithImpl<$Res>
    implements $GrowthConfigCopyWith<$Res> {
  _$GrowthConfigCopyWithImpl(this._self, this._then);

  final GrowthConfig _self;
  final $Res Function(GrowthConfig) _then;

/// Create a copy of GrowthConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? focusKeyframes = null,Object? focusGoldCost = null,Object? campKeyframes = null,Object? campGoldCost = null,Object? focusBoost = null,Object? bondMaxLevel = null,Object? bondGoldCost = null,}) {
  return _then(GrowthConfig(
focusKeyframes: null == focusKeyframes ? _self.focusKeyframes : focusKeyframes // ignore: cast_nullable_to_non_nullable
as List<FocusKeyframe>,focusGoldCost: null == focusGoldCost ? _self.focusGoldCost : focusGoldCost // ignore: cast_nullable_to_non_nullable
as GoldCostFormula,campKeyframes: null == campKeyframes ? _self.campKeyframes : campKeyframes // ignore: cast_nullable_to_non_nullable
as List<CampKeyframe>,campGoldCost: null == campGoldCost ? _self.campGoldCost : campGoldCost // ignore: cast_nullable_to_non_nullable
as GoldCostFormula,focusBoost: null == focusBoost ? _self.focusBoost : focusBoost // ignore: cast_nullable_to_non_nullable
as List<FocusBoostStage>,bondMaxLevel: null == bondMaxLevel ? _self.bondMaxLevel : bondMaxLevel // ignore: cast_nullable_to_non_nullable
as int,bondGoldCost: null == bondGoldCost ? _self.bondGoldCost : bondGoldCost // ignore: cast_nullable_to_non_nullable
as GoldCostFormula,
  ));
}
/// Create a copy of GrowthConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GoldCostFormulaCopyWith<$Res> get focusGoldCost {
  
  return $GoldCostFormulaCopyWith<$Res>(_self.focusGoldCost, (value) {
    return _then(_self.copyWith(focusGoldCost: value));
  });
}/// Create a copy of GrowthConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GoldCostFormulaCopyWith<$Res> get campGoldCost {
  
  return $GoldCostFormulaCopyWith<$Res>(_self.campGoldCost, (value) {
    return _then(_self.copyWith(campGoldCost: value));
  });
}/// Create a copy of GrowthConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GoldCostFormulaCopyWith<$Res> get bondGoldCost {
  
  return $GoldCostFormulaCopyWith<$Res>(_self.bondGoldCost, (value) {
    return _then(_self.copyWith(bondGoldCost: value));
  });
}
}


/// Adds pattern-matching-related methods to [GrowthConfig].
extension GrowthConfigPatterns on GrowthConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GrowthConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GrowthConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GrowthConfig value)  $default,){
final _that = this;
switch (_that) {
case _GrowthConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GrowthConfig value)?  $default,){
final _that = this;
switch (_that) {
case _GrowthConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<FocusKeyframe> focusKeyframes,  GoldCostFormula focusGoldCost,  List<CampKeyframe> campKeyframes,  GoldCostFormula campGoldCost,  List<FocusBoostStage> focusBoost,  int bondMaxLevel,  GoldCostFormula bondGoldCost)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GrowthConfig() when $default != null:
return $default(_that.focusKeyframes,_that.focusGoldCost,_that.campKeyframes,_that.campGoldCost,_that.focusBoost,_that.bondMaxLevel,_that.bondGoldCost);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<FocusKeyframe> focusKeyframes,  GoldCostFormula focusGoldCost,  List<CampKeyframe> campKeyframes,  GoldCostFormula campGoldCost,  List<FocusBoostStage> focusBoost,  int bondMaxLevel,  GoldCostFormula bondGoldCost)  $default,) {final _that = this;
switch (_that) {
case _GrowthConfig():
return $default(_that.focusKeyframes,_that.focusGoldCost,_that.campKeyframes,_that.campGoldCost,_that.focusBoost,_that.bondMaxLevel,_that.bondGoldCost);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<FocusKeyframe> focusKeyframes,  GoldCostFormula focusGoldCost,  List<CampKeyframe> campKeyframes,  GoldCostFormula campGoldCost,  List<FocusBoostStage> focusBoost,  int bondMaxLevel,  GoldCostFormula bondGoldCost)?  $default,) {final _that = this;
switch (_that) {
case _GrowthConfig() when $default != null:
return $default(_that.focusKeyframes,_that.focusGoldCost,_that.campKeyframes,_that.campGoldCost,_that.focusBoost,_that.bondMaxLevel,_that.bondGoldCost);case _:
  return null;

}
}

}

/// @nodoc


class _GrowthConfig implements GrowthConfig {
  const _GrowthConfig({required  List<FocusKeyframe> focusKeyframes, required this.focusGoldCost, required  List<CampKeyframe> campKeyframes, required this.campGoldCost, required  List<FocusBoostStage> focusBoost, required this.bondMaxLevel, required this.bondGoldCost}): _focusKeyframes = focusKeyframes,_campKeyframes = campKeyframes,_focusBoost = focusBoost;
  

 final  List<FocusKeyframe> _focusKeyframes;
@override List<FocusKeyframe> get focusKeyframes {
  if (_focusKeyframes is EqualUnmodifiableListView) return _focusKeyframes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_focusKeyframes);
}

@override final  GoldCostFormula focusGoldCost;
 final  List<CampKeyframe> _campKeyframes;
@override List<CampKeyframe> get campKeyframes {
  if (_campKeyframes is EqualUnmodifiableListView) return _campKeyframes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_campKeyframes);
}

@override final  GoldCostFormula campGoldCost;
 final  List<FocusBoostStage> _focusBoost;
@override List<FocusBoostStage> get focusBoost {
  if (_focusBoost is EqualUnmodifiableListView) return _focusBoost;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_focusBoost);
}

@override final  int bondMaxLevel;
@override final  GoldCostFormula bondGoldCost;

/// Create a copy of GrowthConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GrowthConfigCopyWith<_GrowthConfig> get copyWith => __$GrowthConfigCopyWithImpl<_GrowthConfig>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GrowthConfig&&const DeepCollectionEquality().equals(other.focusKeyframes, _focusKeyframes)&&(identical(other.focusGoldCost, focusGoldCost) || other.focusGoldCost == focusGoldCost)&&const DeepCollectionEquality().equals(other.campKeyframes, _campKeyframes)&&(identical(other.campGoldCost, campGoldCost) || other.campGoldCost == campGoldCost)&&const DeepCollectionEquality().equals(other.focusBoost, _focusBoost)&&(identical(other.bondMaxLevel, bondMaxLevel) || other.bondMaxLevel == bondMaxLevel)&&(identical(other.bondGoldCost, bondGoldCost) || other.bondGoldCost == bondGoldCost));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_focusKeyframes),focusGoldCost,const DeepCollectionEquality().hash(_campKeyframes),campGoldCost,const DeepCollectionEquality().hash(_focusBoost),bondMaxLevel,bondGoldCost);
}

@override
String toString() {
    return 'GrowthConfig(focusKeyframes: $focusKeyframes, focusGoldCost: $focusGoldCost, campKeyframes: $campKeyframes, campGoldCost: $campGoldCost, focusBoost: $focusBoost, bondMaxLevel: $bondMaxLevel, bondGoldCost: $bondGoldCost)';
}


}

/// @nodoc
abstract mixin class _$GrowthConfigCopyWith<$Res> implements $GrowthConfigCopyWith<$Res> {
  factory _$GrowthConfigCopyWith(_GrowthConfig value, $Res Function(_GrowthConfig) _then) = __$GrowthConfigCopyWithImpl;
@override @useResult
$Res call({
 List<FocusKeyframe> focusKeyframes, GoldCostFormula focusGoldCost, List<CampKeyframe> campKeyframes, GoldCostFormula campGoldCost, List<FocusBoostStage> focusBoost, int bondMaxLevel, GoldCostFormula bondGoldCost
});


@override $GoldCostFormulaCopyWith<$Res> get focusGoldCost;@override $GoldCostFormulaCopyWith<$Res> get campGoldCost;@override $GoldCostFormulaCopyWith<$Res> get bondGoldCost;

}
/// @nodoc
class __$GrowthConfigCopyWithImpl<$Res>
    implements _$GrowthConfigCopyWith<$Res> {
  __$GrowthConfigCopyWithImpl(this._self, this._then);

  final _GrowthConfig _self;
  final $Res Function(_GrowthConfig) _then;

/// Create a copy of GrowthConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? focusKeyframes = null,Object? focusGoldCost = null,Object? campKeyframes = null,Object? campGoldCost = null,Object? focusBoost = null,Object? bondMaxLevel = null,Object? bondGoldCost = null,}) {
  return _then(_GrowthConfig(
focusKeyframes: null == focusKeyframes ? _self._focusKeyframes : focusKeyframes // ignore: cast_nullable_to_non_nullable
as List<FocusKeyframe>,focusGoldCost: null == focusGoldCost ? _self.focusGoldCost : focusGoldCost // ignore: cast_nullable_to_non_nullable
as GoldCostFormula,campKeyframes: null == campKeyframes ? _self._campKeyframes : campKeyframes // ignore: cast_nullable_to_non_nullable
as List<CampKeyframe>,campGoldCost: null == campGoldCost ? _self.campGoldCost : campGoldCost // ignore: cast_nullable_to_non_nullable
as GoldCostFormula,focusBoost: null == focusBoost ? _self._focusBoost : focusBoost // ignore: cast_nullable_to_non_nullable
as List<FocusBoostStage>,bondMaxLevel: null == bondMaxLevel ? _self.bondMaxLevel : bondMaxLevel // ignore: cast_nullable_to_non_nullable
as int,bondGoldCost: null == bondGoldCost ? _self.bondGoldCost : bondGoldCost // ignore: cast_nullable_to_non_nullable
as GoldCostFormula,
  ));
}

/// Create a copy of GrowthConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GoldCostFormulaCopyWith<$Res> get focusGoldCost {
  
  return $GoldCostFormulaCopyWith<$Res>(_self.focusGoldCost, (value) {
    return _then(_self.copyWith(focusGoldCost: value));
  });
}/// Create a copy of GrowthConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GoldCostFormulaCopyWith<$Res> get campGoldCost {
  
  return $GoldCostFormulaCopyWith<$Res>(_self.campGoldCost, (value) {
    return _then(_self.copyWith(campGoldCost: value));
  });
}/// Create a copy of GrowthConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GoldCostFormulaCopyWith<$Res> get bondGoldCost {
  
  return $GoldCostFormulaCopyWith<$Res>(_self.bondGoldCost, (value) {
    return _then(_self.copyWith(bondGoldCost: value));
  });
}
}

// dart format on
