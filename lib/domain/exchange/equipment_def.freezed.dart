// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'equipment_def.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EquipmentDef {

 String get id; String get nameKey; String get originDungeonId; String? get grantTagId; int get grantTagBaseLevel; bool get tagBonusAtEnhance5; String get baseModKey; num get baseModValue;
/// Create a copy of EquipmentDef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EquipmentDefCopyWith<EquipmentDef> get copyWith => _$EquipmentDefCopyWithImpl<EquipmentDef>(this as EquipmentDef, _$identity);

  /// Serializes this EquipmentDef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EquipmentDef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EquipmentDef&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.nameKey, _this.nameKey) || other.nameKey == _this.nameKey)&&(identical(other.originDungeonId, _this.originDungeonId) || other.originDungeonId == _this.originDungeonId)&&(identical(other.grantTagId, _this.grantTagId) || other.grantTagId == _this.grantTagId)&&(identical(other.grantTagBaseLevel, _this.grantTagBaseLevel) || other.grantTagBaseLevel == _this.grantTagBaseLevel)&&(identical(other.tagBonusAtEnhance5, _this.tagBonusAtEnhance5) || other.tagBonusAtEnhance5 == _this.tagBonusAtEnhance5)&&(identical(other.baseModKey, _this.baseModKey) || other.baseModKey == _this.baseModKey)&&(identical(other.baseModValue, _this.baseModValue) || other.baseModValue == _this.baseModValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EquipmentDef;
  return Object.hash(runtimeType,_this.id,_this.nameKey,_this.originDungeonId,_this.grantTagId,_this.grantTagBaseLevel,_this.tagBonusAtEnhance5,_this.baseModKey,_this.baseModValue);
}

@override
String toString() {
  final _this = this as EquipmentDef;
  return 'EquipmentDef(id: ${_this.id}, nameKey: ${_this.nameKey}, originDungeonId: ${_this.originDungeonId}, grantTagId: ${_this.grantTagId}, grantTagBaseLevel: ${_this.grantTagBaseLevel}, tagBonusAtEnhance5: ${_this.tagBonusAtEnhance5}, baseModKey: ${_this.baseModKey}, baseModValue: ${_this.baseModValue})';
}


}

/// @nodoc
abstract mixin class $EquipmentDefCopyWith<$Res>  {
  factory $EquipmentDefCopyWith(EquipmentDef value, $Res Function(EquipmentDef) _then) = _$EquipmentDefCopyWithImpl;
@useResult
$Res call({
 String id, String nameKey, String originDungeonId, String? grantTagId, int grantTagBaseLevel, bool tagBonusAtEnhance5, String baseModKey, num baseModValue
});




}
/// @nodoc
class _$EquipmentDefCopyWithImpl<$Res>
    implements $EquipmentDefCopyWith<$Res> {
  _$EquipmentDefCopyWithImpl(this._self, this._then);

  final EquipmentDef _self;
  final $Res Function(EquipmentDef) _then;

/// Create a copy of EquipmentDef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nameKey = null,Object? originDungeonId = null,Object? grantTagId = freezed,Object? grantTagBaseLevel = null,Object? tagBonusAtEnhance5 = null,Object? baseModKey = null,Object? baseModValue = null,}) {
  return _then(EquipmentDef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameKey: null == nameKey ? _self.nameKey : nameKey // ignore: cast_nullable_to_non_nullable
as String,originDungeonId: null == originDungeonId ? _self.originDungeonId : originDungeonId // ignore: cast_nullable_to_non_nullable
as String,grantTagId: freezed == grantTagId ? _self.grantTagId : grantTagId // ignore: cast_nullable_to_non_nullable
as String?,grantTagBaseLevel: null == grantTagBaseLevel ? _self.grantTagBaseLevel : grantTagBaseLevel // ignore: cast_nullable_to_non_nullable
as int,tagBonusAtEnhance5: null == tagBonusAtEnhance5 ? _self.tagBonusAtEnhance5 : tagBonusAtEnhance5 // ignore: cast_nullable_to_non_nullable
as bool,baseModKey: null == baseModKey ? _self.baseModKey : baseModKey // ignore: cast_nullable_to_non_nullable
as String,baseModValue: null == baseModValue ? _self.baseModValue : baseModValue // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [EquipmentDef].
extension EquipmentDefPatterns on EquipmentDef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EquipmentDef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EquipmentDef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EquipmentDef value)  $default,){
final _that = this;
switch (_that) {
case _EquipmentDef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EquipmentDef value)?  $default,){
final _that = this;
switch (_that) {
case _EquipmentDef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nameKey,  String originDungeonId,  String? grantTagId,  int grantTagBaseLevel,  bool tagBonusAtEnhance5,  String baseModKey,  num baseModValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EquipmentDef() when $default != null:
return $default(_that.id,_that.nameKey,_that.originDungeonId,_that.grantTagId,_that.grantTagBaseLevel,_that.tagBonusAtEnhance5,_that.baseModKey,_that.baseModValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nameKey,  String originDungeonId,  String? grantTagId,  int grantTagBaseLevel,  bool tagBonusAtEnhance5,  String baseModKey,  num baseModValue)  $default,) {final _that = this;
switch (_that) {
case _EquipmentDef():
return $default(_that.id,_that.nameKey,_that.originDungeonId,_that.grantTagId,_that.grantTagBaseLevel,_that.tagBonusAtEnhance5,_that.baseModKey,_that.baseModValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nameKey,  String originDungeonId,  String? grantTagId,  int grantTagBaseLevel,  bool tagBonusAtEnhance5,  String baseModKey,  num baseModValue)?  $default,) {final _that = this;
switch (_that) {
case _EquipmentDef() when $default != null:
return $default(_that.id,_that.nameKey,_that.originDungeonId,_that.grantTagId,_that.grantTagBaseLevel,_that.tagBonusAtEnhance5,_that.baseModKey,_that.baseModValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EquipmentDef implements EquipmentDef {
  const _EquipmentDef({required this.id, required this.nameKey, required this.originDungeonId, this.grantTagId, this.grantTagBaseLevel = 0, this.tagBonusAtEnhance5 = false, this.baseModKey = '', this.baseModValue = 0});
  factory _EquipmentDef.fromJson(Map<String, dynamic> json) => _$EquipmentDefFromJson(json);

@override final  String id;
@override final  String nameKey;
@override final  String originDungeonId;
@override final  String? grantTagId;
@override@JsonKey() final  int grantTagBaseLevel;
@override@JsonKey() final  bool tagBonusAtEnhance5;
@override@JsonKey() final  String baseModKey;
@override@JsonKey() final  num baseModValue;

/// Create a copy of EquipmentDef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EquipmentDefCopyWith<_EquipmentDef> get copyWith => __$EquipmentDefCopyWithImpl<_EquipmentDef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EquipmentDefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EquipmentDef&&(identical(other.id, id) || other.id == id)&&(identical(other.nameKey, nameKey) || other.nameKey == nameKey)&&(identical(other.originDungeonId, originDungeonId) || other.originDungeonId == originDungeonId)&&(identical(other.grantTagId, grantTagId) || other.grantTagId == grantTagId)&&(identical(other.grantTagBaseLevel, grantTagBaseLevel) || other.grantTagBaseLevel == grantTagBaseLevel)&&(identical(other.tagBonusAtEnhance5, tagBonusAtEnhance5) || other.tagBonusAtEnhance5 == tagBonusAtEnhance5)&&(identical(other.baseModKey, baseModKey) || other.baseModKey == baseModKey)&&(identical(other.baseModValue, baseModValue) || other.baseModValue == baseModValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,nameKey,originDungeonId,grantTagId,grantTagBaseLevel,tagBonusAtEnhance5,baseModKey,baseModValue);
}

@override
String toString() {
    return 'EquipmentDef(id: $id, nameKey: $nameKey, originDungeonId: $originDungeonId, grantTagId: $grantTagId, grantTagBaseLevel: $grantTagBaseLevel, tagBonusAtEnhance5: $tagBonusAtEnhance5, baseModKey: $baseModKey, baseModValue: $baseModValue)';
}


}

/// @nodoc
abstract mixin class _$EquipmentDefCopyWith<$Res> implements $EquipmentDefCopyWith<$Res> {
  factory _$EquipmentDefCopyWith(_EquipmentDef value, $Res Function(_EquipmentDef) _then) = __$EquipmentDefCopyWithImpl;
@override @useResult
$Res call({
 String id, String nameKey, String originDungeonId, String? grantTagId, int grantTagBaseLevel, bool tagBonusAtEnhance5, String baseModKey, num baseModValue
});




}
/// @nodoc
class __$EquipmentDefCopyWithImpl<$Res>
    implements _$EquipmentDefCopyWith<$Res> {
  __$EquipmentDefCopyWithImpl(this._self, this._then);

  final _EquipmentDef _self;
  final $Res Function(_EquipmentDef) _then;

/// Create a copy of EquipmentDef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nameKey = null,Object? originDungeonId = null,Object? grantTagId = freezed,Object? grantTagBaseLevel = null,Object? tagBonusAtEnhance5 = null,Object? baseModKey = null,Object? baseModValue = null,}) {
  return _then(_EquipmentDef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameKey: null == nameKey ? _self.nameKey : nameKey // ignore: cast_nullable_to_non_nullable
as String,originDungeonId: null == originDungeonId ? _self.originDungeonId : originDungeonId // ignore: cast_nullable_to_non_nullable
as String,grantTagId: freezed == grantTagId ? _self.grantTagId : grantTagId // ignore: cast_nullable_to_non_nullable
as String?,grantTagBaseLevel: null == grantTagBaseLevel ? _self.grantTagBaseLevel : grantTagBaseLevel // ignore: cast_nullable_to_non_nullable
as int,tagBonusAtEnhance5: null == tagBonusAtEnhance5 ? _self.tagBonusAtEnhance5 : tagBonusAtEnhance5 // ignore: cast_nullable_to_non_nullable
as bool,baseModKey: null == baseModKey ? _self.baseModKey : baseModKey // ignore: cast_nullable_to_non_nullable
as String,baseModValue: null == baseModValue ? _self.baseModValue : baseModValue // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}


/// @nodoc
mixin _$EquipmentCatalog {

 List<EquipmentDef> get equipments;
/// Create a copy of EquipmentCatalog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EquipmentCatalogCopyWith<EquipmentCatalog> get copyWith => _$EquipmentCatalogCopyWithImpl<EquipmentCatalog>(this as EquipmentCatalog, _$identity);

  /// Serializes this EquipmentCatalog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EquipmentCatalog;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EquipmentCatalog&&const DeepCollectionEquality().equals(other.equipments, _this.equipments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EquipmentCatalog;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.equipments));
}

@override
String toString() {
  final _this = this as EquipmentCatalog;
  return 'EquipmentCatalog(equipments: ${_this.equipments})';
}


}

/// @nodoc
abstract mixin class $EquipmentCatalogCopyWith<$Res>  {
  factory $EquipmentCatalogCopyWith(EquipmentCatalog value, $Res Function(EquipmentCatalog) _then) = _$EquipmentCatalogCopyWithImpl;
@useResult
$Res call({
 List<EquipmentDef> equipments
});




}
/// @nodoc
class _$EquipmentCatalogCopyWithImpl<$Res>
    implements $EquipmentCatalogCopyWith<$Res> {
  _$EquipmentCatalogCopyWithImpl(this._self, this._then);

  final EquipmentCatalog _self;
  final $Res Function(EquipmentCatalog) _then;

/// Create a copy of EquipmentCatalog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? equipments = null,}) {
  return _then(EquipmentCatalog(
equipments: null == equipments ? _self.equipments : equipments // ignore: cast_nullable_to_non_nullable
as List<EquipmentDef>,
  ));
}

}


/// Adds pattern-matching-related methods to [EquipmentCatalog].
extension EquipmentCatalogPatterns on EquipmentCatalog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EquipmentCatalog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EquipmentCatalog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EquipmentCatalog value)  $default,){
final _that = this;
switch (_that) {
case _EquipmentCatalog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EquipmentCatalog value)?  $default,){
final _that = this;
switch (_that) {
case _EquipmentCatalog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<EquipmentDef> equipments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EquipmentCatalog() when $default != null:
return $default(_that.equipments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<EquipmentDef> equipments)  $default,) {final _that = this;
switch (_that) {
case _EquipmentCatalog():
return $default(_that.equipments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<EquipmentDef> equipments)?  $default,) {final _that = this;
switch (_that) {
case _EquipmentCatalog() when $default != null:
return $default(_that.equipments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EquipmentCatalog implements EquipmentCatalog {
  const _EquipmentCatalog({ List<EquipmentDef> equipments = const <EquipmentDef>[]}): _equipments = equipments;
  factory _EquipmentCatalog.fromJson(Map<String, dynamic> json) => _$EquipmentCatalogFromJson(json);

 final  List<EquipmentDef> _equipments;
@override@JsonKey() List<EquipmentDef> get equipments {
  if (_equipments is EqualUnmodifiableListView) return _equipments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_equipments);
}


/// Create a copy of EquipmentCatalog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EquipmentCatalogCopyWith<_EquipmentCatalog> get copyWith => __$EquipmentCatalogCopyWithImpl<_EquipmentCatalog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EquipmentCatalogToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EquipmentCatalog&&const DeepCollectionEquality().equals(other.equipments, _equipments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_equipments));
}

@override
String toString() {
    return 'EquipmentCatalog(equipments: $equipments)';
}


}

/// @nodoc
abstract mixin class _$EquipmentCatalogCopyWith<$Res> implements $EquipmentCatalogCopyWith<$Res> {
  factory _$EquipmentCatalogCopyWith(_EquipmentCatalog value, $Res Function(_EquipmentCatalog) _then) = __$EquipmentCatalogCopyWithImpl;
@override @useResult
$Res call({
 List<EquipmentDef> equipments
});




}
/// @nodoc
class __$EquipmentCatalogCopyWithImpl<$Res>
    implements _$EquipmentCatalogCopyWith<$Res> {
  __$EquipmentCatalogCopyWithImpl(this._self, this._then);

  final _EquipmentCatalog _self;
  final $Res Function(_EquipmentCatalog) _then;

/// Create a copy of EquipmentCatalog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? equipments = null,}) {
  return _then(_EquipmentCatalog(
equipments: null == equipments ? _self._equipments : equipments // ignore: cast_nullable_to_non_nullable
as List<EquipmentDef>,
  ));
}


}

// dart format on
