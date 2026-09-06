// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'banner_def.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BannerCost {

 CostEntry get single; CostEntry get ten;
/// Create a copy of BannerCost
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BannerCostCopyWith<BannerCost> get copyWith => _$BannerCostCopyWithImpl<BannerCost>(this as BannerCost, _$identity);

  /// Serializes this BannerCost to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BannerCost;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BannerCost&&(identical(other.single, _this.single) || other.single == _this.single)&&(identical(other.ten, _this.ten) || other.ten == _this.ten));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BannerCost;
  return Object.hash(runtimeType,_this.single,_this.ten);
}

@override
String toString() {
  final _this = this as BannerCost;
  return 'BannerCost(single: ${_this.single}, ten: ${_this.ten})';
}


}

/// @nodoc
abstract mixin class $BannerCostCopyWith<$Res>  {
  factory $BannerCostCopyWith(BannerCost value, $Res Function(BannerCost) _then) = _$BannerCostCopyWithImpl;
@useResult
$Res call({
 CostEntry single, CostEntry ten
});


$CostEntryCopyWith<$Res> get single;$CostEntryCopyWith<$Res> get ten;

}
/// @nodoc
class _$BannerCostCopyWithImpl<$Res>
    implements $BannerCostCopyWith<$Res> {
  _$BannerCostCopyWithImpl(this._self, this._then);

  final BannerCost _self;
  final $Res Function(BannerCost) _then;

/// Create a copy of BannerCost
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? single = null,Object? ten = null,}) {
  return _then(BannerCost(
single: null == single ? _self.single : single // ignore: cast_nullable_to_non_nullable
as CostEntry,ten: null == ten ? _self.ten : ten // ignore: cast_nullable_to_non_nullable
as CostEntry,
  ));
}
/// Create a copy of BannerCost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CostEntryCopyWith<$Res> get single {
  
  return $CostEntryCopyWith<$Res>(_self.single, (value) {
    return _then(_self.copyWith(single: value));
  });
}/// Create a copy of BannerCost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CostEntryCopyWith<$Res> get ten {
  
  return $CostEntryCopyWith<$Res>(_self.ten, (value) {
    return _then(_self.copyWith(ten: value));
  });
}
}


/// Adds pattern-matching-related methods to [BannerCost].
extension BannerCostPatterns on BannerCost {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BannerCost value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BannerCost() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BannerCost value)  $default,){
final _that = this;
switch (_that) {
case _BannerCost():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BannerCost value)?  $default,){
final _that = this;
switch (_that) {
case _BannerCost() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CostEntry single,  CostEntry ten)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BannerCost() when $default != null:
return $default(_that.single,_that.ten);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CostEntry single,  CostEntry ten)  $default,) {final _that = this;
switch (_that) {
case _BannerCost():
return $default(_that.single,_that.ten);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CostEntry single,  CostEntry ten)?  $default,) {final _that = this;
switch (_that) {
case _BannerCost() when $default != null:
return $default(_that.single,_that.ten);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BannerCost implements BannerCost {
  const _BannerCost({required this.single, required this.ten});
  factory _BannerCost.fromJson(Map<String, dynamic> json) => _$BannerCostFromJson(json);

@override final  CostEntry single;
@override final  CostEntry ten;

/// Create a copy of BannerCost
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BannerCostCopyWith<_BannerCost> get copyWith => __$BannerCostCopyWithImpl<_BannerCost>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BannerCostToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BannerCost&&(identical(other.single, single) || other.single == single)&&(identical(other.ten, ten) || other.ten == ten));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,single,ten);
}

@override
String toString() {
    return 'BannerCost(single: $single, ten: $ten)';
}


}

/// @nodoc
abstract mixin class _$BannerCostCopyWith<$Res> implements $BannerCostCopyWith<$Res> {
  factory _$BannerCostCopyWith(_BannerCost value, $Res Function(_BannerCost) _then) = __$BannerCostCopyWithImpl;
@override @useResult
$Res call({
 CostEntry single, CostEntry ten
});


@override $CostEntryCopyWith<$Res> get single;@override $CostEntryCopyWith<$Res> get ten;

}
/// @nodoc
class __$BannerCostCopyWithImpl<$Res>
    implements _$BannerCostCopyWith<$Res> {
  __$BannerCostCopyWithImpl(this._self, this._then);

  final _BannerCost _self;
  final $Res Function(_BannerCost) _then;

/// Create a copy of BannerCost
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? single = null,Object? ten = null,}) {
  return _then(_BannerCost(
single: null == single ? _self.single : single // ignore: cast_nullable_to_non_nullable
as CostEntry,ten: null == ten ? _self.ten : ten // ignore: cast_nullable_to_non_nullable
as CostEntry,
  ));
}

/// Create a copy of BannerCost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CostEntryCopyWith<$Res> get single {
  
  return $CostEntryCopyWith<$Res>(_self.single, (value) {
    return _then(_self.copyWith(single: value));
  });
}/// Create a copy of BannerCost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CostEntryCopyWith<$Res> get ten {
  
  return $CostEntryCopyWith<$Res>(_self.ten, (value) {
    return _then(_self.copyWith(ten: value));
  });
}
}


/// @nodoc
mixin _$RateEntry {

 int get rarity; bool get pickup; int get totalPct; List<String> get pool;
/// Create a copy of RateEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RateEntryCopyWith<RateEntry> get copyWith => _$RateEntryCopyWithImpl<RateEntry>(this as RateEntry, _$identity);

  /// Serializes this RateEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RateEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RateEntry&&(identical(other.rarity, _this.rarity) || other.rarity == _this.rarity)&&(identical(other.pickup, _this.pickup) || other.pickup == _this.pickup)&&(identical(other.totalPct, _this.totalPct) || other.totalPct == _this.totalPct)&&const DeepCollectionEquality().equals(other.pool, _this.pool));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RateEntry;
  return Object.hash(runtimeType,_this.rarity,_this.pickup,_this.totalPct,const DeepCollectionEquality().hash(_this.pool));
}

@override
String toString() {
  final _this = this as RateEntry;
  return 'RateEntry(rarity: ${_this.rarity}, pickup: ${_this.pickup}, totalPct: ${_this.totalPct}, pool: ${_this.pool})';
}


}

/// @nodoc
abstract mixin class $RateEntryCopyWith<$Res>  {
  factory $RateEntryCopyWith(RateEntry value, $Res Function(RateEntry) _then) = _$RateEntryCopyWithImpl;
@useResult
$Res call({
 int rarity, bool pickup, int totalPct, List<String> pool
});




}
/// @nodoc
class _$RateEntryCopyWithImpl<$Res>
    implements $RateEntryCopyWith<$Res> {
  _$RateEntryCopyWithImpl(this._self, this._then);

  final RateEntry _self;
  final $Res Function(RateEntry) _then;

/// Create a copy of RateEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rarity = null,Object? pickup = null,Object? totalPct = null,Object? pool = null,}) {
  return _then(RateEntry(
rarity: null == rarity ? _self.rarity : rarity // ignore: cast_nullable_to_non_nullable
as int,pickup: null == pickup ? _self.pickup : pickup // ignore: cast_nullable_to_non_nullable
as bool,totalPct: null == totalPct ? _self.totalPct : totalPct // ignore: cast_nullable_to_non_nullable
as int,pool: null == pool ? _self.pool : pool // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [RateEntry].
extension RateEntryPatterns on RateEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RateEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RateEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RateEntry value)  $default,){
final _that = this;
switch (_that) {
case _RateEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RateEntry value)?  $default,){
final _that = this;
switch (_that) {
case _RateEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rarity,  bool pickup,  int totalPct,  List<String> pool)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RateEntry() when $default != null:
return $default(_that.rarity,_that.pickup,_that.totalPct,_that.pool);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rarity,  bool pickup,  int totalPct,  List<String> pool)  $default,) {final _that = this;
switch (_that) {
case _RateEntry():
return $default(_that.rarity,_that.pickup,_that.totalPct,_that.pool);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rarity,  bool pickup,  int totalPct,  List<String> pool)?  $default,) {final _that = this;
switch (_that) {
case _RateEntry() when $default != null:
return $default(_that.rarity,_that.pickup,_that.totalPct,_that.pool);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RateEntry implements RateEntry {
  const _RateEntry({required this.rarity, this.pickup = false, required this.totalPct, required  List<String> pool}): _pool = pool;
  factory _RateEntry.fromJson(Map<String, dynamic> json) => _$RateEntryFromJson(json);

@override final  int rarity;
@override@JsonKey() final  bool pickup;
@override final  int totalPct;
 final  List<String> _pool;
@override List<String> get pool {
  if (_pool is EqualUnmodifiableListView) return _pool;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pool);
}


/// Create a copy of RateEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RateEntryCopyWith<_RateEntry> get copyWith => __$RateEntryCopyWithImpl<_RateEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RateEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RateEntry&&(identical(other.rarity, rarity) || other.rarity == rarity)&&(identical(other.pickup, pickup) || other.pickup == pickup)&&(identical(other.totalPct, totalPct) || other.totalPct == totalPct)&&const DeepCollectionEquality().equals(other.pool, _pool));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,rarity,pickup,totalPct,const DeepCollectionEquality().hash(_pool));
}

@override
String toString() {
    return 'RateEntry(rarity: $rarity, pickup: $pickup, totalPct: $totalPct, pool: $pool)';
}


}

/// @nodoc
abstract mixin class _$RateEntryCopyWith<$Res> implements $RateEntryCopyWith<$Res> {
  factory _$RateEntryCopyWith(_RateEntry value, $Res Function(_RateEntry) _then) = __$RateEntryCopyWithImpl;
@override @useResult
$Res call({
 int rarity, bool pickup, int totalPct, List<String> pool
});




}
/// @nodoc
class __$RateEntryCopyWithImpl<$Res>
    implements _$RateEntryCopyWith<$Res> {
  __$RateEntryCopyWithImpl(this._self, this._then);

  final _RateEntry _self;
  final $Res Function(_RateEntry) _then;

/// Create a copy of RateEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rarity = null,Object? pickup = null,Object? totalPct = null,Object? pool = null,}) {
  return _then(_RateEntry(
rarity: null == rarity ? _self.rarity : rarity // ignore: cast_nullable_to_non_nullable
as int,pickup: null == pickup ? _self.pickup : pickup // ignore: cast_nullable_to_non_nullable
as bool,totalPct: null == totalPct ? _self.totalPct : totalPct // ignore: cast_nullable_to_non_nullable
as int,pool: null == pool ? _self._pool : pool // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$DuplicateConversion {

 int get rarity3; int get rarity2; int get rarity1; String get item;
/// Create a copy of DuplicateConversion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DuplicateConversionCopyWith<DuplicateConversion> get copyWith => _$DuplicateConversionCopyWithImpl<DuplicateConversion>(this as DuplicateConversion, _$identity);

  /// Serializes this DuplicateConversion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DuplicateConversion;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DuplicateConversion&&(identical(other.rarity3, _this.rarity3) || other.rarity3 == _this.rarity3)&&(identical(other.rarity2, _this.rarity2) || other.rarity2 == _this.rarity2)&&(identical(other.rarity1, _this.rarity1) || other.rarity1 == _this.rarity1)&&(identical(other.item, _this.item) || other.item == _this.item));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DuplicateConversion;
  return Object.hash(runtimeType,_this.rarity3,_this.rarity2,_this.rarity1,_this.item);
}

@override
String toString() {
  final _this = this as DuplicateConversion;
  return 'DuplicateConversion(rarity3: ${_this.rarity3}, rarity2: ${_this.rarity2}, rarity1: ${_this.rarity1}, item: ${_this.item})';
}


}

/// @nodoc
abstract mixin class $DuplicateConversionCopyWith<$Res>  {
  factory $DuplicateConversionCopyWith(DuplicateConversion value, $Res Function(DuplicateConversion) _then) = _$DuplicateConversionCopyWithImpl;
@useResult
$Res call({
 int rarity3, int rarity2, int rarity1, String item
});




}
/// @nodoc
class _$DuplicateConversionCopyWithImpl<$Res>
    implements $DuplicateConversionCopyWith<$Res> {
  _$DuplicateConversionCopyWithImpl(this._self, this._then);

  final DuplicateConversion _self;
  final $Res Function(DuplicateConversion) _then;

/// Create a copy of DuplicateConversion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rarity3 = null,Object? rarity2 = null,Object? rarity1 = null,Object? item = null,}) {
  return _then(DuplicateConversion(
rarity3: null == rarity3 ? _self.rarity3 : rarity3 // ignore: cast_nullable_to_non_nullable
as int,rarity2: null == rarity2 ? _self.rarity2 : rarity2 // ignore: cast_nullable_to_non_nullable
as int,rarity1: null == rarity1 ? _self.rarity1 : rarity1 // ignore: cast_nullable_to_non_nullable
as int,item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DuplicateConversion].
extension DuplicateConversionPatterns on DuplicateConversion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DuplicateConversion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DuplicateConversion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DuplicateConversion value)  $default,){
final _that = this;
switch (_that) {
case _DuplicateConversion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DuplicateConversion value)?  $default,){
final _that = this;
switch (_that) {
case _DuplicateConversion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rarity3,  int rarity2,  int rarity1,  String item)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DuplicateConversion() when $default != null:
return $default(_that.rarity3,_that.rarity2,_that.rarity1,_that.item);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rarity3,  int rarity2,  int rarity1,  String item)  $default,) {final _that = this;
switch (_that) {
case _DuplicateConversion():
return $default(_that.rarity3,_that.rarity2,_that.rarity1,_that.item);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rarity3,  int rarity2,  int rarity1,  String item)?  $default,) {final _that = this;
switch (_that) {
case _DuplicateConversion() when $default != null:
return $default(_that.rarity3,_that.rarity2,_that.rarity1,_that.item);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DuplicateConversion implements DuplicateConversion {
  const _DuplicateConversion({required this.rarity3, required this.rarity2, required this.rarity1, required this.item});
  factory _DuplicateConversion.fromJson(Map<String, dynamic> json) => _$DuplicateConversionFromJson(json);

@override final  int rarity3;
@override final  int rarity2;
@override final  int rarity1;
@override final  String item;

/// Create a copy of DuplicateConversion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DuplicateConversionCopyWith<_DuplicateConversion> get copyWith => __$DuplicateConversionCopyWithImpl<_DuplicateConversion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DuplicateConversionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DuplicateConversion&&(identical(other.rarity3, rarity3) || other.rarity3 == rarity3)&&(identical(other.rarity2, rarity2) || other.rarity2 == rarity2)&&(identical(other.rarity1, rarity1) || other.rarity1 == rarity1)&&(identical(other.item, item) || other.item == item));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,rarity3,rarity2,rarity1,item);
}

@override
String toString() {
    return 'DuplicateConversion(rarity3: $rarity3, rarity2: $rarity2, rarity1: $rarity1, item: $item)';
}


}

/// @nodoc
abstract mixin class _$DuplicateConversionCopyWith<$Res> implements $DuplicateConversionCopyWith<$Res> {
  factory _$DuplicateConversionCopyWith(_DuplicateConversion value, $Res Function(_DuplicateConversion) _then) = __$DuplicateConversionCopyWithImpl;
@override @useResult
$Res call({
 int rarity3, int rarity2, int rarity1, String item
});




}
/// @nodoc
class __$DuplicateConversionCopyWithImpl<$Res>
    implements _$DuplicateConversionCopyWith<$Res> {
  __$DuplicateConversionCopyWithImpl(this._self, this._then);

  final _DuplicateConversion _self;
  final $Res Function(_DuplicateConversion) _then;

/// Create a copy of DuplicateConversion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rarity3 = null,Object? rarity2 = null,Object? rarity1 = null,Object? item = null,}) {
  return _then(_DuplicateConversion(
rarity3: null == rarity3 ? _self.rarity3 : rarity3 // ignore: cast_nullable_to_non_nullable
as int,rarity2: null == rarity2 ? _self.rarity2 : rarity2 // ignore: cast_nullable_to_non_nullable
as int,rarity1: null == rarity1 ? _self.rarity1 : rarity1 // ignore: cast_nullable_to_non_nullable
as int,item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$BannerDef {

 String get id; String get kind; String get nameKey; DateTime? get startAtUtc; DateTime? get endAtUtc; BannerCost get cost; bool get givesExchangePoint; List<RateEntry> get rates; DuplicateConversion get duplicateConversion; List<String> get exchangeTargets;
/// Create a copy of BannerDef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BannerDefCopyWith<BannerDef> get copyWith => _$BannerDefCopyWithImpl<BannerDef>(this as BannerDef, _$identity);

  /// Serializes this BannerDef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BannerDef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BannerDef&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.nameKey, _this.nameKey) || other.nameKey == _this.nameKey)&&(identical(other.startAtUtc, _this.startAtUtc) || other.startAtUtc == _this.startAtUtc)&&(identical(other.endAtUtc, _this.endAtUtc) || other.endAtUtc == _this.endAtUtc)&&(identical(other.cost, _this.cost) || other.cost == _this.cost)&&(identical(other.givesExchangePoint, _this.givesExchangePoint) || other.givesExchangePoint == _this.givesExchangePoint)&&const DeepCollectionEquality().equals(other.rates, _this.rates)&&(identical(other.duplicateConversion, _this.duplicateConversion) || other.duplicateConversion == _this.duplicateConversion)&&const DeepCollectionEquality().equals(other.exchangeTargets, _this.exchangeTargets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BannerDef;
  return Object.hash(runtimeType,_this.id,_this.kind,_this.nameKey,_this.startAtUtc,_this.endAtUtc,_this.cost,_this.givesExchangePoint,const DeepCollectionEquality().hash(_this.rates),_this.duplicateConversion,const DeepCollectionEquality().hash(_this.exchangeTargets));
}

@override
String toString() {
  final _this = this as BannerDef;
  return 'BannerDef(id: ${_this.id}, kind: ${_this.kind}, nameKey: ${_this.nameKey}, startAtUtc: ${_this.startAtUtc}, endAtUtc: ${_this.endAtUtc}, cost: ${_this.cost}, givesExchangePoint: ${_this.givesExchangePoint}, rates: ${_this.rates}, duplicateConversion: ${_this.duplicateConversion}, exchangeTargets: ${_this.exchangeTargets})';
}


}

/// @nodoc
abstract mixin class $BannerDefCopyWith<$Res>  {
  factory $BannerDefCopyWith(BannerDef value, $Res Function(BannerDef) _then) = _$BannerDefCopyWithImpl;
@useResult
$Res call({
 String id, String kind, String nameKey, DateTime? startAtUtc, DateTime? endAtUtc, BannerCost cost, bool givesExchangePoint, List<RateEntry> rates, DuplicateConversion duplicateConversion, List<String> exchangeTargets
});


$BannerCostCopyWith<$Res> get cost;$DuplicateConversionCopyWith<$Res> get duplicateConversion;

}
/// @nodoc
class _$BannerDefCopyWithImpl<$Res>
    implements $BannerDefCopyWith<$Res> {
  _$BannerDefCopyWithImpl(this._self, this._then);

  final BannerDef _self;
  final $Res Function(BannerDef) _then;

/// Create a copy of BannerDef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? nameKey = null,Object? startAtUtc = freezed,Object? endAtUtc = freezed,Object? cost = null,Object? givesExchangePoint = null,Object? rates = null,Object? duplicateConversion = null,Object? exchangeTargets = null,}) {
  return _then(BannerDef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,nameKey: null == nameKey ? _self.nameKey : nameKey // ignore: cast_nullable_to_non_nullable
as String,startAtUtc: freezed == startAtUtc ? _self.startAtUtc : startAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,endAtUtc: freezed == endAtUtc ? _self.endAtUtc : endAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as BannerCost,givesExchangePoint: null == givesExchangePoint ? _self.givesExchangePoint : givesExchangePoint // ignore: cast_nullable_to_non_nullable
as bool,rates: null == rates ? _self.rates : rates // ignore: cast_nullable_to_non_nullable
as List<RateEntry>,duplicateConversion: null == duplicateConversion ? _self.duplicateConversion : duplicateConversion // ignore: cast_nullable_to_non_nullable
as DuplicateConversion,exchangeTargets: null == exchangeTargets ? _self.exchangeTargets : exchangeTargets // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of BannerDef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BannerCostCopyWith<$Res> get cost {
  
  return $BannerCostCopyWith<$Res>(_self.cost, (value) {
    return _then(_self.copyWith(cost: value));
  });
}/// Create a copy of BannerDef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DuplicateConversionCopyWith<$Res> get duplicateConversion {
  
  return $DuplicateConversionCopyWith<$Res>(_self.duplicateConversion, (value) {
    return _then(_self.copyWith(duplicateConversion: value));
  });
}
}


/// Adds pattern-matching-related methods to [BannerDef].
extension BannerDefPatterns on BannerDef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BannerDef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BannerDef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BannerDef value)  $default,){
final _that = this;
switch (_that) {
case _BannerDef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BannerDef value)?  $default,){
final _that = this;
switch (_that) {
case _BannerDef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String kind,  String nameKey,  DateTime? startAtUtc,  DateTime? endAtUtc,  BannerCost cost,  bool givesExchangePoint,  List<RateEntry> rates,  DuplicateConversion duplicateConversion,  List<String> exchangeTargets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BannerDef() when $default != null:
return $default(_that.id,_that.kind,_that.nameKey,_that.startAtUtc,_that.endAtUtc,_that.cost,_that.givesExchangePoint,_that.rates,_that.duplicateConversion,_that.exchangeTargets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String kind,  String nameKey,  DateTime? startAtUtc,  DateTime? endAtUtc,  BannerCost cost,  bool givesExchangePoint,  List<RateEntry> rates,  DuplicateConversion duplicateConversion,  List<String> exchangeTargets)  $default,) {final _that = this;
switch (_that) {
case _BannerDef():
return $default(_that.id,_that.kind,_that.nameKey,_that.startAtUtc,_that.endAtUtc,_that.cost,_that.givesExchangePoint,_that.rates,_that.duplicateConversion,_that.exchangeTargets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String kind,  String nameKey,  DateTime? startAtUtc,  DateTime? endAtUtc,  BannerCost cost,  bool givesExchangePoint,  List<RateEntry> rates,  DuplicateConversion duplicateConversion,  List<String> exchangeTargets)?  $default,) {final _that = this;
switch (_that) {
case _BannerDef() when $default != null:
return $default(_that.id,_that.kind,_that.nameKey,_that.startAtUtc,_that.endAtUtc,_that.cost,_that.givesExchangePoint,_that.rates,_that.duplicateConversion,_that.exchangeTargets);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BannerDef implements BannerDef {
  const _BannerDef({required this.id, required this.kind, required this.nameKey, this.startAtUtc, this.endAtUtc, required this.cost, this.givesExchangePoint = false, required  List<RateEntry> rates, required this.duplicateConversion,  List<String> exchangeTargets = const <String>[]}): _rates = rates,_exchangeTargets = exchangeTargets;
  factory _BannerDef.fromJson(Map<String, dynamic> json) => _$BannerDefFromJson(json);

@override final  String id;
@override final  String kind;
@override final  String nameKey;
@override final  DateTime? startAtUtc;
@override final  DateTime? endAtUtc;
@override final  BannerCost cost;
@override@JsonKey() final  bool givesExchangePoint;
 final  List<RateEntry> _rates;
@override List<RateEntry> get rates {
  if (_rates is EqualUnmodifiableListView) return _rates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rates);
}

@override final  DuplicateConversion duplicateConversion;
 final  List<String> _exchangeTargets;
@override@JsonKey() List<String> get exchangeTargets {
  if (_exchangeTargets is EqualUnmodifiableListView) return _exchangeTargets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exchangeTargets);
}


/// Create a copy of BannerDef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BannerDefCopyWith<_BannerDef> get copyWith => __$BannerDefCopyWithImpl<_BannerDef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BannerDefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BannerDef&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.nameKey, nameKey) || other.nameKey == nameKey)&&(identical(other.startAtUtc, startAtUtc) || other.startAtUtc == startAtUtc)&&(identical(other.endAtUtc, endAtUtc) || other.endAtUtc == endAtUtc)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.givesExchangePoint, givesExchangePoint) || other.givesExchangePoint == givesExchangePoint)&&const DeepCollectionEquality().equals(other.rates, _rates)&&(identical(other.duplicateConversion, duplicateConversion) || other.duplicateConversion == duplicateConversion)&&const DeepCollectionEquality().equals(other.exchangeTargets, _exchangeTargets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,kind,nameKey,startAtUtc,endAtUtc,cost,givesExchangePoint,const DeepCollectionEquality().hash(_rates),duplicateConversion,const DeepCollectionEquality().hash(_exchangeTargets));
}

@override
String toString() {
    return 'BannerDef(id: $id, kind: $kind, nameKey: $nameKey, startAtUtc: $startAtUtc, endAtUtc: $endAtUtc, cost: $cost, givesExchangePoint: $givesExchangePoint, rates: $rates, duplicateConversion: $duplicateConversion, exchangeTargets: $exchangeTargets)';
}


}

/// @nodoc
abstract mixin class _$BannerDefCopyWith<$Res> implements $BannerDefCopyWith<$Res> {
  factory _$BannerDefCopyWith(_BannerDef value, $Res Function(_BannerDef) _then) = __$BannerDefCopyWithImpl;
@override @useResult
$Res call({
 String id, String kind, String nameKey, DateTime? startAtUtc, DateTime? endAtUtc, BannerCost cost, bool givesExchangePoint, List<RateEntry> rates, DuplicateConversion duplicateConversion, List<String> exchangeTargets
});


@override $BannerCostCopyWith<$Res> get cost;@override $DuplicateConversionCopyWith<$Res> get duplicateConversion;

}
/// @nodoc
class __$BannerDefCopyWithImpl<$Res>
    implements _$BannerDefCopyWith<$Res> {
  __$BannerDefCopyWithImpl(this._self, this._then);

  final _BannerDef _self;
  final $Res Function(_BannerDef) _then;

/// Create a copy of BannerDef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? nameKey = null,Object? startAtUtc = freezed,Object? endAtUtc = freezed,Object? cost = null,Object? givesExchangePoint = null,Object? rates = null,Object? duplicateConversion = null,Object? exchangeTargets = null,}) {
  return _then(_BannerDef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,nameKey: null == nameKey ? _self.nameKey : nameKey // ignore: cast_nullable_to_non_nullable
as String,startAtUtc: freezed == startAtUtc ? _self.startAtUtc : startAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,endAtUtc: freezed == endAtUtc ? _self.endAtUtc : endAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as BannerCost,givesExchangePoint: null == givesExchangePoint ? _self.givesExchangePoint : givesExchangePoint // ignore: cast_nullable_to_non_nullable
as bool,rates: null == rates ? _self._rates : rates // ignore: cast_nullable_to_non_nullable
as List<RateEntry>,duplicateConversion: null == duplicateConversion ? _self.duplicateConversion : duplicateConversion // ignore: cast_nullable_to_non_nullable
as DuplicateConversion,exchangeTargets: null == exchangeTargets ? _self._exchangeTargets : exchangeTargets // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of BannerDef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BannerCostCopyWith<$Res> get cost {
  
  return $BannerCostCopyWith<$Res>(_self.cost, (value) {
    return _then(_self.copyWith(cost: value));
  });
}/// Create a copy of BannerDef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DuplicateConversionCopyWith<$Res> get duplicateConversion {
  
  return $DuplicateConversionCopyWith<$Res>(_self.duplicateConversion, (value) {
    return _then(_self.copyWith(duplicateConversion: value));
  });
}
}


/// @nodoc
mixin _$GachaExchangeRule {

 int get pointPerPull; int get requiredPoints; bool get carryOver;
/// Create a copy of GachaExchangeRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GachaExchangeRuleCopyWith<GachaExchangeRule> get copyWith => _$GachaExchangeRuleCopyWithImpl<GachaExchangeRule>(this as GachaExchangeRule, _$identity);

  /// Serializes this GachaExchangeRule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GachaExchangeRule;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GachaExchangeRule&&(identical(other.pointPerPull, _this.pointPerPull) || other.pointPerPull == _this.pointPerPull)&&(identical(other.requiredPoints, _this.requiredPoints) || other.requiredPoints == _this.requiredPoints)&&(identical(other.carryOver, _this.carryOver) || other.carryOver == _this.carryOver));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GachaExchangeRule;
  return Object.hash(runtimeType,_this.pointPerPull,_this.requiredPoints,_this.carryOver);
}

@override
String toString() {
  final _this = this as GachaExchangeRule;
  return 'GachaExchangeRule(pointPerPull: ${_this.pointPerPull}, requiredPoints: ${_this.requiredPoints}, carryOver: ${_this.carryOver})';
}


}

/// @nodoc
abstract mixin class $GachaExchangeRuleCopyWith<$Res>  {
  factory $GachaExchangeRuleCopyWith(GachaExchangeRule value, $Res Function(GachaExchangeRule) _then) = _$GachaExchangeRuleCopyWithImpl;
@useResult
$Res call({
 int pointPerPull, int requiredPoints, bool carryOver
});




}
/// @nodoc
class _$GachaExchangeRuleCopyWithImpl<$Res>
    implements $GachaExchangeRuleCopyWith<$Res> {
  _$GachaExchangeRuleCopyWithImpl(this._self, this._then);

  final GachaExchangeRule _self;
  final $Res Function(GachaExchangeRule) _then;

/// Create a copy of GachaExchangeRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pointPerPull = null,Object? requiredPoints = null,Object? carryOver = null,}) {
  return _then(GachaExchangeRule(
pointPerPull: null == pointPerPull ? _self.pointPerPull : pointPerPull // ignore: cast_nullable_to_non_nullable
as int,requiredPoints: null == requiredPoints ? _self.requiredPoints : requiredPoints // ignore: cast_nullable_to_non_nullable
as int,carryOver: null == carryOver ? _self.carryOver : carryOver // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GachaExchangeRule].
extension GachaExchangeRulePatterns on GachaExchangeRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GachaExchangeRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GachaExchangeRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GachaExchangeRule value)  $default,){
final _that = this;
switch (_that) {
case _GachaExchangeRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GachaExchangeRule value)?  $default,){
final _that = this;
switch (_that) {
case _GachaExchangeRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int pointPerPull,  int requiredPoints,  bool carryOver)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GachaExchangeRule() when $default != null:
return $default(_that.pointPerPull,_that.requiredPoints,_that.carryOver);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int pointPerPull,  int requiredPoints,  bool carryOver)  $default,) {final _that = this;
switch (_that) {
case _GachaExchangeRule():
return $default(_that.pointPerPull,_that.requiredPoints,_that.carryOver);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int pointPerPull,  int requiredPoints,  bool carryOver)?  $default,) {final _that = this;
switch (_that) {
case _GachaExchangeRule() when $default != null:
return $default(_that.pointPerPull,_that.requiredPoints,_that.carryOver);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GachaExchangeRule implements GachaExchangeRule {
  const _GachaExchangeRule({required this.pointPerPull, required this.requiredPoints, this.carryOver = true});
  factory _GachaExchangeRule.fromJson(Map<String, dynamic> json) => _$GachaExchangeRuleFromJson(json);

@override final  int pointPerPull;
@override final  int requiredPoints;
@override@JsonKey() final  bool carryOver;

/// Create a copy of GachaExchangeRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GachaExchangeRuleCopyWith<_GachaExchangeRule> get copyWith => __$GachaExchangeRuleCopyWithImpl<_GachaExchangeRule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GachaExchangeRuleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GachaExchangeRule&&(identical(other.pointPerPull, pointPerPull) || other.pointPerPull == pointPerPull)&&(identical(other.requiredPoints, requiredPoints) || other.requiredPoints == requiredPoints)&&(identical(other.carryOver, carryOver) || other.carryOver == carryOver));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,pointPerPull,requiredPoints,carryOver);
}

@override
String toString() {
    return 'GachaExchangeRule(pointPerPull: $pointPerPull, requiredPoints: $requiredPoints, carryOver: $carryOver)';
}


}

/// @nodoc
abstract mixin class _$GachaExchangeRuleCopyWith<$Res> implements $GachaExchangeRuleCopyWith<$Res> {
  factory _$GachaExchangeRuleCopyWith(_GachaExchangeRule value, $Res Function(_GachaExchangeRule) _then) = __$GachaExchangeRuleCopyWithImpl;
@override @useResult
$Res call({
 int pointPerPull, int requiredPoints, bool carryOver
});




}
/// @nodoc
class __$GachaExchangeRuleCopyWithImpl<$Res>
    implements _$GachaExchangeRuleCopyWith<$Res> {
  __$GachaExchangeRuleCopyWithImpl(this._self, this._then);

  final _GachaExchangeRule _self;
  final $Res Function(_GachaExchangeRule) _then;

/// Create a copy of GachaExchangeRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pointPerPull = null,Object? requiredPoints = null,Object? carryOver = null,}) {
  return _then(_GachaExchangeRule(
pointPerPull: null == pointPerPull ? _self.pointPerPull : pointPerPull // ignore: cast_nullable_to_non_nullable
as int,requiredPoints: null == requiredPoints ? _self.requiredPoints : requiredPoints // ignore: cast_nullable_to_non_nullable
as int,carryOver: null == carryOver ? _self.carryOver : carryOver // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$BannerCatalog {

 List<BannerDef> get banners; GachaExchangeRule get exchange;
/// Create a copy of BannerCatalog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BannerCatalogCopyWith<BannerCatalog> get copyWith => _$BannerCatalogCopyWithImpl<BannerCatalog>(this as BannerCatalog, _$identity);

  /// Serializes this BannerCatalog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BannerCatalog;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BannerCatalog&&const DeepCollectionEquality().equals(other.banners, _this.banners)&&(identical(other.exchange, _this.exchange) || other.exchange == _this.exchange));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BannerCatalog;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.banners),_this.exchange);
}

@override
String toString() {
  final _this = this as BannerCatalog;
  return 'BannerCatalog(banners: ${_this.banners}, exchange: ${_this.exchange})';
}


}

/// @nodoc
abstract mixin class $BannerCatalogCopyWith<$Res>  {
  factory $BannerCatalogCopyWith(BannerCatalog value, $Res Function(BannerCatalog) _then) = _$BannerCatalogCopyWithImpl;
@useResult
$Res call({
 List<BannerDef> banners, GachaExchangeRule exchange
});


$GachaExchangeRuleCopyWith<$Res> get exchange;

}
/// @nodoc
class _$BannerCatalogCopyWithImpl<$Res>
    implements $BannerCatalogCopyWith<$Res> {
  _$BannerCatalogCopyWithImpl(this._self, this._then);

  final BannerCatalog _self;
  final $Res Function(BannerCatalog) _then;

/// Create a copy of BannerCatalog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? banners = null,Object? exchange = null,}) {
  return _then(BannerCatalog(
banners: null == banners ? _self.banners : banners // ignore: cast_nullable_to_non_nullable
as List<BannerDef>,exchange: null == exchange ? _self.exchange : exchange // ignore: cast_nullable_to_non_nullable
as GachaExchangeRule,
  ));
}
/// Create a copy of BannerCatalog
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GachaExchangeRuleCopyWith<$Res> get exchange {
  
  return $GachaExchangeRuleCopyWith<$Res>(_self.exchange, (value) {
    return _then(_self.copyWith(exchange: value));
  });
}
}


/// Adds pattern-matching-related methods to [BannerCatalog].
extension BannerCatalogPatterns on BannerCatalog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BannerCatalog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BannerCatalog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BannerCatalog value)  $default,){
final _that = this;
switch (_that) {
case _BannerCatalog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BannerCatalog value)?  $default,){
final _that = this;
switch (_that) {
case _BannerCatalog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<BannerDef> banners,  GachaExchangeRule exchange)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BannerCatalog() when $default != null:
return $default(_that.banners,_that.exchange);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<BannerDef> banners,  GachaExchangeRule exchange)  $default,) {final _that = this;
switch (_that) {
case _BannerCatalog():
return $default(_that.banners,_that.exchange);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<BannerDef> banners,  GachaExchangeRule exchange)?  $default,) {final _that = this;
switch (_that) {
case _BannerCatalog() when $default != null:
return $default(_that.banners,_that.exchange);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BannerCatalog implements BannerCatalog {
  const _BannerCatalog({ List<BannerDef> banners = const <BannerDef>[], required this.exchange}): _banners = banners;
  factory _BannerCatalog.fromJson(Map<String, dynamic> json) => _$BannerCatalogFromJson(json);

 final  List<BannerDef> _banners;
@override@JsonKey() List<BannerDef> get banners {
  if (_banners is EqualUnmodifiableListView) return _banners;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_banners);
}

@override final  GachaExchangeRule exchange;

/// Create a copy of BannerCatalog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BannerCatalogCopyWith<_BannerCatalog> get copyWith => __$BannerCatalogCopyWithImpl<_BannerCatalog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BannerCatalogToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BannerCatalog&&const DeepCollectionEquality().equals(other.banners, _banners)&&(identical(other.exchange, exchange) || other.exchange == exchange));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_banners),exchange);
}

@override
String toString() {
    return 'BannerCatalog(banners: $banners, exchange: $exchange)';
}


}

/// @nodoc
abstract mixin class _$BannerCatalogCopyWith<$Res> implements $BannerCatalogCopyWith<$Res> {
  factory _$BannerCatalogCopyWith(_BannerCatalog value, $Res Function(_BannerCatalog) _then) = __$BannerCatalogCopyWithImpl;
@override @useResult
$Res call({
 List<BannerDef> banners, GachaExchangeRule exchange
});


@override $GachaExchangeRuleCopyWith<$Res> get exchange;

}
/// @nodoc
class __$BannerCatalogCopyWithImpl<$Res>
    implements _$BannerCatalogCopyWith<$Res> {
  __$BannerCatalogCopyWithImpl(this._self, this._then);

  final _BannerCatalog _self;
  final $Res Function(_BannerCatalog) _then;

/// Create a copy of BannerCatalog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? banners = null,Object? exchange = null,}) {
  return _then(_BannerCatalog(
banners: null == banners ? _self._banners : banners // ignore: cast_nullable_to_non_nullable
as List<BannerDef>,exchange: null == exchange ? _self.exchange : exchange // ignore: cast_nullable_to_non_nullable
as GachaExchangeRule,
  ));
}

/// Create a copy of BannerCatalog
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GachaExchangeRuleCopyWith<$Res> get exchange {
  
  return $GachaExchangeRuleCopyWith<$Res>(_self.exchange, (value) {
    return _then(_self.copyWith(exchange: value));
  });
}
}

// dart format on
