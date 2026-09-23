import 'package:freezed_annotation/freezed_annotation.dart';

part '../../../../gen/src/data/remote/dto/vehicle_dto.freezed.dart';
part '../../../../gen/src/data/remote/dto/vehicle_dto.g.dart';

@freezed
abstract class VehicleDto with _$VehicleDto {
  const factory VehicleDto({
    String? id,
    required String make,
    required String model,
    required String year,
    required String licensePlate,
    String? color,
    required String type, // ECONOMY, PREMIUM, XL
    @Default(false) bool approved,
  }) = _VehicleDto;

  factory VehicleDto.fromJson(Map<String, dynamic> json) =>
      _$VehicleDtoFromJson(json);
}
