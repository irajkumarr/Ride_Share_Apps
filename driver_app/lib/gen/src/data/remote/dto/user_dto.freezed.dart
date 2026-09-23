// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../../../../src/data/remote/dto/user_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserDto {

 bool? get success; String? get message; UserDataDto? get data;
/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserDtoCopyWith<UserDto> get copyWith => _$UserDtoCopyWithImpl<UserDto>(this as UserDto, _$identity);

  /// Serializes this UserDto to a JSON map.
  Map<String, dynamic> toJson();




@override
String toString() {
  final _this = this as UserDto;
  return 'UserDto(success: ${_this.success}, message: ${_this.message}, data: ${_this.data})';
}


}

/// @nodoc
abstract mixin class $UserDtoCopyWith<$Res>  {
  factory $UserDtoCopyWith(UserDto value, $Res Function(UserDto) _then) = _$UserDtoCopyWithImpl;
@useResult
$Res call({
 bool? success, String? message, UserDataDto? data
});


$UserDataDtoCopyWith<$Res>? get data;

}
/// @nodoc
class _$UserDtoCopyWithImpl<$Res>
    implements $UserDtoCopyWith<$Res> {
  _$UserDtoCopyWithImpl(this._self, this._then);

  final UserDto _self;
  final $Res Function(UserDto) _then;

/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = freezed,Object? message = freezed,Object? data = freezed,}) {
  return _then(UserDto(
success: freezed == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as UserDataDto?,
  ));
}
/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserDataDtoCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $UserDataDtoCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserDto].
extension UserDtoPatterns on UserDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserDto value)  $default,){
final _that = this;
switch (_that) {
case _UserDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserDto value)?  $default,){
final _that = this;
switch (_that) {
case _UserDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool? success,  String? message,  UserDataDto? data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserDto() when $default != null:
return $default(_that.success,_that.message,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool? success,  String? message,  UserDataDto? data)  $default,) {final _that = this;
switch (_that) {
case _UserDto():
return $default(_that.success,_that.message,_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool? success,  String? message,  UserDataDto? data)?  $default,) {final _that = this;
switch (_that) {
case _UserDto() when $default != null:
return $default(_that.success,_that.message,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserDto implements UserDto {
  const _UserDto({this.success, this.message, this.data});
  factory _UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);

@override final  bool? success;
@override final  String? message;
@override final  UserDataDto? data;

/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserDtoCopyWith<_UserDto> get copyWith => __$UserDtoCopyWithImpl<_UserDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserDtoToJson(this, );
}



@override
String toString() {
    return 'UserDto(success: $success, message: $message, data: $data)';
}


}

/// @nodoc
abstract mixin class _$UserDtoCopyWith<$Res> implements $UserDtoCopyWith<$Res> {
  factory _$UserDtoCopyWith(_UserDto value, $Res Function(_UserDto) _then) = __$UserDtoCopyWithImpl;
@override @useResult
$Res call({
 bool? success, String? message, UserDataDto? data
});


@override $UserDataDtoCopyWith<$Res>? get data;

}
/// @nodoc
class __$UserDtoCopyWithImpl<$Res>
    implements _$UserDtoCopyWith<$Res> {
  __$UserDtoCopyWithImpl(this._self, this._then);

  final _UserDto _self;
  final $Res Function(_UserDto) _then;

/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = freezed,Object? message = freezed,Object? data = freezed,}) {
  return _then(_UserDto(
success: freezed == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as UserDataDto?,
  ));
}

/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserDataDtoCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $UserDataDtoCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// @nodoc
mixin _$UserDataDto {

 String? get token; String? get fullName; String? get email; String? get phone; String? get role; String? get status; String? get id; double? get rating; int? get totalRides;
/// Create a copy of UserDataDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserDataDtoCopyWith<UserDataDto> get copyWith => _$UserDataDtoCopyWithImpl<UserDataDto>(this as UserDataDto, _$identity);

  /// Serializes this UserDataDto to a JSON map.
  Map<String, dynamic> toJson();




@override
String toString() {
  final _this = this as UserDataDto;
  return 'UserDataDto(token: ${_this.token}, fullName: ${_this.fullName}, email: ${_this.email}, phone: ${_this.phone}, role: ${_this.role}, status: ${_this.status}, id: ${_this.id}, rating: ${_this.rating}, totalRides: ${_this.totalRides})';
}


}

/// @nodoc
abstract mixin class $UserDataDtoCopyWith<$Res>  {
  factory $UserDataDtoCopyWith(UserDataDto value, $Res Function(UserDataDto) _then) = _$UserDataDtoCopyWithImpl;
@useResult
$Res call({
 String? token, String? fullName, String? email, String? phone, String? role, String? status, String? id, double? rating, int? totalRides
});




}
/// @nodoc
class _$UserDataDtoCopyWithImpl<$Res>
    implements $UserDataDtoCopyWith<$Res> {
  _$UserDataDtoCopyWithImpl(this._self, this._then);

  final UserDataDto _self;
  final $Res Function(UserDataDto) _then;

/// Create a copy of UserDataDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = freezed,Object? fullName = freezed,Object? email = freezed,Object? phone = freezed,Object? role = freezed,Object? status = freezed,Object? id = freezed,Object? rating = freezed,Object? totalRides = freezed,}) {
  return _then(UserDataDto(
token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,totalRides: freezed == totalRides ? _self.totalRides : totalRides // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserDataDto].
extension UserDataDtoPatterns on UserDataDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserDataDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserDataDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserDataDto value)  $default,){
final _that = this;
switch (_that) {
case _UserDataDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserDataDto value)?  $default,){
final _that = this;
switch (_that) {
case _UserDataDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? token,  String? fullName,  String? email,  String? phone,  String? role,  String? status,  String? id,  double? rating,  int? totalRides)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserDataDto() when $default != null:
return $default(_that.token,_that.fullName,_that.email,_that.phone,_that.role,_that.status,_that.id,_that.rating,_that.totalRides);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? token,  String? fullName,  String? email,  String? phone,  String? role,  String? status,  String? id,  double? rating,  int? totalRides)  $default,) {final _that = this;
switch (_that) {
case _UserDataDto():
return $default(_that.token,_that.fullName,_that.email,_that.phone,_that.role,_that.status,_that.id,_that.rating,_that.totalRides);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? token,  String? fullName,  String? email,  String? phone,  String? role,  String? status,  String? id,  double? rating,  int? totalRides)?  $default,) {final _that = this;
switch (_that) {
case _UserDataDto() when $default != null:
return $default(_that.token,_that.fullName,_that.email,_that.phone,_that.role,_that.status,_that.id,_that.rating,_that.totalRides);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserDataDto implements UserDataDto {
  const _UserDataDto({this.token, this.fullName, this.email, this.phone, this.role, this.status, this.id, this.rating, this.totalRides});
  factory _UserDataDto.fromJson(Map<String, dynamic> json) => _$UserDataDtoFromJson(json);

@override final  String? token;
@override final  String? fullName;
@override final  String? email;
@override final  String? phone;
@override final  String? role;
@override final  String? status;
@override final  String? id;
@override final  double? rating;
@override final  int? totalRides;

/// Create a copy of UserDataDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserDataDtoCopyWith<_UserDataDto> get copyWith => __$UserDataDtoCopyWithImpl<_UserDataDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserDataDtoToJson(this, );
}



@override
String toString() {
    return 'UserDataDto(token: $token, fullName: $fullName, email: $email, phone: $phone, role: $role, status: $status, id: $id, rating: $rating, totalRides: $totalRides)';
}


}

/// @nodoc
abstract mixin class _$UserDataDtoCopyWith<$Res> implements $UserDataDtoCopyWith<$Res> {
  factory _$UserDataDtoCopyWith(_UserDataDto value, $Res Function(_UserDataDto) _then) = __$UserDataDtoCopyWithImpl;
@override @useResult
$Res call({
 String? token, String? fullName, String? email, String? phone, String? role, String? status, String? id, double? rating, int? totalRides
});




}
/// @nodoc
class __$UserDataDtoCopyWithImpl<$Res>
    implements _$UserDataDtoCopyWith<$Res> {
  __$UserDataDtoCopyWithImpl(this._self, this._then);

  final _UserDataDto _self;
  final $Res Function(_UserDataDto) _then;

/// Create a copy of UserDataDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = freezed,Object? fullName = freezed,Object? email = freezed,Object? phone = freezed,Object? role = freezed,Object? status = freezed,Object? id = freezed,Object? rating = freezed,Object? totalRides = freezed,}) {
  return _then(_UserDataDto(
token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,totalRides: freezed == totalRides ? _self.totalRides : totalRides // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
