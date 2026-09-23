// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../../../../src/data/remote/dto/vehicle_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VehicleDto {

 String? get id; String get make; String get model; String get year; String get licensePlate; String? get color; String get type; bool get approved;
/// Create a copy of VehicleDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VehicleDtoCopyWith<VehicleDto> get copyWith => _$VehicleDtoCopyWithImpl<VehicleDto>(this as VehicleDto, _$identity);

  /// Serializes this VehicleDto to a JSON map.
  Map<String, dynamic> toJson();




@override
String toString() {
  final _this = this as VehicleDto;
  return 'VehicleDto(id: ${_this.id}, make: ${_this.make}, model: ${_this.model}, year: ${_this.year}, licensePlate: ${_this.licensePlate}, color: ${_this.color}, type: ${_this.type}, approved: ${_this.approved})';
}


}

/// @nodoc
abstract mixin class $VehicleDtoCopyWith<$Res>  {
  factory $VehicleDtoCopyWith(VehicleDto value, $Res Function(VehicleDto) _then) = _$VehicleDtoCopyWithImpl;
@useResult
$Res call({
 String? id, String make, String model, String year, String licensePlate, String? color, String type, bool approved
});




}
/// @nodoc
class _$VehicleDtoCopyWithImpl<$Res>
    implements $VehicleDtoCopyWith<$Res> {
  _$VehicleDtoCopyWithImpl(this._self, this._then);

  final VehicleDto _self;
  final $Res Function(VehicleDto) _then;

/// Create a copy of VehicleDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? make = null,Object? model = null,Object? year = null,Object? licensePlate = null,Object? color = freezed,Object? type = null,Object? approved = null,}) {
  return _then(VehicleDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,make: null == make ? _self.make : make // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String,licensePlate: null == licensePlate ? _self.licensePlate : licensePlate // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,approved: null == approved ? _self.approved : approved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [VehicleDto].
extension VehicleDtoPatterns on VehicleDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VehicleDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VehicleDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VehicleDto value)  $default,){
final _that = this;
switch (_that) {
case _VehicleDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VehicleDto value)?  $default,){
final _that = this;
switch (_that) {
case _VehicleDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String make,  String model,  String year,  String licensePlate,  String? color,  String type,  bool approved)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VehicleDto() when $default != null:
return $default(_that.id,_that.make,_that.model,_that.year,_that.licensePlate,_that.color,_that.type,_that.approved);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String make,  String model,  String year,  String licensePlate,  String? color,  String type,  bool approved)  $default,) {final _that = this;
switch (_that) {
case _VehicleDto():
return $default(_that.id,_that.make,_that.model,_that.year,_that.licensePlate,_that.color,_that.type,_that.approved);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String make,  String model,  String year,  String licensePlate,  String? color,  String type,  bool approved)?  $default,) {final _that = this;
switch (_that) {
case _VehicleDto() when $default != null:
return $default(_that.id,_that.make,_that.model,_that.year,_that.licensePlate,_that.color,_that.type,_that.approved);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VehicleDto implements VehicleDto {
  const _VehicleDto({this.id, required this.make, required this.model, required this.year, required this.licensePlate, this.color, required this.type, this.approved = false});
  factory _VehicleDto.fromJson(Map<String, dynamic> json) => _$VehicleDtoFromJson(json);

@override final  String? id;
@override final  String make;
@override final  String model;
@override final  String year;
@override final  String licensePlate;
@override final  String? color;
@override final  String type;
@override@JsonKey() final  bool approved;

/// Create a copy of VehicleDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VehicleDtoCopyWith<_VehicleDto> get copyWith => __$VehicleDtoCopyWithImpl<_VehicleDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VehicleDtoToJson(this, );
}



@override
String toString() {
    return 'VehicleDto(id: $id, make: $make, model: $model, year: $year, licensePlate: $licensePlate, color: $color, type: $type, approved: $approved)';
}


}

/// @nodoc
abstract mixin class _$VehicleDtoCopyWith<$Res> implements $VehicleDtoCopyWith<$Res> {
  factory _$VehicleDtoCopyWith(_VehicleDto value, $Res Function(_VehicleDto) _then) = __$VehicleDtoCopyWithImpl;
@override @useResult
$Res call({
 String? id, String make, String model, String year, String licensePlate, String? color, String type, bool approved
});




}
/// @nodoc
class __$VehicleDtoCopyWithImpl<$Res>
    implements _$VehicleDtoCopyWith<$Res> {
  __$VehicleDtoCopyWithImpl(this._self, this._then);

  final _VehicleDto _self;
  final $Res Function(_VehicleDto) _then;

/// Create a copy of VehicleDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? make = null,Object? model = null,Object? year = null,Object? licensePlate = null,Object? color = freezed,Object? type = null,Object? approved = null,}) {
  return _then(_VehicleDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,make: null == make ? _self.make : make // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String,licensePlate: null == licensePlate ? _self.licensePlate : licensePlate // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,approved: null == approved ? _self.approved : approved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
