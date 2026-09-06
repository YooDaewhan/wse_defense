// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dungeon_def.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DropEntryDef {

 String get item; int get min; int get max; int get chancePct; bool get bonusDayOnly;
/// Create a copy of DropEntryDef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DropEntryDefCopyWith<DropEntryDef> get copyWith => _$DropEntryDefCopyWithImpl<DropEntryDef>(this as DropEntryDef, _$identity);

  /// Serializes this DropEntryDef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DropEntryDef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DropEntryDef&&(identical(other.item, _this.item) || other.item == _this.item)&&(identical(other.min, _this.min) || other.min == _this.min)&&(identical(other.max, _this.max) || other.max == _this.max)&&(identical(other.chancePct, _this.chancePct) || other.chancePct == _this.chancePct)&&(identical(other.bonusDayOnly, _this.bonusDayOnly) || other.bonusDayOnly == _this.bonusDayOnly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DropEntryDef;
  return Object.hash(runtimeType,_this.item,_this.min,_this.max,_this.chancePct,_this.bonusDayOnly);
}

@override
String toString() {
  final _this = this as DropEntryDef;
  return 'DropEntryDef(item: ${_this.item}, min: ${_this.min}, max: ${_this.max}, chancePct: ${_this.chancePct}, bonusDayOnly: ${_this.bonusDayOnly})';
}


}

/// @nodoc
abstract mixin class $DropEntryDefCopyWith<$Res>  {
  factory $DropEntryDefCopyWith(DropEntryDef value, $Res Function(DropEntryDef) _then) = _$DropEntryDefCopyWithImpl;
@useResult
$Res call({
 String item, int min, int max, int chancePct, bool bonusDayOnly
});




}
/// @nodoc
class _$DropEntryDefCopyWithImpl<$Res>
    implements $DropEntryDefCopyWith<$Res> {
  _$DropEntryDefCopyWithImpl(this._self, this._then);

  final DropEntryDef _self;
  final $Res Function(DropEntryDef) _then;

/// Create a copy of DropEntryDef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? item = null,Object? min = null,Object? max = null,Object? chancePct = null,Object? bonusDayOnly = null,}) {
  return _then(DropEntryDef(
item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as String,min: null == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as int,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as int,chancePct: null == chancePct ? _self.chancePct : chancePct // ignore: cast_nullable_to_non_nullable
as int,bonusDayOnly: null == bonusDayOnly ? _self.bonusDayOnly : bonusDayOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DropEntryDef].
extension DropEntryDefPatterns on DropEntryDef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DropEntryDef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DropEntryDef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DropEntryDef value)  $default,){
final _that = this;
switch (_that) {
case _DropEntryDef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DropEntryDef value)?  $default,){
final _that = this;
switch (_that) {
case _DropEntryDef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String item,  int min,  int max,  int chancePct,  bool bonusDayOnly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DropEntryDef() when $default != null:
return $default(_that.item,_that.min,_that.max,_that.chancePct,_that.bonusDayOnly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String item,  int min,  int max,  int chancePct,  bool bonusDayOnly)  $default,) {final _that = this;
switch (_that) {
case _DropEntryDef():
return $default(_that.item,_that.min,_that.max,_that.chancePct,_that.bonusDayOnly);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String item,  int min,  int max,  int chancePct,  bool bonusDayOnly)?  $default,) {final _that = this;
switch (_that) {
case _DropEntryDef() when $default != null:
return $default(_that.item,_that.min,_that.max,_that.chancePct,_that.bonusDayOnly);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DropEntryDef implements DropEntryDef {
  const _DropEntryDef({required this.item, required this.min, required this.max, this.chancePct = 100000, this.bonusDayOnly = false});
  factory _DropEntryDef.fromJson(Map<String, dynamic> json) => _$DropEntryDefFromJson(json);

@override final  String item;
@override final  int min;
@override final  int max;
@override@JsonKey() final  int chancePct;
@override@JsonKey() final  bool bonusDayOnly;

/// Create a copy of DropEntryDef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DropEntryDefCopyWith<_DropEntryDef> get copyWith => __$DropEntryDefCopyWithImpl<_DropEntryDef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DropEntryDefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DropEntryDef&&(identical(other.item, item) || other.item == item)&&(identical(other.min, min) || other.min == min)&&(identical(other.max, max) || other.max == max)&&(identical(other.chancePct, chancePct) || other.chancePct == chancePct)&&(identical(other.bonusDayOnly, bonusDayOnly) || other.bonusDayOnly == bonusDayOnly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,item,min,max,chancePct,bonusDayOnly);
}

@override
String toString() {
    return 'DropEntryDef(item: $item, min: $min, max: $max, chancePct: $chancePct, bonusDayOnly: $bonusDayOnly)';
}


}

/// @nodoc
abstract mixin class _$DropEntryDefCopyWith<$Res> implements $DropEntryDefCopyWith<$Res> {
  factory _$DropEntryDefCopyWith(_DropEntryDef value, $Res Function(_DropEntryDef) _then) = __$DropEntryDefCopyWithImpl;
@override @useResult
$Res call({
 String item, int min, int max, int chancePct, bool bonusDayOnly
});




}
/// @nodoc
class __$DropEntryDefCopyWithImpl<$Res>
    implements _$DropEntryDefCopyWith<$Res> {
  __$DropEntryDefCopyWithImpl(this._self, this._then);

  final _DropEntryDef _self;
  final $Res Function(_DropEntryDef) _then;

/// Create a copy of DropEntryDef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? item = null,Object? min = null,Object? max = null,Object? chancePct = null,Object? bonusDayOnly = null,}) {
  return _then(_DropEntryDef(
item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as String,min: null == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as int,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as int,chancePct: null == chancePct ? _self.chancePct : chancePct // ignore: cast_nullable_to_non_nullable
as int,bonusDayOnly: null == bonusDayOnly ? _self.bonusDayOnly : bonusDayOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$DungeonGimmickDef {

 String get kind; int get biasPerSample;
/// Create a copy of DungeonGimmickDef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DungeonGimmickDefCopyWith<DungeonGimmickDef> get copyWith => _$DungeonGimmickDefCopyWithImpl<DungeonGimmickDef>(this as DungeonGimmickDef, _$identity);

  /// Serializes this DungeonGimmickDef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DungeonGimmickDef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DungeonGimmickDef&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.biasPerSample, _this.biasPerSample) || other.biasPerSample == _this.biasPerSample));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DungeonGimmickDef;
  return Object.hash(runtimeType,_this.kind,_this.biasPerSample);
}

@override
String toString() {
  final _this = this as DungeonGimmickDef;
  return 'DungeonGimmickDef(kind: ${_this.kind}, biasPerSample: ${_this.biasPerSample})';
}


}

/// @nodoc
abstract mixin class $DungeonGimmickDefCopyWith<$Res>  {
  factory $DungeonGimmickDefCopyWith(DungeonGimmickDef value, $Res Function(DungeonGimmickDef) _then) = _$DungeonGimmickDefCopyWithImpl;
@useResult
$Res call({
 String kind, int biasPerSample
});




}
/// @nodoc
class _$DungeonGimmickDefCopyWithImpl<$Res>
    implements $DungeonGimmickDefCopyWith<$Res> {
  _$DungeonGimmickDefCopyWithImpl(this._self, this._then);

  final DungeonGimmickDef _self;
  final $Res Function(DungeonGimmickDef) _then;

/// Create a copy of DungeonGimmickDef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? biasPerSample = null,}) {
  return _then(DungeonGimmickDef(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,biasPerSample: null == biasPerSample ? _self.biasPerSample : biasPerSample // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DungeonGimmickDef].
extension DungeonGimmickDefPatterns on DungeonGimmickDef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DungeonGimmickDef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DungeonGimmickDef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DungeonGimmickDef value)  $default,){
final _that = this;
switch (_that) {
case _DungeonGimmickDef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DungeonGimmickDef value)?  $default,){
final _that = this;
switch (_that) {
case _DungeonGimmickDef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String kind,  int biasPerSample)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DungeonGimmickDef() when $default != null:
return $default(_that.kind,_that.biasPerSample);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String kind,  int biasPerSample)  $default,) {final _that = this;
switch (_that) {
case _DungeonGimmickDef():
return $default(_that.kind,_that.biasPerSample);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String kind,  int biasPerSample)?  $default,) {final _that = this;
switch (_that) {
case _DungeonGimmickDef() when $default != null:
return $default(_that.kind,_that.biasPerSample);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DungeonGimmickDef implements DungeonGimmickDef {
  const _DungeonGimmickDef({required this.kind, this.biasPerSample = 0});
  factory _DungeonGimmickDef.fromJson(Map<String, dynamic> json) => _$DungeonGimmickDefFromJson(json);

@override final  String kind;
@override@JsonKey() final  int biasPerSample;

/// Create a copy of DungeonGimmickDef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DungeonGimmickDefCopyWith<_DungeonGimmickDef> get copyWith => __$DungeonGimmickDefCopyWithImpl<_DungeonGimmickDef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DungeonGimmickDefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DungeonGimmickDef&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.biasPerSample, biasPerSample) || other.biasPerSample == biasPerSample));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,kind,biasPerSample);
}

@override
String toString() {
    return 'DungeonGimmickDef(kind: $kind, biasPerSample: $biasPerSample)';
}


}

/// @nodoc
abstract mixin class _$DungeonGimmickDefCopyWith<$Res> implements $DungeonGimmickDefCopyWith<$Res> {
  factory _$DungeonGimmickDefCopyWith(_DungeonGimmickDef value, $Res Function(_DungeonGimmickDef) _then) = __$DungeonGimmickDefCopyWithImpl;
@override @useResult
$Res call({
 String kind, int biasPerSample
});




}
/// @nodoc
class __$DungeonGimmickDefCopyWithImpl<$Res>
    implements _$DungeonGimmickDefCopyWith<$Res> {
  __$DungeonGimmickDefCopyWithImpl(this._self, this._then);

  final _DungeonGimmickDef _self;
  final $Res Function(_DungeonGimmickDef) _then;

/// Create a copy of DungeonGimmickDef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? biasPerSample = null,}) {
  return _then(_DungeonGimmickDef(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,biasPerSample: null == biasPerSample ? _self.biasPerSample : biasPerSample // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$DungeonUnlockDef {

 String? get stageCleared; int? get difficultyCleared; String? get chapterCleared;
/// Create a copy of DungeonUnlockDef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DungeonUnlockDefCopyWith<DungeonUnlockDef> get copyWith => _$DungeonUnlockDefCopyWithImpl<DungeonUnlockDef>(this as DungeonUnlockDef, _$identity);

  /// Serializes this DungeonUnlockDef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DungeonUnlockDef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DungeonUnlockDef&&(identical(other.stageCleared, _this.stageCleared) || other.stageCleared == _this.stageCleared)&&(identical(other.difficultyCleared, _this.difficultyCleared) || other.difficultyCleared == _this.difficultyCleared)&&(identical(other.chapterCleared, _this.chapterCleared) || other.chapterCleared == _this.chapterCleared));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DungeonUnlockDef;
  return Object.hash(runtimeType,_this.stageCleared,_this.difficultyCleared,_this.chapterCleared);
}

@override
String toString() {
  final _this = this as DungeonUnlockDef;
  return 'DungeonUnlockDef(stageCleared: ${_this.stageCleared}, difficultyCleared: ${_this.difficultyCleared}, chapterCleared: ${_this.chapterCleared})';
}


}

/// @nodoc
abstract mixin class $DungeonUnlockDefCopyWith<$Res>  {
  factory $DungeonUnlockDefCopyWith(DungeonUnlockDef value, $Res Function(DungeonUnlockDef) _then) = _$DungeonUnlockDefCopyWithImpl;
@useResult
$Res call({
 String? stageCleared, int? difficultyCleared, String? chapterCleared
});




}
/// @nodoc
class _$DungeonUnlockDefCopyWithImpl<$Res>
    implements $DungeonUnlockDefCopyWith<$Res> {
  _$DungeonUnlockDefCopyWithImpl(this._self, this._then);

  final DungeonUnlockDef _self;
  final $Res Function(DungeonUnlockDef) _then;

/// Create a copy of DungeonUnlockDef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stageCleared = freezed,Object? difficultyCleared = freezed,Object? chapterCleared = freezed,}) {
  return _then(DungeonUnlockDef(
stageCleared: freezed == stageCleared ? _self.stageCleared : stageCleared // ignore: cast_nullable_to_non_nullable
as String?,difficultyCleared: freezed == difficultyCleared ? _self.difficultyCleared : difficultyCleared // ignore: cast_nullable_to_non_nullable
as int?,chapterCleared: freezed == chapterCleared ? _self.chapterCleared : chapterCleared // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DungeonUnlockDef].
extension DungeonUnlockDefPatterns on DungeonUnlockDef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DungeonUnlockDef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DungeonUnlockDef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DungeonUnlockDef value)  $default,){
final _that = this;
switch (_that) {
case _DungeonUnlockDef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DungeonUnlockDef value)?  $default,){
final _that = this;
switch (_that) {
case _DungeonUnlockDef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? stageCleared,  int? difficultyCleared,  String? chapterCleared)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DungeonUnlockDef() when $default != null:
return $default(_that.stageCleared,_that.difficultyCleared,_that.chapterCleared);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? stageCleared,  int? difficultyCleared,  String? chapterCleared)  $default,) {final _that = this;
switch (_that) {
case _DungeonUnlockDef():
return $default(_that.stageCleared,_that.difficultyCleared,_that.chapterCleared);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? stageCleared,  int? difficultyCleared,  String? chapterCleared)?  $default,) {final _that = this;
switch (_that) {
case _DungeonUnlockDef() when $default != null:
return $default(_that.stageCleared,_that.difficultyCleared,_that.chapterCleared);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DungeonUnlockDef implements DungeonUnlockDef {
  const _DungeonUnlockDef({this.stageCleared, this.difficultyCleared, this.chapterCleared});
  factory _DungeonUnlockDef.fromJson(Map<String, dynamic> json) => _$DungeonUnlockDefFromJson(json);

@override final  String? stageCleared;
@override final  int? difficultyCleared;
@override final  String? chapterCleared;

/// Create a copy of DungeonUnlockDef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DungeonUnlockDefCopyWith<_DungeonUnlockDef> get copyWith => __$DungeonUnlockDefCopyWithImpl<_DungeonUnlockDef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DungeonUnlockDefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DungeonUnlockDef&&(identical(other.stageCleared, stageCleared) || other.stageCleared == stageCleared)&&(identical(other.difficultyCleared, difficultyCleared) || other.difficultyCleared == difficultyCleared)&&(identical(other.chapterCleared, chapterCleared) || other.chapterCleared == chapterCleared));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,stageCleared,difficultyCleared,chapterCleared);
}

@override
String toString() {
    return 'DungeonUnlockDef(stageCleared: $stageCleared, difficultyCleared: $difficultyCleared, chapterCleared: $chapterCleared)';
}


}

/// @nodoc
abstract mixin class _$DungeonUnlockDefCopyWith<$Res> implements $DungeonUnlockDefCopyWith<$Res> {
  factory _$DungeonUnlockDefCopyWith(_DungeonUnlockDef value, $Res Function(_DungeonUnlockDef) _then) = __$DungeonUnlockDefCopyWithImpl;
@override @useResult
$Res call({
 String? stageCleared, int? difficultyCleared, String? chapterCleared
});




}
/// @nodoc
class __$DungeonUnlockDefCopyWithImpl<$Res>
    implements _$DungeonUnlockDefCopyWith<$Res> {
  __$DungeonUnlockDefCopyWithImpl(this._self, this._then);

  final _DungeonUnlockDef _self;
  final $Res Function(_DungeonUnlockDef) _then;

/// Create a copy of DungeonUnlockDef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stageCleared = freezed,Object? difficultyCleared = freezed,Object? chapterCleared = freezed,}) {
  return _then(_DungeonUnlockDef(
stageCleared: freezed == stageCleared ? _self.stageCleared : stageCleared // ignore: cast_nullable_to_non_nullable
as String?,difficultyCleared: freezed == difficultyCleared ? _self.difficultyCleared : difficultyCleared // ignore: cast_nullable_to_non_nullable
as int?,chapterCleared: freezed == chapterCleared ? _self.chapterCleared : chapterCleared // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DungeonDifficultyDef {

 int get level; String get stageId; DungeonUnlockDef? get unlock; int get recommendedBondLevel; DungeonGimmickDef? get gimmick; bool get hasMiniBoss; List<DropEntryDef> get drops;
/// Create a copy of DungeonDifficultyDef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DungeonDifficultyDefCopyWith<DungeonDifficultyDef> get copyWith => _$DungeonDifficultyDefCopyWithImpl<DungeonDifficultyDef>(this as DungeonDifficultyDef, _$identity);

  /// Serializes this DungeonDifficultyDef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DungeonDifficultyDef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DungeonDifficultyDef&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.stageId, _this.stageId) || other.stageId == _this.stageId)&&(identical(other.unlock, _this.unlock) || other.unlock == _this.unlock)&&(identical(other.recommendedBondLevel, _this.recommendedBondLevel) || other.recommendedBondLevel == _this.recommendedBondLevel)&&(identical(other.gimmick, _this.gimmick) || other.gimmick == _this.gimmick)&&(identical(other.hasMiniBoss, _this.hasMiniBoss) || other.hasMiniBoss == _this.hasMiniBoss)&&const DeepCollectionEquality().equals(other.drops, _this.drops));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DungeonDifficultyDef;
  return Object.hash(runtimeType,_this.level,_this.stageId,_this.unlock,_this.recommendedBondLevel,_this.gimmick,_this.hasMiniBoss,const DeepCollectionEquality().hash(_this.drops));
}

@override
String toString() {
  final _this = this as DungeonDifficultyDef;
  return 'DungeonDifficultyDef(level: ${_this.level}, stageId: ${_this.stageId}, unlock: ${_this.unlock}, recommendedBondLevel: ${_this.recommendedBondLevel}, gimmick: ${_this.gimmick}, hasMiniBoss: ${_this.hasMiniBoss}, drops: ${_this.drops})';
}


}

/// @nodoc
abstract mixin class $DungeonDifficultyDefCopyWith<$Res>  {
  factory $DungeonDifficultyDefCopyWith(DungeonDifficultyDef value, $Res Function(DungeonDifficultyDef) _then) = _$DungeonDifficultyDefCopyWithImpl;
@useResult
$Res call({
 int level, String stageId, DungeonUnlockDef? unlock, int recommendedBondLevel, DungeonGimmickDef? gimmick, bool hasMiniBoss, List<DropEntryDef> drops
});


$DungeonUnlockDefCopyWith<$Res>? get unlock;$DungeonGimmickDefCopyWith<$Res>? get gimmick;

}
/// @nodoc
class _$DungeonDifficultyDefCopyWithImpl<$Res>
    implements $DungeonDifficultyDefCopyWith<$Res> {
  _$DungeonDifficultyDefCopyWithImpl(this._self, this._then);

  final DungeonDifficultyDef _self;
  final $Res Function(DungeonDifficultyDef) _then;

/// Create a copy of DungeonDifficultyDef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? level = null,Object? stageId = null,Object? unlock = freezed,Object? recommendedBondLevel = null,Object? gimmick = freezed,Object? hasMiniBoss = null,Object? drops = null,}) {
  return _then(DungeonDifficultyDef(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,stageId: null == stageId ? _self.stageId : stageId // ignore: cast_nullable_to_non_nullable
as String,unlock: freezed == unlock ? _self.unlock : unlock // ignore: cast_nullable_to_non_nullable
as DungeonUnlockDef?,recommendedBondLevel: null == recommendedBondLevel ? _self.recommendedBondLevel : recommendedBondLevel // ignore: cast_nullable_to_non_nullable
as int,gimmick: freezed == gimmick ? _self.gimmick : gimmick // ignore: cast_nullable_to_non_nullable
as DungeonGimmickDef?,hasMiniBoss: null == hasMiniBoss ? _self.hasMiniBoss : hasMiniBoss // ignore: cast_nullable_to_non_nullable
as bool,drops: null == drops ? _self.drops : drops // ignore: cast_nullable_to_non_nullable
as List<DropEntryDef>,
  ));
}
/// Create a copy of DungeonDifficultyDef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DungeonUnlockDefCopyWith<$Res>? get unlock {
    if (_self.unlock == null) {
    return null;
  }

  return $DungeonUnlockDefCopyWith<$Res>(_self.unlock!, (value) {
    return _then(_self.copyWith(unlock: value));
  });
}/// Create a copy of DungeonDifficultyDef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DungeonGimmickDefCopyWith<$Res>? get gimmick {
    if (_self.gimmick == null) {
    return null;
  }

  return $DungeonGimmickDefCopyWith<$Res>(_self.gimmick!, (value) {
    return _then(_self.copyWith(gimmick: value));
  });
}
}


/// Adds pattern-matching-related methods to [DungeonDifficultyDef].
extension DungeonDifficultyDefPatterns on DungeonDifficultyDef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DungeonDifficultyDef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DungeonDifficultyDef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DungeonDifficultyDef value)  $default,){
final _that = this;
switch (_that) {
case _DungeonDifficultyDef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DungeonDifficultyDef value)?  $default,){
final _that = this;
switch (_that) {
case _DungeonDifficultyDef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int level,  String stageId,  DungeonUnlockDef? unlock,  int recommendedBondLevel,  DungeonGimmickDef? gimmick,  bool hasMiniBoss,  List<DropEntryDef> drops)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DungeonDifficultyDef() when $default != null:
return $default(_that.level,_that.stageId,_that.unlock,_that.recommendedBondLevel,_that.gimmick,_that.hasMiniBoss,_that.drops);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int level,  String stageId,  DungeonUnlockDef? unlock,  int recommendedBondLevel,  DungeonGimmickDef? gimmick,  bool hasMiniBoss,  List<DropEntryDef> drops)  $default,) {final _that = this;
switch (_that) {
case _DungeonDifficultyDef():
return $default(_that.level,_that.stageId,_that.unlock,_that.recommendedBondLevel,_that.gimmick,_that.hasMiniBoss,_that.drops);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int level,  String stageId,  DungeonUnlockDef? unlock,  int recommendedBondLevel,  DungeonGimmickDef? gimmick,  bool hasMiniBoss,  List<DropEntryDef> drops)?  $default,) {final _that = this;
switch (_that) {
case _DungeonDifficultyDef() when $default != null:
return $default(_that.level,_that.stageId,_that.unlock,_that.recommendedBondLevel,_that.gimmick,_that.hasMiniBoss,_that.drops);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DungeonDifficultyDef implements DungeonDifficultyDef {
  const _DungeonDifficultyDef({required this.level, required this.stageId, this.unlock, this.recommendedBondLevel = 0, this.gimmick, this.hasMiniBoss = false,  List<DropEntryDef> drops = const <DropEntryDef>[]}): _drops = drops;
  factory _DungeonDifficultyDef.fromJson(Map<String, dynamic> json) => _$DungeonDifficultyDefFromJson(json);

@override final  int level;
@override final  String stageId;
@override final  DungeonUnlockDef? unlock;
@override@JsonKey() final  int recommendedBondLevel;
@override final  DungeonGimmickDef? gimmick;
@override@JsonKey() final  bool hasMiniBoss;
 final  List<DropEntryDef> _drops;
@override@JsonKey() List<DropEntryDef> get drops {
  if (_drops is EqualUnmodifiableListView) return _drops;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_drops);
}


/// Create a copy of DungeonDifficultyDef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DungeonDifficultyDefCopyWith<_DungeonDifficultyDef> get copyWith => __$DungeonDifficultyDefCopyWithImpl<_DungeonDifficultyDef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DungeonDifficultyDefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DungeonDifficultyDef&&(identical(other.level, level) || other.level == level)&&(identical(other.stageId, stageId) || other.stageId == stageId)&&(identical(other.unlock, unlock) || other.unlock == unlock)&&(identical(other.recommendedBondLevel, recommendedBondLevel) || other.recommendedBondLevel == recommendedBondLevel)&&(identical(other.gimmick, gimmick) || other.gimmick == gimmick)&&(identical(other.hasMiniBoss, hasMiniBoss) || other.hasMiniBoss == hasMiniBoss)&&const DeepCollectionEquality().equals(other.drops, _drops));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,level,stageId,unlock,recommendedBondLevel,gimmick,hasMiniBoss,const DeepCollectionEquality().hash(_drops));
}

@override
String toString() {
    return 'DungeonDifficultyDef(level: $level, stageId: $stageId, unlock: $unlock, recommendedBondLevel: $recommendedBondLevel, gimmick: $gimmick, hasMiniBoss: $hasMiniBoss, drops: $drops)';
}


}

/// @nodoc
abstract mixin class _$DungeonDifficultyDefCopyWith<$Res> implements $DungeonDifficultyDefCopyWith<$Res> {
  factory _$DungeonDifficultyDefCopyWith(_DungeonDifficultyDef value, $Res Function(_DungeonDifficultyDef) _then) = __$DungeonDifficultyDefCopyWithImpl;
@override @useResult
$Res call({
 int level, String stageId, DungeonUnlockDef? unlock, int recommendedBondLevel, DungeonGimmickDef? gimmick, bool hasMiniBoss, List<DropEntryDef> drops
});


@override $DungeonUnlockDefCopyWith<$Res>? get unlock;@override $DungeonGimmickDefCopyWith<$Res>? get gimmick;

}
/// @nodoc
class __$DungeonDifficultyDefCopyWithImpl<$Res>
    implements _$DungeonDifficultyDefCopyWith<$Res> {
  __$DungeonDifficultyDefCopyWithImpl(this._self, this._then);

  final _DungeonDifficultyDef _self;
  final $Res Function(_DungeonDifficultyDef) _then;

/// Create a copy of DungeonDifficultyDef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? level = null,Object? stageId = null,Object? unlock = freezed,Object? recommendedBondLevel = null,Object? gimmick = freezed,Object? hasMiniBoss = null,Object? drops = null,}) {
  return _then(_DungeonDifficultyDef(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,stageId: null == stageId ? _self.stageId : stageId // ignore: cast_nullable_to_non_nullable
as String,unlock: freezed == unlock ? _self.unlock : unlock // ignore: cast_nullable_to_non_nullable
as DungeonUnlockDef?,recommendedBondLevel: null == recommendedBondLevel ? _self.recommendedBondLevel : recommendedBondLevel // ignore: cast_nullable_to_non_nullable
as int,gimmick: freezed == gimmick ? _self.gimmick : gimmick // ignore: cast_nullable_to_non_nullable
as DungeonGimmickDef?,hasMiniBoss: null == hasMiniBoss ? _self.hasMiniBoss : hasMiniBoss // ignore: cast_nullable_to_non_nullable
as bool,drops: null == drops ? _self._drops : drops // ignore: cast_nullable_to_non_nullable
as List<DropEntryDef>,
  ));
}

/// Create a copy of DungeonDifficultyDef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DungeonUnlockDefCopyWith<$Res>? get unlock {
    if (_self.unlock == null) {
    return null;
  }

  return $DungeonUnlockDefCopyWith<$Res>(_self.unlock!, (value) {
    return _then(_self.copyWith(unlock: value));
  });
}/// Create a copy of DungeonDifficultyDef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DungeonGimmickDefCopyWith<$Res>? get gimmick {
    if (_self.gimmick == null) {
    return null;
  }

  return $DungeonGimmickDefCopyWith<$Res>(_self.gimmick!, (value) {
    return _then(_self.copyWith(gimmick: value));
  });
}
}


/// @nodoc
mixin _$DungeonDef {

 String get id; String get nameKey; String get themeKey; List<int> get bonusWeekdays; String get shardFamily; List<DungeonDifficultyDef> get difficulties;
/// Create a copy of DungeonDef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DungeonDefCopyWith<DungeonDef> get copyWith => _$DungeonDefCopyWithImpl<DungeonDef>(this as DungeonDef, _$identity);

  /// Serializes this DungeonDef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DungeonDef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DungeonDef&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.nameKey, _this.nameKey) || other.nameKey == _this.nameKey)&&(identical(other.themeKey, _this.themeKey) || other.themeKey == _this.themeKey)&&const DeepCollectionEquality().equals(other.bonusWeekdays, _this.bonusWeekdays)&&(identical(other.shardFamily, _this.shardFamily) || other.shardFamily == _this.shardFamily)&&const DeepCollectionEquality().equals(other.difficulties, _this.difficulties));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DungeonDef;
  return Object.hash(runtimeType,_this.id,_this.nameKey,_this.themeKey,const DeepCollectionEquality().hash(_this.bonusWeekdays),_this.shardFamily,const DeepCollectionEquality().hash(_this.difficulties));
}

@override
String toString() {
  final _this = this as DungeonDef;
  return 'DungeonDef(id: ${_this.id}, nameKey: ${_this.nameKey}, themeKey: ${_this.themeKey}, bonusWeekdays: ${_this.bonusWeekdays}, shardFamily: ${_this.shardFamily}, difficulties: ${_this.difficulties})';
}


}

/// @nodoc
abstract mixin class $DungeonDefCopyWith<$Res>  {
  factory $DungeonDefCopyWith(DungeonDef value, $Res Function(DungeonDef) _then) = _$DungeonDefCopyWithImpl;
@useResult
$Res call({
 String id, String nameKey, String themeKey, List<int> bonusWeekdays, String shardFamily, List<DungeonDifficultyDef> difficulties
});




}
/// @nodoc
class _$DungeonDefCopyWithImpl<$Res>
    implements $DungeonDefCopyWith<$Res> {
  _$DungeonDefCopyWithImpl(this._self, this._then);

  final DungeonDef _self;
  final $Res Function(DungeonDef) _then;

/// Create a copy of DungeonDef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nameKey = null,Object? themeKey = null,Object? bonusWeekdays = null,Object? shardFamily = null,Object? difficulties = null,}) {
  return _then(DungeonDef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameKey: null == nameKey ? _self.nameKey : nameKey // ignore: cast_nullable_to_non_nullable
as String,themeKey: null == themeKey ? _self.themeKey : themeKey // ignore: cast_nullable_to_non_nullable
as String,bonusWeekdays: null == bonusWeekdays ? _self.bonusWeekdays : bonusWeekdays // ignore: cast_nullable_to_non_nullable
as List<int>,shardFamily: null == shardFamily ? _self.shardFamily : shardFamily // ignore: cast_nullable_to_non_nullable
as String,difficulties: null == difficulties ? _self.difficulties : difficulties // ignore: cast_nullable_to_non_nullable
as List<DungeonDifficultyDef>,
  ));
}

}


/// Adds pattern-matching-related methods to [DungeonDef].
extension DungeonDefPatterns on DungeonDef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DungeonDef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DungeonDef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DungeonDef value)  $default,){
final _that = this;
switch (_that) {
case _DungeonDef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DungeonDef value)?  $default,){
final _that = this;
switch (_that) {
case _DungeonDef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nameKey,  String themeKey,  List<int> bonusWeekdays,  String shardFamily,  List<DungeonDifficultyDef> difficulties)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DungeonDef() when $default != null:
return $default(_that.id,_that.nameKey,_that.themeKey,_that.bonusWeekdays,_that.shardFamily,_that.difficulties);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nameKey,  String themeKey,  List<int> bonusWeekdays,  String shardFamily,  List<DungeonDifficultyDef> difficulties)  $default,) {final _that = this;
switch (_that) {
case _DungeonDef():
return $default(_that.id,_that.nameKey,_that.themeKey,_that.bonusWeekdays,_that.shardFamily,_that.difficulties);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nameKey,  String themeKey,  List<int> bonusWeekdays,  String shardFamily,  List<DungeonDifficultyDef> difficulties)?  $default,) {final _that = this;
switch (_that) {
case _DungeonDef() when $default != null:
return $default(_that.id,_that.nameKey,_that.themeKey,_that.bonusWeekdays,_that.shardFamily,_that.difficulties);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DungeonDef implements DungeonDef {
  const _DungeonDef({required this.id, required this.nameKey, required this.themeKey,  List<int> bonusWeekdays = const <int>[], required this.shardFamily,  List<DungeonDifficultyDef> difficulties = const <DungeonDifficultyDef>[]}): _bonusWeekdays = bonusWeekdays,_difficulties = difficulties;
  factory _DungeonDef.fromJson(Map<String, dynamic> json) => _$DungeonDefFromJson(json);

@override final  String id;
@override final  String nameKey;
@override final  String themeKey;
 final  List<int> _bonusWeekdays;
@override@JsonKey() List<int> get bonusWeekdays {
  if (_bonusWeekdays is EqualUnmodifiableListView) return _bonusWeekdays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bonusWeekdays);
}

@override final  String shardFamily;
 final  List<DungeonDifficultyDef> _difficulties;
@override@JsonKey() List<DungeonDifficultyDef> get difficulties {
  if (_difficulties is EqualUnmodifiableListView) return _difficulties;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_difficulties);
}


/// Create a copy of DungeonDef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DungeonDefCopyWith<_DungeonDef> get copyWith => __$DungeonDefCopyWithImpl<_DungeonDef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DungeonDefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DungeonDef&&(identical(other.id, id) || other.id == id)&&(identical(other.nameKey, nameKey) || other.nameKey == nameKey)&&(identical(other.themeKey, themeKey) || other.themeKey == themeKey)&&const DeepCollectionEquality().equals(other.bonusWeekdays, _bonusWeekdays)&&(identical(other.shardFamily, shardFamily) || other.shardFamily == shardFamily)&&const DeepCollectionEquality().equals(other.difficulties, _difficulties));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,nameKey,themeKey,const DeepCollectionEquality().hash(_bonusWeekdays),shardFamily,const DeepCollectionEquality().hash(_difficulties));
}

@override
String toString() {
    return 'DungeonDef(id: $id, nameKey: $nameKey, themeKey: $themeKey, bonusWeekdays: $bonusWeekdays, shardFamily: $shardFamily, difficulties: $difficulties)';
}


}

/// @nodoc
abstract mixin class _$DungeonDefCopyWith<$Res> implements $DungeonDefCopyWith<$Res> {
  factory _$DungeonDefCopyWith(_DungeonDef value, $Res Function(_DungeonDef) _then) = __$DungeonDefCopyWithImpl;
@override @useResult
$Res call({
 String id, String nameKey, String themeKey, List<int> bonusWeekdays, String shardFamily, List<DungeonDifficultyDef> difficulties
});




}
/// @nodoc
class __$DungeonDefCopyWithImpl<$Res>
    implements _$DungeonDefCopyWith<$Res> {
  __$DungeonDefCopyWithImpl(this._self, this._then);

  final _DungeonDef _self;
  final $Res Function(_DungeonDef) _then;

/// Create a copy of DungeonDef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nameKey = null,Object? themeKey = null,Object? bonusWeekdays = null,Object? shardFamily = null,Object? difficulties = null,}) {
  return _then(_DungeonDef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameKey: null == nameKey ? _self.nameKey : nameKey // ignore: cast_nullable_to_non_nullable
as String,themeKey: null == themeKey ? _self.themeKey : themeKey // ignore: cast_nullable_to_non_nullable
as String,bonusWeekdays: null == bonusWeekdays ? _self._bonusWeekdays : bonusWeekdays // ignore: cast_nullable_to_non_nullable
as List<int>,shardFamily: null == shardFamily ? _self.shardFamily : shardFamily // ignore: cast_nullable_to_non_nullable
as String,difficulties: null == difficulties ? _self._difficulties : difficulties // ignore: cast_nullable_to_non_nullable
as List<DungeonDifficultyDef>,
  ));
}


}


/// @nodoc
mixin _$DungeonConfig {

 int get dailyRunLimit; bool get sweepConsumesRun; bool get sweepRequiresClear; List<DungeonDef> get dungeons;
/// Create a copy of DungeonConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DungeonConfigCopyWith<DungeonConfig> get copyWith => _$DungeonConfigCopyWithImpl<DungeonConfig>(this as DungeonConfig, _$identity);

  /// Serializes this DungeonConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DungeonConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DungeonConfig&&(identical(other.dailyRunLimit, _this.dailyRunLimit) || other.dailyRunLimit == _this.dailyRunLimit)&&(identical(other.sweepConsumesRun, _this.sweepConsumesRun) || other.sweepConsumesRun == _this.sweepConsumesRun)&&(identical(other.sweepRequiresClear, _this.sweepRequiresClear) || other.sweepRequiresClear == _this.sweepRequiresClear)&&const DeepCollectionEquality().equals(other.dungeons, _this.dungeons));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DungeonConfig;
  return Object.hash(runtimeType,_this.dailyRunLimit,_this.sweepConsumesRun,_this.sweepRequiresClear,const DeepCollectionEquality().hash(_this.dungeons));
}

@override
String toString() {
  final _this = this as DungeonConfig;
  return 'DungeonConfig(dailyRunLimit: ${_this.dailyRunLimit}, sweepConsumesRun: ${_this.sweepConsumesRun}, sweepRequiresClear: ${_this.sweepRequiresClear}, dungeons: ${_this.dungeons})';
}


}

/// @nodoc
abstract mixin class $DungeonConfigCopyWith<$Res>  {
  factory $DungeonConfigCopyWith(DungeonConfig value, $Res Function(DungeonConfig) _then) = _$DungeonConfigCopyWithImpl;
@useResult
$Res call({
 int dailyRunLimit, bool sweepConsumesRun, bool sweepRequiresClear, List<DungeonDef> dungeons
});




}
/// @nodoc
class _$DungeonConfigCopyWithImpl<$Res>
    implements $DungeonConfigCopyWith<$Res> {
  _$DungeonConfigCopyWithImpl(this._self, this._then);

  final DungeonConfig _self;
  final $Res Function(DungeonConfig) _then;

/// Create a copy of DungeonConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dailyRunLimit = null,Object? sweepConsumesRun = null,Object? sweepRequiresClear = null,Object? dungeons = null,}) {
  return _then(DungeonConfig(
dailyRunLimit: null == dailyRunLimit ? _self.dailyRunLimit : dailyRunLimit // ignore: cast_nullable_to_non_nullable
as int,sweepConsumesRun: null == sweepConsumesRun ? _self.sweepConsumesRun : sweepConsumesRun // ignore: cast_nullable_to_non_nullable
as bool,sweepRequiresClear: null == sweepRequiresClear ? _self.sweepRequiresClear : sweepRequiresClear // ignore: cast_nullable_to_non_nullable
as bool,dungeons: null == dungeons ? _self.dungeons : dungeons // ignore: cast_nullable_to_non_nullable
as List<DungeonDef>,
  ));
}

}


/// Adds pattern-matching-related methods to [DungeonConfig].
extension DungeonConfigPatterns on DungeonConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DungeonConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DungeonConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DungeonConfig value)  $default,){
final _that = this;
switch (_that) {
case _DungeonConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DungeonConfig value)?  $default,){
final _that = this;
switch (_that) {
case _DungeonConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int dailyRunLimit,  bool sweepConsumesRun,  bool sweepRequiresClear,  List<DungeonDef> dungeons)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DungeonConfig() when $default != null:
return $default(_that.dailyRunLimit,_that.sweepConsumesRun,_that.sweepRequiresClear,_that.dungeons);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int dailyRunLimit,  bool sweepConsumesRun,  bool sweepRequiresClear,  List<DungeonDef> dungeons)  $default,) {final _that = this;
switch (_that) {
case _DungeonConfig():
return $default(_that.dailyRunLimit,_that.sweepConsumesRun,_that.sweepRequiresClear,_that.dungeons);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int dailyRunLimit,  bool sweepConsumesRun,  bool sweepRequiresClear,  List<DungeonDef> dungeons)?  $default,) {final _that = this;
switch (_that) {
case _DungeonConfig() when $default != null:
return $default(_that.dailyRunLimit,_that.sweepConsumesRun,_that.sweepRequiresClear,_that.dungeons);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DungeonConfig implements DungeonConfig {
  const _DungeonConfig({required this.dailyRunLimit, this.sweepConsumesRun = true, this.sweepRequiresClear = true,  List<DungeonDef> dungeons = const <DungeonDef>[]}): _dungeons = dungeons;
  factory _DungeonConfig.fromJson(Map<String, dynamic> json) => _$DungeonConfigFromJson(json);

@override final  int dailyRunLimit;
@override@JsonKey() final  bool sweepConsumesRun;
@override@JsonKey() final  bool sweepRequiresClear;
 final  List<DungeonDef> _dungeons;
@override@JsonKey() List<DungeonDef> get dungeons {
  if (_dungeons is EqualUnmodifiableListView) return _dungeons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dungeons);
}


/// Create a copy of DungeonConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DungeonConfigCopyWith<_DungeonConfig> get copyWith => __$DungeonConfigCopyWithImpl<_DungeonConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DungeonConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DungeonConfig&&(identical(other.dailyRunLimit, dailyRunLimit) || other.dailyRunLimit == dailyRunLimit)&&(identical(other.sweepConsumesRun, sweepConsumesRun) || other.sweepConsumesRun == sweepConsumesRun)&&(identical(other.sweepRequiresClear, sweepRequiresClear) || other.sweepRequiresClear == sweepRequiresClear)&&const DeepCollectionEquality().equals(other.dungeons, _dungeons));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,dailyRunLimit,sweepConsumesRun,sweepRequiresClear,const DeepCollectionEquality().hash(_dungeons));
}

@override
String toString() {
    return 'DungeonConfig(dailyRunLimit: $dailyRunLimit, sweepConsumesRun: $sweepConsumesRun, sweepRequiresClear: $sweepRequiresClear, dungeons: $dungeons)';
}


}

/// @nodoc
abstract mixin class _$DungeonConfigCopyWith<$Res> implements $DungeonConfigCopyWith<$Res> {
  factory _$DungeonConfigCopyWith(_DungeonConfig value, $Res Function(_DungeonConfig) _then) = __$DungeonConfigCopyWithImpl;
@override @useResult
$Res call({
 int dailyRunLimit, bool sweepConsumesRun, bool sweepRequiresClear, List<DungeonDef> dungeons
});




}
/// @nodoc
class __$DungeonConfigCopyWithImpl<$Res>
    implements _$DungeonConfigCopyWith<$Res> {
  __$DungeonConfigCopyWithImpl(this._self, this._then);

  final _DungeonConfig _self;
  final $Res Function(_DungeonConfig) _then;

/// Create a copy of DungeonConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dailyRunLimit = null,Object? sweepConsumesRun = null,Object? sweepRequiresClear = null,Object? dungeons = null,}) {
  return _then(_DungeonConfig(
dailyRunLimit: null == dailyRunLimit ? _self.dailyRunLimit : dailyRunLimit // ignore: cast_nullable_to_non_nullable
as int,sweepConsumesRun: null == sweepConsumesRun ? _self.sweepConsumesRun : sweepConsumesRun // ignore: cast_nullable_to_non_nullable
as bool,sweepRequiresClear: null == sweepRequiresClear ? _self.sweepRequiresClear : sweepRequiresClear // ignore: cast_nullable_to_non_nullable
as bool,dungeons: null == dungeons ? _self._dungeons : dungeons // ignore: cast_nullable_to_non_nullable
as List<DungeonDef>,
  ));
}


}

// dart format on
