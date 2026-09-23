// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../../../../src/data/remote/dto/ride_dispatch_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RideRequestPayloadDto {

 String get rideId; String? get riderName; String get pickupAddress; String get dropoffAddress; double get estimatedFare; double? get distanceToPickupKm; double? get pickupLat; double? get pickupLng; double? get dropoffLat; double? get dropoffLng; String? get vehicleCategory; double? get surgeBonus; String? get paymentType; double? get riderRating; int? get riderTripsCount; String? get riderNote; int? get estimatedDurationMin;
/// Create a copy of RideRequestPayloadDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideRequestPayloadDtoCopyWith<RideRequestPayloadDto> get copyWith => _$RideRequestPayloadDtoCopyWithImpl<RideRequestPayloadDto>(this as RideRequestPayloadDto, _$identity);

  /// Serializes this RideRequestPayloadDto to a JSON map.
  Map<String, dynamic> toJson();




@override
String toString() {
  final _this = this as RideRequestPayloadDto;
  return 'RideRequestPayloadDto(rideId: ${_this.rideId}, riderName: ${_this.riderName}, pickupAddress: ${_this.pickupAddress}, dropoffAddress: ${_this.dropoffAddress}, estimatedFare: ${_this.estimatedFare}, distanceToPickupKm: ${_this.distanceToPickupKm}, pickupLat: ${_this.pickupLat}, pickupLng: ${_this.pickupLng}, dropoffLat: ${_this.dropoffLat}, dropoffLng: ${_this.dropoffLng}, vehicleCategory: ${_this.vehicleCategory}, surgeBonus: ${_this.surgeBonus}, paymentType: ${_this.paymentType}, riderRating: ${_this.riderRating}, riderTripsCount: ${_this.riderTripsCount}, riderNote: ${_this.riderNote}, estimatedDurationMin: ${_this.estimatedDurationMin})';
}


}

/// @nodoc
abstract mixin class $RideRequestPayloadDtoCopyWith<$Res>  {
  factory $RideRequestPayloadDtoCopyWith(RideRequestPayloadDto value, $Res Function(RideRequestPayloadDto) _then) = _$RideRequestPayloadDtoCopyWithImpl;
@useResult
$Res call({
 String rideId, String? riderName, String pickupAddress, String dropoffAddress, double estimatedFare, double? distanceToPickupKm, double? pickupLat, double? pickupLng, double? dropoffLat, double? dropoffLng, String? vehicleCategory, double? surgeBonus, String? paymentType, double? riderRating, int? riderTripsCount, String? riderNote, int? estimatedDurationMin
});




}
/// @nodoc
class _$RideRequestPayloadDtoCopyWithImpl<$Res>
    implements $RideRequestPayloadDtoCopyWith<$Res> {
  _$RideRequestPayloadDtoCopyWithImpl(this._self, this._then);

  final RideRequestPayloadDto _self;
  final $Res Function(RideRequestPayloadDto) _then;

/// Create a copy of RideRequestPayloadDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rideId = null,Object? riderName = freezed,Object? pickupAddress = null,Object? dropoffAddress = null,Object? estimatedFare = null,Object? distanceToPickupKm = freezed,Object? pickupLat = freezed,Object? pickupLng = freezed,Object? dropoffLat = freezed,Object? dropoffLng = freezed,Object? vehicleCategory = freezed,Object? surgeBonus = freezed,Object? paymentType = freezed,Object? riderRating = freezed,Object? riderTripsCount = freezed,Object? riderNote = freezed,Object? estimatedDurationMin = freezed,}) {
  return _then(RideRequestPayloadDto(
rideId: null == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String,riderName: freezed == riderName ? _self.riderName : riderName // ignore: cast_nullable_to_non_nullable
as String?,pickupAddress: null == pickupAddress ? _self.pickupAddress : pickupAddress // ignore: cast_nullable_to_non_nullable
as String,dropoffAddress: null == dropoffAddress ? _self.dropoffAddress : dropoffAddress // ignore: cast_nullable_to_non_nullable
as String,estimatedFare: null == estimatedFare ? _self.estimatedFare : estimatedFare // ignore: cast_nullable_to_non_nullable
as double,distanceToPickupKm: freezed == distanceToPickupKm ? _self.distanceToPickupKm : distanceToPickupKm // ignore: cast_nullable_to_non_nullable
as double?,pickupLat: freezed == pickupLat ? _self.pickupLat : pickupLat // ignore: cast_nullable_to_non_nullable
as double?,pickupLng: freezed == pickupLng ? _self.pickupLng : pickupLng // ignore: cast_nullable_to_non_nullable
as double?,dropoffLat: freezed == dropoffLat ? _self.dropoffLat : dropoffLat // ignore: cast_nullable_to_non_nullable
as double?,dropoffLng: freezed == dropoffLng ? _self.dropoffLng : dropoffLng // ignore: cast_nullable_to_non_nullable
as double?,vehicleCategory: freezed == vehicleCategory ? _self.vehicleCategory : vehicleCategory // ignore: cast_nullable_to_non_nullable
as String?,surgeBonus: freezed == surgeBonus ? _self.surgeBonus : surgeBonus // ignore: cast_nullable_to_non_nullable
as double?,paymentType: freezed == paymentType ? _self.paymentType : paymentType // ignore: cast_nullable_to_non_nullable
as String?,riderRating: freezed == riderRating ? _self.riderRating : riderRating // ignore: cast_nullable_to_non_nullable
as double?,riderTripsCount: freezed == riderTripsCount ? _self.riderTripsCount : riderTripsCount // ignore: cast_nullable_to_non_nullable
as int?,riderNote: freezed == riderNote ? _self.riderNote : riderNote // ignore: cast_nullable_to_non_nullable
as String?,estimatedDurationMin: freezed == estimatedDurationMin ? _self.estimatedDurationMin : estimatedDurationMin // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [RideRequestPayloadDto].
extension RideRequestPayloadDtoPatterns on RideRequestPayloadDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideRequestPayloadDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideRequestPayloadDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideRequestPayloadDto value)  $default,){
final _that = this;
switch (_that) {
case _RideRequestPayloadDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideRequestPayloadDto value)?  $default,){
final _that = this;
switch (_that) {
case _RideRequestPayloadDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String rideId,  String? riderName,  String pickupAddress,  String dropoffAddress,  double estimatedFare,  double? distanceToPickupKm,  double? pickupLat,  double? pickupLng,  double? dropoffLat,  double? dropoffLng,  String? vehicleCategory,  double? surgeBonus,  String? paymentType,  double? riderRating,  int? riderTripsCount,  String? riderNote,  int? estimatedDurationMin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideRequestPayloadDto() when $default != null:
return $default(_that.rideId,_that.riderName,_that.pickupAddress,_that.dropoffAddress,_that.estimatedFare,_that.distanceToPickupKm,_that.pickupLat,_that.pickupLng,_that.dropoffLat,_that.dropoffLng,_that.vehicleCategory,_that.surgeBonus,_that.paymentType,_that.riderRating,_that.riderTripsCount,_that.riderNote,_that.estimatedDurationMin);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String rideId,  String? riderName,  String pickupAddress,  String dropoffAddress,  double estimatedFare,  double? distanceToPickupKm,  double? pickupLat,  double? pickupLng,  double? dropoffLat,  double? dropoffLng,  String? vehicleCategory,  double? surgeBonus,  String? paymentType,  double? riderRating,  int? riderTripsCount,  String? riderNote,  int? estimatedDurationMin)  $default,) {final _that = this;
switch (_that) {
case _RideRequestPayloadDto():
return $default(_that.rideId,_that.riderName,_that.pickupAddress,_that.dropoffAddress,_that.estimatedFare,_that.distanceToPickupKm,_that.pickupLat,_that.pickupLng,_that.dropoffLat,_that.dropoffLng,_that.vehicleCategory,_that.surgeBonus,_that.paymentType,_that.riderRating,_that.riderTripsCount,_that.riderNote,_that.estimatedDurationMin);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String rideId,  String? riderName,  String pickupAddress,  String dropoffAddress,  double estimatedFare,  double? distanceToPickupKm,  double? pickupLat,  double? pickupLng,  double? dropoffLat,  double? dropoffLng,  String? vehicleCategory,  double? surgeBonus,  String? paymentType,  double? riderRating,  int? riderTripsCount,  String? riderNote,  int? estimatedDurationMin)?  $default,) {final _that = this;
switch (_that) {
case _RideRequestPayloadDto() when $default != null:
return $default(_that.rideId,_that.riderName,_that.pickupAddress,_that.dropoffAddress,_that.estimatedFare,_that.distanceToPickupKm,_that.pickupLat,_that.pickupLng,_that.dropoffLat,_that.dropoffLng,_that.vehicleCategory,_that.surgeBonus,_that.paymentType,_that.riderRating,_that.riderTripsCount,_that.riderNote,_that.estimatedDurationMin);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RideRequestPayloadDto implements RideRequestPayloadDto {
  const _RideRequestPayloadDto({required this.rideId, this.riderName, required this.pickupAddress, required this.dropoffAddress, required this.estimatedFare, this.distanceToPickupKm, this.pickupLat, this.pickupLng, this.dropoffLat, this.dropoffLng, this.vehicleCategory, this.surgeBonus, this.paymentType, this.riderRating, this.riderTripsCount, this.riderNote, this.estimatedDurationMin});
  factory _RideRequestPayloadDto.fromJson(Map<String, dynamic> json) => _$RideRequestPayloadDtoFromJson(json);

@override final  String rideId;
@override final  String? riderName;
@override final  String pickupAddress;
@override final  String dropoffAddress;
@override final  double estimatedFare;
@override final  double? distanceToPickupKm;
@override final  double? pickupLat;
@override final  double? pickupLng;
@override final  double? dropoffLat;
@override final  double? dropoffLng;
@override final  String? vehicleCategory;
@override final  double? surgeBonus;
@override final  String? paymentType;
@override final  double? riderRating;
@override final  int? riderTripsCount;
@override final  String? riderNote;
@override final  int? estimatedDurationMin;

/// Create a copy of RideRequestPayloadDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideRequestPayloadDtoCopyWith<_RideRequestPayloadDto> get copyWith => __$RideRequestPayloadDtoCopyWithImpl<_RideRequestPayloadDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RideRequestPayloadDtoToJson(this, );
}



@override
String toString() {
    return 'RideRequestPayloadDto(rideId: $rideId, riderName: $riderName, pickupAddress: $pickupAddress, dropoffAddress: $dropoffAddress, estimatedFare: $estimatedFare, distanceToPickupKm: $distanceToPickupKm, pickupLat: $pickupLat, pickupLng: $pickupLng, dropoffLat: $dropoffLat, dropoffLng: $dropoffLng, vehicleCategory: $vehicleCategory, surgeBonus: $surgeBonus, paymentType: $paymentType, riderRating: $riderRating, riderTripsCount: $riderTripsCount, riderNote: $riderNote, estimatedDurationMin: $estimatedDurationMin)';
}


}

/// @nodoc
abstract mixin class _$RideRequestPayloadDtoCopyWith<$Res> implements $RideRequestPayloadDtoCopyWith<$Res> {
  factory _$RideRequestPayloadDtoCopyWith(_RideRequestPayloadDto value, $Res Function(_RideRequestPayloadDto) _then) = __$RideRequestPayloadDtoCopyWithImpl;
@override @useResult
$Res call({
 String rideId, String? riderName, String pickupAddress, String dropoffAddress, double estimatedFare, double? distanceToPickupKm, double? pickupLat, double? pickupLng, double? dropoffLat, double? dropoffLng, String? vehicleCategory, double? surgeBonus, String? paymentType, double? riderRating, int? riderTripsCount, String? riderNote, int? estimatedDurationMin
});




}
/// @nodoc
class __$RideRequestPayloadDtoCopyWithImpl<$Res>
    implements _$RideRequestPayloadDtoCopyWith<$Res> {
  __$RideRequestPayloadDtoCopyWithImpl(this._self, this._then);

  final _RideRequestPayloadDto _self;
  final $Res Function(_RideRequestPayloadDto) _then;

/// Create a copy of RideRequestPayloadDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rideId = null,Object? riderName = freezed,Object? pickupAddress = null,Object? dropoffAddress = null,Object? estimatedFare = null,Object? distanceToPickupKm = freezed,Object? pickupLat = freezed,Object? pickupLng = freezed,Object? dropoffLat = freezed,Object? dropoffLng = freezed,Object? vehicleCategory = freezed,Object? surgeBonus = freezed,Object? paymentType = freezed,Object? riderRating = freezed,Object? riderTripsCount = freezed,Object? riderNote = freezed,Object? estimatedDurationMin = freezed,}) {
  return _then(_RideRequestPayloadDto(
rideId: null == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String,riderName: freezed == riderName ? _self.riderName : riderName // ignore: cast_nullable_to_non_nullable
as String?,pickupAddress: null == pickupAddress ? _self.pickupAddress : pickupAddress // ignore: cast_nullable_to_non_nullable
as String,dropoffAddress: null == dropoffAddress ? _self.dropoffAddress : dropoffAddress // ignore: cast_nullable_to_non_nullable
as String,estimatedFare: null == estimatedFare ? _self.estimatedFare : estimatedFare // ignore: cast_nullable_to_non_nullable
as double,distanceToPickupKm: freezed == distanceToPickupKm ? _self.distanceToPickupKm : distanceToPickupKm // ignore: cast_nullable_to_non_nullable
as double?,pickupLat: freezed == pickupLat ? _self.pickupLat : pickupLat // ignore: cast_nullable_to_non_nullable
as double?,pickupLng: freezed == pickupLng ? _self.pickupLng : pickupLng // ignore: cast_nullable_to_non_nullable
as double?,dropoffLat: freezed == dropoffLat ? _self.dropoffLat : dropoffLat // ignore: cast_nullable_to_non_nullable
as double?,dropoffLng: freezed == dropoffLng ? _self.dropoffLng : dropoffLng // ignore: cast_nullable_to_non_nullable
as double?,vehicleCategory: freezed == vehicleCategory ? _self.vehicleCategory : vehicleCategory // ignore: cast_nullable_to_non_nullable
as String?,surgeBonus: freezed == surgeBonus ? _self.surgeBonus : surgeBonus // ignore: cast_nullable_to_non_nullable
as double?,paymentType: freezed == paymentType ? _self.paymentType : paymentType // ignore: cast_nullable_to_non_nullable
as String?,riderRating: freezed == riderRating ? _self.riderRating : riderRating // ignore: cast_nullable_to_non_nullable
as double?,riderTripsCount: freezed == riderTripsCount ? _self.riderTripsCount : riderTripsCount // ignore: cast_nullable_to_non_nullable
as int?,riderNote: freezed == riderNote ? _self.riderNote : riderNote // ignore: cast_nullable_to_non_nullable
as String?,estimatedDurationMin: freezed == estimatedDurationMin ? _self.estimatedDurationMin : estimatedDurationMin // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$RideStatusPayloadDto {

 String get rideId; String get status; String? get message; Map<String, dynamic>? get driverData; Map<String, dynamic>? get vehicle;
/// Create a copy of RideStatusPayloadDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideStatusPayloadDtoCopyWith<RideStatusPayloadDto> get copyWith => _$RideStatusPayloadDtoCopyWithImpl<RideStatusPayloadDto>(this as RideStatusPayloadDto, _$identity);

  /// Serializes this RideStatusPayloadDto to a JSON map.
  Map<String, dynamic> toJson();




@override
String toString() {
  final _this = this as RideStatusPayloadDto;
  return 'RideStatusPayloadDto(rideId: ${_this.rideId}, status: ${_this.status}, message: ${_this.message}, driverData: ${_this.driverData}, vehicle: ${_this.vehicle})';
}


}

/// @nodoc
abstract mixin class $RideStatusPayloadDtoCopyWith<$Res>  {
  factory $RideStatusPayloadDtoCopyWith(RideStatusPayloadDto value, $Res Function(RideStatusPayloadDto) _then) = _$RideStatusPayloadDtoCopyWithImpl;
@useResult
$Res call({
 String rideId, String status, String? message, Map<String, dynamic>? driverData, Map<String, dynamic>? vehicle
});




}
/// @nodoc
class _$RideStatusPayloadDtoCopyWithImpl<$Res>
    implements $RideStatusPayloadDtoCopyWith<$Res> {
  _$RideStatusPayloadDtoCopyWithImpl(this._self, this._then);

  final RideStatusPayloadDto _self;
  final $Res Function(RideStatusPayloadDto) _then;

/// Create a copy of RideStatusPayloadDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rideId = null,Object? status = null,Object? message = freezed,Object? driverData = freezed,Object? vehicle = freezed,}) {
  return _then(RideStatusPayloadDto(
rideId: null == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,driverData: freezed == driverData ? _self.driverData : driverData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,vehicle: freezed == vehicle ? _self.vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [RideStatusPayloadDto].
extension RideStatusPayloadDtoPatterns on RideStatusPayloadDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideStatusPayloadDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideStatusPayloadDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideStatusPayloadDto value)  $default,){
final _that = this;
switch (_that) {
case _RideStatusPayloadDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideStatusPayloadDto value)?  $default,){
final _that = this;
switch (_that) {
case _RideStatusPayloadDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String rideId,  String status,  String? message,  Map<String, dynamic>? driverData,  Map<String, dynamic>? vehicle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideStatusPayloadDto() when $default != null:
return $default(_that.rideId,_that.status,_that.message,_that.driverData,_that.vehicle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String rideId,  String status,  String? message,  Map<String, dynamic>? driverData,  Map<String, dynamic>? vehicle)  $default,) {final _that = this;
switch (_that) {
case _RideStatusPayloadDto():
return $default(_that.rideId,_that.status,_that.message,_that.driverData,_that.vehicle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String rideId,  String status,  String? message,  Map<String, dynamic>? driverData,  Map<String, dynamic>? vehicle)?  $default,) {final _that = this;
switch (_that) {
case _RideStatusPayloadDto() when $default != null:
return $default(_that.rideId,_that.status,_that.message,_that.driverData,_that.vehicle);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RideStatusPayloadDto implements RideStatusPayloadDto {
  const _RideStatusPayloadDto({required this.rideId, required this.status, this.message,  Map<String, dynamic>? driverData,  Map<String, dynamic>? vehicle}): _driverData = driverData,_vehicle = vehicle;
  factory _RideStatusPayloadDto.fromJson(Map<String, dynamic> json) => _$RideStatusPayloadDtoFromJson(json);

@override final  String rideId;
@override final  String status;
@override final  String? message;
 final  Map<String, dynamic>? _driverData;
@override Map<String, dynamic>? get driverData {
  final value = _driverData;
  if (value == null) return null;
  if (_driverData is EqualUnmodifiableMapView) return _driverData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _vehicle;
@override Map<String, dynamic>? get vehicle {
  final value = _vehicle;
  if (value == null) return null;
  if (_vehicle is EqualUnmodifiableMapView) return _vehicle;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of RideStatusPayloadDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideStatusPayloadDtoCopyWith<_RideStatusPayloadDto> get copyWith => __$RideStatusPayloadDtoCopyWithImpl<_RideStatusPayloadDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RideStatusPayloadDtoToJson(this, );
}



@override
String toString() {
    return 'RideStatusPayloadDto(rideId: $rideId, status: $status, message: $message, driverData: $driverData, vehicle: $vehicle)';
}


}

/// @nodoc
abstract mixin class _$RideStatusPayloadDtoCopyWith<$Res> implements $RideStatusPayloadDtoCopyWith<$Res> {
  factory _$RideStatusPayloadDtoCopyWith(_RideStatusPayloadDto value, $Res Function(_RideStatusPayloadDto) _then) = __$RideStatusPayloadDtoCopyWithImpl;
@override @useResult
$Res call({
 String rideId, String status, String? message, Map<String, dynamic>? driverData, Map<String, dynamic>? vehicle
});




}
/// @nodoc
class __$RideStatusPayloadDtoCopyWithImpl<$Res>
    implements _$RideStatusPayloadDtoCopyWith<$Res> {
  __$RideStatusPayloadDtoCopyWithImpl(this._self, this._then);

  final _RideStatusPayloadDto _self;
  final $Res Function(_RideStatusPayloadDto) _then;

/// Create a copy of RideStatusPayloadDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rideId = null,Object? status = null,Object? message = freezed,Object? driverData = freezed,Object? vehicle = freezed,}) {
  return _then(_RideStatusPayloadDto(
rideId: null == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,driverData: freezed == driverData ? _self._driverData : driverData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,vehicle: freezed == vehicle ? _self._vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
