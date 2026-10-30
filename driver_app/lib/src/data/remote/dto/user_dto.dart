import 'package:freezed_annotation/freezed_annotation.dart';

part '../../../../gen/src/data/remote/dto/user_dto.freezed.dart';
part '../../../../gen/src/data/remote/dto/user_dto.g.dart';

@freezed
abstract class UserDto with _$UserDto {
  const factory UserDto({bool? success, String? message, UserDataDto? data}) =
      _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}

@freezed
abstract class UserDataDto with _$UserDataDto {
  const factory UserDataDto({
    String? token,
    String? fullName,
    String? email,
    String? phone,
    String? role,
    String? status,
    String? id,
    double? rating,
    int? totalRides,
  }) = _UserDataDto;

  factory UserDataDto.fromJson(Map<String, dynamic> json) =>
      _$UserDataDtoFromJson(json);
}
