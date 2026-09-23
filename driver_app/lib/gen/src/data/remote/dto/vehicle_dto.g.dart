// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../../../src/data/remote/dto/vehicle_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VehicleDto _$VehicleDtoFromJson(Map<String, dynamic> json) => _VehicleDto(
  id: json['id'] as String?,
  make: json['make'] as String,
  model: json['model'] as String,
  year: json['year'] as String,
  licensePlate: json['licensePlate'] as String,
  color: json['color'] as String?,
  type: json['type'] as String,
  approved: json['approved'] as bool? ?? false,
);

Map<String, dynamic> _$VehicleDtoToJson(_VehicleDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'make': instance.make,
      'model': instance.model,
      'year': instance.year,
      'licensePlate': instance.licensePlate,
      'color': instance.color,
      'type': instance.type,
      'approved': instance.approved,
    };
