// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exchange_def.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CostEntry {

 String get item; int get amount;
/// Create a copy of CostEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CostEntryCopyWith<CostEntry> get copyWith => _$CostEntryCopyWithImpl<CostEntry>(this as CostEntry, _$identity);

  /// Serializes this CostEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CostEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CostEntry&&(identical(other.item, _this.item) || other.item == _this.item)&&(identical(other.amount, _this.amount) || other.amount == _this.amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CostEntry;
  return Object.hash(runtimeType,_this.item,_this.amount);
}

@override
String toString() {
  final _this = this as CostEntry;
  return 'CostEntry(item: ${_this.item}, amount: ${_this.amount})';
}


}

/// @nodoc
abstract mixin class $CostEntryCopyWith<$Res>  {
  factory $CostEntryCopyWith(CostEntry value, $Res Function(CostEntry) _then) = _$CostEntryCopyWithImpl;
@useResult
$Res call({
 String item, int amount
});




}
/// @nodoc
class _$CostEntryCopyWithImpl<$Res>
    implements $CostEntryCopyWith<$Res> {
  _$CostEntryCopyWithImpl(this._self, this._then);

  final CostEntry _self;
  final $Res Function(CostEntry) _then;

/// Create a copy of CostEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? item = null,Object? amount = null,}) {
  return _then(CostEntry(
item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CostEntry].
extension CostEntryPatterns on CostEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CostEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CostEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CostEntry value)  $default,){
final _that = this;
switch (_that) {
case _CostEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CostEntry value)?  $default,){
final _that = this;
switch (_that) {
case _CostEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String item,  int amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CostEntry() when $default != null:
return $default(_that.item,_that.amount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String item,  int amount)  $default,) {final _that = this;
switch (_that) {
case _CostEntry():
return $default(_that.item,_that.amount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String item,  int amount)?  $default,) {final _that = this;
switch (_that) {
case _CostEntry() when $default != null:
return $default(_that.item,_that.amount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CostEntry implements CostEntry {
  const _CostEntry({required this.item, required this.amount});
  factory _CostEntry.fromJson(Map<String, dynamic> json) => _$CostEntryFromJson(json);

@override final  String item;
@override final  int amount;

/// Create a copy of CostEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CostEntryCopyWith<_CostEntry> get copyWith => __$CostEntryCopyWithImpl<_CostEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CostEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CostEntry&&(identical(other.item, item) || other.item == item)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,item,amount);
}

@override
String toString() {
    return 'CostEntry(item: $item, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$CostEntryCopyWith<$Res> implements $CostEntryCopyWith<$Res> {
  factory _$CostEntryCopyWith(_CostEntry value, $Res Function(_CostEntry) _then) = __$CostEntryCopyWithImpl;
@override @useResult
$Res call({
 String item, int amount
});




}
/// @nodoc
class __$CostEntryCopyWithImpl<$Res>
    implements _$CostEntryCopyWith<$Res> {
  __$CostEntryCopyWithImpl(this._self, this._then);

  final _CostEntry _self;
  final $Res Function(_CostEntry) _then;

/// Create a copy of CostEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? item = null,Object? amount = null,}) {
  return _then(_CostEntry(
item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$GainDef {

 String get type; String get id; int get amount;
/// Create a copy of GainDef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GainDefCopyWith<GainDef> get copyWith => _$GainDefCopyWithImpl<GainDef>(this as GainDef, _$identity);

  /// Serializes this GainDef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GainDef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GainDef&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.amount, _this.amount) || other.amount == _this.amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GainDef;
  return Object.hash(runtimeType,_this.type,_this.id,_this.amount);
}

@override
String toString() {
  final _this = this as GainDef;
  return 'GainDef(type: ${_this.type}, id: ${_this.id}, amount: ${_this.amount})';
}


}

/// @nodoc
abstract mixin class $GainDefCopyWith<$Res>  {
  factory $GainDefCopyWith(GainDef value, $Res Function(GainDef) _then) = _$GainDefCopyWithImpl;
@useResult
$Res call({
 String type, String id, int amount
});




}
/// @nodoc
class _$GainDefCopyWithImpl<$Res>
    implements $GainDefCopyWith<$Res> {
  _$GainDefCopyWithImpl(this._self, this._then);

  final GainDef _self;
  final $Res Function(GainDef) _then;

/// Create a copy of GainDef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? id = null,Object? amount = null,}) {
  return _then(GainDef(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GainDef].
extension GainDefPatterns on GainDef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GainDef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GainDef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GainDef value)  $default,){
final _that = this;
switch (_that) {
case _GainDef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GainDef value)?  $default,){
final _that = this;
switch (_that) {
case _GainDef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String id,  int amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GainDef() when $default != null:
return $default(_that.type,_that.id,_that.amount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String id,  int amount)  $default,) {final _that = this;
switch (_that) {
case _GainDef():
return $default(_that.type,_that.id,_that.amount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String id,  int amount)?  $default,) {final _that = this;
switch (_that) {
case _GainDef() when $default != null:
return $default(_that.type,_that.id,_that.amount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GainDef implements GainDef {
  const _GainDef({required this.type, required this.id, this.amount = 1});
  factory _GainDef.fromJson(Map<String, dynamic> json) => _$GainDefFromJson(json);

@override final  String type;
@override final  String id;
@override@JsonKey() final  int amount;

/// Create a copy of GainDef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GainDefCopyWith<_GainDef> get copyWith => __$GainDefCopyWithImpl<_GainDef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GainDefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GainDef&&(identical(other.type, type) || other.type == type)&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,id,amount);
}

@override
String toString() {
    return 'GainDef(type: $type, id: $id, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$GainDefCopyWith<$Res> implements $GainDefCopyWith<$Res> {
  factory _$GainDefCopyWith(_GainDef value, $Res Function(_GainDef) _then) = __$GainDefCopyWithImpl;
@override @useResult
$Res call({
 String type, String id, int amount
});




}
/// @nodoc
class __$GainDefCopyWithImpl<$Res>
    implements _$GainDefCopyWith<$Res> {
  __$GainDefCopyWithImpl(this._self, this._then);

  final _GainDef _self;
  final $Res Function(_GainDef) _then;

/// Create a copy of GainDef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? id = null,Object? amount = null,}) {
  return _then(_GainDef(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ExchangeUnlockDef {

 String? get dungeonId; int? get level;
/// Create a copy of ExchangeUnlockDef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExchangeUnlockDefCopyWith<ExchangeUnlockDef> get copyWith => _$ExchangeUnlockDefCopyWithImpl<ExchangeUnlockDef>(this as ExchangeUnlockDef, _$identity);

  /// Serializes this ExchangeUnlockDef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExchangeUnlockDef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExchangeUnlockDef&&(identical(other.dungeonId, _this.dungeonId) || other.dungeonId == _this.dungeonId)&&(identical(other.level, _this.level) || other.level == _this.level));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExchangeUnlockDef;
  return Object.hash(runtimeType,_this.dungeonId,_this.level);
}

@override
String toString() {
  final _this = this as ExchangeUnlockDef;
  return 'ExchangeUnlockDef(dungeonId: ${_this.dungeonId}, level: ${_this.level})';
}


}

/// @nodoc
abstract mixin class $ExchangeUnlockDefCopyWith<$Res>  {
  factory $ExchangeUnlockDefCopyWith(ExchangeUnlockDef value, $Res Function(ExchangeUnlockDef) _then) = _$ExchangeUnlockDefCopyWithImpl;
@useResult
$Res call({
 String? dungeonId, int? level
});




}
/// @nodoc
class _$ExchangeUnlockDefCopyWithImpl<$Res>
    implements $ExchangeUnlockDefCopyWith<$Res> {
  _$ExchangeUnlockDefCopyWithImpl(this._self, this._then);

  final ExchangeUnlockDef _self;
  final $Res Function(ExchangeUnlockDef) _then;

/// Create a copy of ExchangeUnlockDef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dungeonId = freezed,Object? level = freezed,}) {
  return _then(ExchangeUnlockDef(
dungeonId: freezed == dungeonId ? _self.dungeonId : dungeonId // ignore: cast_nullable_to_non_nullable
as String?,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExchangeUnlockDef].
extension ExchangeUnlockDefPatterns on ExchangeUnlockDef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExchangeUnlockDef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExchangeUnlockDef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExchangeUnlockDef value)  $default,){
final _that = this;
switch (_that) {
case _ExchangeUnlockDef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExchangeUnlockDef value)?  $default,){
final _that = this;
switch (_that) {
case _ExchangeUnlockDef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? dungeonId,  int? level)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExchangeUnlockDef() when $default != null:
return $default(_that.dungeonId,_that.level);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? dungeonId,  int? level)  $default,) {final _that = this;
switch (_that) {
case _ExchangeUnlockDef():
return $default(_that.dungeonId,_that.level);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? dungeonId,  int? level)?  $default,) {final _that = this;
switch (_that) {
case _ExchangeUnlockDef() when $default != null:
return $default(_that.dungeonId,_that.level);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExchangeUnlockDef implements ExchangeUnlockDef {
  const _ExchangeUnlockDef({this.dungeonId, this.level});
  factory _ExchangeUnlockDef.fromJson(Map<String, dynamic> json) => _$ExchangeUnlockDefFromJson(json);

@override final  String? dungeonId;
@override final  int? level;

/// Create a copy of ExchangeUnlockDef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExchangeUnlockDefCopyWith<_ExchangeUnlockDef> get copyWith => __$ExchangeUnlockDefCopyWithImpl<_ExchangeUnlockDef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExchangeUnlockDefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExchangeUnlockDef&&(identical(other.dungeonId, dungeonId) || other.dungeonId == dungeonId)&&(identical(other.level, level) || other.level == level));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,dungeonId,level);
}

@override
String toString() {
    return 'ExchangeUnlockDef(dungeonId: $dungeonId, level: $level)';
}


}

/// @nodoc
abstract mixin class _$ExchangeUnlockDefCopyWith<$Res> implements $ExchangeUnlockDefCopyWith<$Res> {
  factory _$ExchangeUnlockDefCopyWith(_ExchangeUnlockDef value, $Res Function(_ExchangeUnlockDef) _then) = __$ExchangeUnlockDefCopyWithImpl;
@override @useResult
$Res call({
 String? dungeonId, int? level
});




}
/// @nodoc
class __$ExchangeUnlockDefCopyWithImpl<$Res>
    implements _$ExchangeUnlockDefCopyWith<$Res> {
  __$ExchangeUnlockDefCopyWithImpl(this._self, this._then);

  final _ExchangeUnlockDef _self;
  final $Res Function(_ExchangeUnlockDef) _then;

/// Create a copy of ExchangeUnlockDef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dungeonId = freezed,Object? level = freezed,}) {
  return _then(_ExchangeUnlockDef(
dungeonId: freezed == dungeonId ? _self.dungeonId : dungeonId // ignore: cast_nullable_to_non_nullable
as String?,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$ExchangeEntryDef {

 String get id; List<CostEntry> get cost; GainDef get gain; int get limit; String get resetPeriod; ExchangeUnlockDef? get unlock;
/// Create a copy of ExchangeEntryDef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExchangeEntryDefCopyWith<ExchangeEntryDef> get copyWith => _$ExchangeEntryDefCopyWithImpl<ExchangeEntryDef>(this as ExchangeEntryDef, _$identity);

  /// Serializes this ExchangeEntryDef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExchangeEntryDef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExchangeEntryDef&&(identical(other.id, _this.id) || other.id == _this.id)&&const DeepCollectionEquality().equals(other.cost, _this.cost)&&(identical(other.gain, _this.gain) || other.gain == _this.gain)&&(identical(other.limit, _this.limit) || other.limit == _this.limit)&&(identical(other.resetPeriod, _this.resetPeriod) || other.resetPeriod == _this.resetPeriod)&&(identical(other.unlock, _this.unlock) || other.unlock == _this.unlock));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExchangeEntryDef;
  return Object.hash(runtimeType,_this.id,const DeepCollectionEquality().hash(_this.cost),_this.gain,_this.limit,_this.resetPeriod,_this.unlock);
}

@override
String toString() {
  final _this = this as ExchangeEntryDef;
  return 'ExchangeEntryDef(id: ${_this.id}, cost: ${_this.cost}, gain: ${_this.gain}, limit: ${_this.limit}, resetPeriod: ${_this.resetPeriod}, unlock: ${_this.unlock})';
}


}

/// @nodoc
abstract mixin class $ExchangeEntryDefCopyWith<$Res>  {
  factory $ExchangeEntryDefCopyWith(ExchangeEntryDef value, $Res Function(ExchangeEntryDef) _then) = _$ExchangeEntryDefCopyWithImpl;
@useResult
$Res call({
 String id, List<CostEntry> cost, GainDef gain, int limit, String resetPeriod, ExchangeUnlockDef? unlock
});


$GainDefCopyWith<$Res> get gain;$ExchangeUnlockDefCopyWith<$Res>? get unlock;

}
/// @nodoc
class _$ExchangeEntryDefCopyWithImpl<$Res>
    implements $ExchangeEntryDefCopyWith<$Res> {
  _$ExchangeEntryDefCopyWithImpl(this._self, this._then);

  final ExchangeEntryDef _self;
  final $Res Function(ExchangeEntryDef) _then;

/// Create a copy of ExchangeEntryDef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? cost = null,Object? gain = null,Object? limit = null,Object? resetPeriod = null,Object? unlock = freezed,}) {
  return _then(ExchangeEntryDef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as List<CostEntry>,gain: null == gain ? _self.gain : gain // ignore: cast_nullable_to_non_nullable
as GainDef,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,resetPeriod: null == resetPeriod ? _self.resetPeriod : resetPeriod // ignore: cast_nullable_to_non_nullable
as String,unlock: freezed == unlock ? _self.unlock : unlock // ignore: cast_nullable_to_non_nullable
as ExchangeUnlockDef?,
  ));
}
/// Create a copy of ExchangeEntryDef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GainDefCopyWith<$Res> get gain {
  
  return $GainDefCopyWith<$Res>(_self.gain, (value) {
    return _then(_self.copyWith(gain: value));
  });
}/// Create a copy of ExchangeEntryDef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExchangeUnlockDefCopyWith<$Res>? get unlock {
    if (_self.unlock == null) {
    return null;
  }

  return $ExchangeUnlockDefCopyWith<$Res>(_self.unlock!, (value) {
    return _then(_self.copyWith(unlock: value));
  });
}
}


/// Adds pattern-matching-related methods to [ExchangeEntryDef].
extension ExchangeEntryDefPatterns on ExchangeEntryDef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExchangeEntryDef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExchangeEntryDef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExchangeEntryDef value)  $default,){
final _that = this;
switch (_that) {
case _ExchangeEntryDef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExchangeEntryDef value)?  $default,){
final _that = this;
switch (_that) {
case _ExchangeEntryDef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<CostEntry> cost,  GainDef gain,  int limit,  String resetPeriod,  ExchangeUnlockDef? unlock)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExchangeEntryDef() when $default != null:
return $default(_that.id,_that.cost,_that.gain,_that.limit,_that.resetPeriod,_that.unlock);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<CostEntry> cost,  GainDef gain,  int limit,  String resetPeriod,  ExchangeUnlockDef? unlock)  $default,) {final _that = this;
switch (_that) {
case _ExchangeEntryDef():
return $default(_that.id,_that.cost,_that.gain,_that.limit,_that.resetPeriod,_that.unlock);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<CostEntry> cost,  GainDef gain,  int limit,  String resetPeriod,  ExchangeUnlockDef? unlock)?  $default,) {final _that = this;
switch (_that) {
case _ExchangeEntryDef() when $default != null:
return $default(_that.id,_that.cost,_that.gain,_that.limit,_that.resetPeriod,_that.unlock);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExchangeEntryDef implements ExchangeEntryDef {
  const _ExchangeEntryDef({required this.id, required  List<CostEntry> cost, required this.gain, this.limit = 0, this.resetPeriod = 'NONE', this.unlock}): _cost = cost;
  factory _ExchangeEntryDef.fromJson(Map<String, dynamic> json) => _$ExchangeEntryDefFromJson(json);

@override final  String id;
 final  List<CostEntry> _cost;
@override List<CostEntry> get cost {
  if (_cost is EqualUnmodifiableListView) return _cost;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cost);
}

@override final  GainDef gain;
@override@JsonKey() final  int limit;
@override@JsonKey() final  String resetPeriod;
@override final  ExchangeUnlockDef? unlock;

/// Create a copy of ExchangeEntryDef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExchangeEntryDefCopyWith<_ExchangeEntryDef> get copyWith => __$ExchangeEntryDefCopyWithImpl<_ExchangeEntryDef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExchangeEntryDefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExchangeEntryDef&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.cost, _cost)&&(identical(other.gain, gain) || other.gain == gain)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.resetPeriod, resetPeriod) || other.resetPeriod == resetPeriod)&&(identical(other.unlock, unlock) || other.unlock == unlock));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_cost),gain,limit,resetPeriod,unlock);
}

@override
String toString() {
    return 'ExchangeEntryDef(id: $id, cost: $cost, gain: $gain, limit: $limit, resetPeriod: $resetPeriod, unlock: $unlock)';
}


}

/// @nodoc
abstract mixin class _$ExchangeEntryDefCopyWith<$Res> implements $ExchangeEntryDefCopyWith<$Res> {
  factory _$ExchangeEntryDefCopyWith(_ExchangeEntryDef value, $Res Function(_ExchangeEntryDef) _then) = __$ExchangeEntryDefCopyWithImpl;
@override @useResult
$Res call({
 String id, List<CostEntry> cost, GainDef gain, int limit, String resetPeriod, ExchangeUnlockDef? unlock
});


@override $GainDefCopyWith<$Res> get gain;@override $ExchangeUnlockDefCopyWith<$Res>? get unlock;

}
/// @nodoc
class __$ExchangeEntryDefCopyWithImpl<$Res>
    implements _$ExchangeEntryDefCopyWith<$Res> {
  __$ExchangeEntryDefCopyWithImpl(this._self, this._then);

  final _ExchangeEntryDef _self;
  final $Res Function(_ExchangeEntryDef) _then;

/// Create a copy of ExchangeEntryDef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? cost = null,Object? gain = null,Object? limit = null,Object? resetPeriod = null,Object? unlock = freezed,}) {
  return _then(_ExchangeEntryDef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,cost: null == cost ? _self._cost : cost // ignore: cast_nullable_to_non_nullable
as List<CostEntry>,gain: null == gain ? _self.gain : gain // ignore: cast_nullable_to_non_nullable
as GainDef,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,resetPeriod: null == resetPeriod ? _self.resetPeriod : resetPeriod // ignore: cast_nullable_to_non_nullable
as String,unlock: freezed == unlock ? _self.unlock : unlock // ignore: cast_nullable_to_non_nullable
as ExchangeUnlockDef?,
  ));
}

/// Create a copy of ExchangeEntryDef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GainDefCopyWith<$Res> get gain {
  
  return $GainDefCopyWith<$Res>(_self.gain, (value) {
    return _then(_self.copyWith(gain: value));
  });
}/// Create a copy of ExchangeEntryDef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExchangeUnlockDefCopyWith<$Res>? get unlock {
    if (_self.unlock == null) {
    return null;
  }

  return $ExchangeUnlockDefCopyWith<$Res>(_self.unlock!, (value) {
    return _then(_self.copyWith(unlock: value));
  });
}
}


/// @nodoc
mixin _$ShopDef {

 String get id; String get nameKey; List<ExchangeEntryDef> get entries;
/// Create a copy of ShopDef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShopDefCopyWith<ShopDef> get copyWith => _$ShopDefCopyWithImpl<ShopDef>(this as ShopDef, _$identity);

  /// Serializes this ShopDef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ShopDef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShopDef&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.nameKey, _this.nameKey) || other.nameKey == _this.nameKey)&&const DeepCollectionEquality().equals(other.entries, _this.entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ShopDef;
  return Object.hash(runtimeType,_this.id,_this.nameKey,const DeepCollectionEquality().hash(_this.entries));
}

@override
String toString() {
  final _this = this as ShopDef;
  return 'ShopDef(id: ${_this.id}, nameKey: ${_this.nameKey}, entries: ${_this.entries})';
}


}

/// @nodoc
abstract mixin class $ShopDefCopyWith<$Res>  {
  factory $ShopDefCopyWith(ShopDef value, $Res Function(ShopDef) _then) = _$ShopDefCopyWithImpl;
@useResult
$Res call({
 String id, String nameKey, List<ExchangeEntryDef> entries
});




}
/// @nodoc
class _$ShopDefCopyWithImpl<$Res>
    implements $ShopDefCopyWith<$Res> {
  _$ShopDefCopyWithImpl(this._self, this._then);

  final ShopDef _self;
  final $Res Function(ShopDef) _then;

/// Create a copy of ShopDef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nameKey = null,Object? entries = null,}) {
  return _then(ShopDef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameKey: null == nameKey ? _self.nameKey : nameKey // ignore: cast_nullable_to_non_nullable
as String,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<ExchangeEntryDef>,
  ));
}

}


/// Adds pattern-matching-related methods to [ShopDef].
extension ShopDefPatterns on ShopDef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShopDef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShopDef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShopDef value)  $default,){
final _that = this;
switch (_that) {
case _ShopDef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShopDef value)?  $default,){
final _that = this;
switch (_that) {
case _ShopDef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nameKey,  List<ExchangeEntryDef> entries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShopDef() when $default != null:
return $default(_that.id,_that.nameKey,_that.entries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nameKey,  List<ExchangeEntryDef> entries)  $default,) {final _that = this;
switch (_that) {
case _ShopDef():
return $default(_that.id,_that.nameKey,_that.entries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nameKey,  List<ExchangeEntryDef> entries)?  $default,) {final _that = this;
switch (_that) {
case _ShopDef() when $default != null:
return $default(_that.id,_that.nameKey,_that.entries);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShopDef implements ShopDef {
  const _ShopDef({required this.id, required this.nameKey,  List<ExchangeEntryDef> entries = const <ExchangeEntryDef>[]}): _entries = entries;
  factory _ShopDef.fromJson(Map<String, dynamic> json) => _$ShopDefFromJson(json);

@override final  String id;
@override final  String nameKey;
 final  List<ExchangeEntryDef> _entries;
@override@JsonKey() List<ExchangeEntryDef> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


/// Create a copy of ShopDef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShopDefCopyWith<_ShopDef> get copyWith => __$ShopDefCopyWithImpl<_ShopDef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShopDefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShopDef&&(identical(other.id, id) || other.id == id)&&(identical(other.nameKey, nameKey) || other.nameKey == nameKey)&&const DeepCollectionEquality().equals(other.entries, _entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,nameKey,const DeepCollectionEquality().hash(_entries));
}

@override
String toString() {
    return 'ShopDef(id: $id, nameKey: $nameKey, entries: $entries)';
}


}

/// @nodoc
abstract mixin class _$ShopDefCopyWith<$Res> implements $ShopDefCopyWith<$Res> {
  factory _$ShopDefCopyWith(_ShopDef value, $Res Function(_ShopDef) _then) = __$ShopDefCopyWithImpl;
@override @useResult
$Res call({
 String id, String nameKey, List<ExchangeEntryDef> entries
});




}
/// @nodoc
class __$ShopDefCopyWithImpl<$Res>
    implements _$ShopDefCopyWith<$Res> {
  __$ShopDefCopyWithImpl(this._self, this._then);

  final _ShopDef _self;
  final $Res Function(_ShopDef) _then;

/// Create a copy of ShopDef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nameKey = null,Object? entries = null,}) {
  return _then(_ShopDef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameKey: null == nameKey ? _self.nameKey : nameKey // ignore: cast_nullable_to_non_nullable
as String,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<ExchangeEntryDef>,
  ));
}


}


/// @nodoc
mixin _$ExchangeConfig {

 List<ExchangeEntryDef> get upgrades; List<ShopDef> get shops;
/// Create a copy of ExchangeConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExchangeConfigCopyWith<ExchangeConfig> get copyWith => _$ExchangeConfigCopyWithImpl<ExchangeConfig>(this as ExchangeConfig, _$identity);

  /// Serializes this ExchangeConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExchangeConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExchangeConfig&&const DeepCollectionEquality().equals(other.upgrades, _this.upgrades)&&const DeepCollectionEquality().equals(other.shops, _this.shops));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExchangeConfig;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.upgrades),const DeepCollectionEquality().hash(_this.shops));
}

@override
String toString() {
  final _this = this as ExchangeConfig;
  return 'ExchangeConfig(upgrades: ${_this.upgrades}, shops: ${_this.shops})';
}


}

/// @nodoc
abstract mixin class $ExchangeConfigCopyWith<$Res>  {
  factory $ExchangeConfigCopyWith(ExchangeConfig value, $Res Function(ExchangeConfig) _then) = _$ExchangeConfigCopyWithImpl;
@useResult
$Res call({
 List<ExchangeEntryDef> upgrades, List<ShopDef> shops
});




}
/// @nodoc
class _$ExchangeConfigCopyWithImpl<$Res>
    implements $ExchangeConfigCopyWith<$Res> {
  _$ExchangeConfigCopyWithImpl(this._self, this._then);

  final ExchangeConfig _self;
  final $Res Function(ExchangeConfig) _then;

/// Create a copy of ExchangeConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? upgrades = null,Object? shops = null,}) {
  return _then(ExchangeConfig(
upgrades: null == upgrades ? _self.upgrades : upgrades // ignore: cast_nullable_to_non_nullable
as List<ExchangeEntryDef>,shops: null == shops ? _self.shops : shops // ignore: cast_nullable_to_non_nullable
as List<ShopDef>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExchangeConfig].
extension ExchangeConfigPatterns on ExchangeConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExchangeConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExchangeConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExchangeConfig value)  $default,){
final _that = this;
switch (_that) {
case _ExchangeConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExchangeConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ExchangeConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ExchangeEntryDef> upgrades,  List<ShopDef> shops)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExchangeConfig() when $default != null:
return $default(_that.upgrades,_that.shops);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ExchangeEntryDef> upgrades,  List<ShopDef> shops)  $default,) {final _that = this;
switch (_that) {
case _ExchangeConfig():
return $default(_that.upgrades,_that.shops);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ExchangeEntryDef> upgrades,  List<ShopDef> shops)?  $default,) {final _that = this;
switch (_that) {
case _ExchangeConfig() when $default != null:
return $default(_that.upgrades,_that.shops);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExchangeConfig implements ExchangeConfig {
  const _ExchangeConfig({ List<ExchangeEntryDef> upgrades = const <ExchangeEntryDef>[],  List<ShopDef> shops = const <ShopDef>[]}): _upgrades = upgrades,_shops = shops;
  factory _ExchangeConfig.fromJson(Map<String, dynamic> json) => _$ExchangeConfigFromJson(json);

 final  List<ExchangeEntryDef> _upgrades;
@override@JsonKey() List<ExchangeEntryDef> get upgrades {
  if (_upgrades is EqualUnmodifiableListView) return _upgrades;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_upgrades);
}

 final  List<ShopDef> _shops;
@override@JsonKey() List<ShopDef> get shops {
  if (_shops is EqualUnmodifiableListView) return _shops;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_shops);
}


/// Create a copy of ExchangeConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExchangeConfigCopyWith<_ExchangeConfig> get copyWith => __$ExchangeConfigCopyWithImpl<_ExchangeConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExchangeConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExchangeConfig&&const DeepCollectionEquality().equals(other.upgrades, _upgrades)&&const DeepCollectionEquality().equals(other.shops, _shops));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_upgrades),const DeepCollectionEquality().hash(_shops));
}

@override
String toString() {
    return 'ExchangeConfig(upgrades: $upgrades, shops: $shops)';
}


}

/// @nodoc
abstract mixin class _$ExchangeConfigCopyWith<$Res> implements $ExchangeConfigCopyWith<$Res> {
  factory _$ExchangeConfigCopyWith(_ExchangeConfig value, $Res Function(_ExchangeConfig) _then) = __$ExchangeConfigCopyWithImpl;
@override @useResult
$Res call({
 List<ExchangeEntryDef> upgrades, List<ShopDef> shops
});




}
/// @nodoc
class __$ExchangeConfigCopyWithImpl<$Res>
    implements _$ExchangeConfigCopyWith<$Res> {
  __$ExchangeConfigCopyWithImpl(this._self, this._then);

  final _ExchangeConfig _self;
  final $Res Function(_ExchangeConfig) _then;

/// Create a copy of ExchangeConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? upgrades = null,Object? shops = null,}) {
  return _then(_ExchangeConfig(
upgrades: null == upgrades ? _self._upgrades : upgrades // ignore: cast_nullable_to_non_nullable
as List<ExchangeEntryDef>,shops: null == shops ? _self._shops : shops // ignore: cast_nullable_to_non_nullable
as List<ShopDef>,
  ));
}


}

// dart format on
