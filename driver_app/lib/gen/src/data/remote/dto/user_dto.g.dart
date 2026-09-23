// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../../../src/data/remote/dto/user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserDto _$UserDtoFromJson(Map<String, dynamic> json) => _UserDto(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : UserDataDto.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserDtoToJson(_UserDto instance) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

_UserDataDto _$UserDataDtoFromJson(Map<String, dynamic> json) => _UserDataDto(
  token: json['token'] as String?,
  fullName: json['fullName'] as String?,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  role: json['role'] as String?,
  status: json['status'] as String?,
  id: json['id'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  totalRides: (json['totalRides'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserDataDtoToJson(_UserDataDto instance) =>
    <String, dynamic>{
      'token': instance.token,
      'fullName': instance.fullName,
      'email': instance.email,
      'phone': instance.phone,
      'role': instance.role,
      'status': instance.status,
      'id': instance.id,
      'rating': instance.rating,
      'totalRides': instance.totalRides,
    };
