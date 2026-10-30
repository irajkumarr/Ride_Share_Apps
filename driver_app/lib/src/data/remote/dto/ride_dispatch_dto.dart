import 'package:freezed_annotation/freezed_annotation.dart';

part '../../../../gen/src/data/remote/dto/ride_dispatch_dto.freezed.dart';
part '../../../../gen/src/data/remote/dto/ride_dispatch_dto.g.dart';

/// Payload delivered to driver over STOMP topic `/user/queue/ride-requests`
@freezed
abstract class RideRequestPayloadDto with _$RideRequestPayloadDto {
  const factory RideRequestPayloadDto({
    required String rideId,
    String? riderName,
    required String pickupAddress,
    required String dropoffAddress,
    required double estimatedFare,
    double? distanceToPickupKm,
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng,
    String? vehicleCategory,
    double? surgeBonus,
    String? paymentType,
    double? riderRating,
    int? riderTripsCount,
    String? riderNote,
    int? estimatedDurationMin,
  }) = _RideRequestPayloadDto;

  factory RideRequestPayloadDto.fromJson(Map<String, dynamic> json) =>
      _$RideRequestPayloadDtoFromJson(json);
}

/// Status payload received over `/user/queue/ride-status` or sent via `/app/ride.status.update`
@freezed
abstract class RideStatusPayloadDto with _$RideStatusPayloadDto {
  const factory RideStatusPayloadDto({
    required String rideId,
    required String status,
    String? message,
    Map<String, dynamic>? driverData,
    Map<String, dynamic>? vehicle,
  }) = _RideStatusPayloadDto;

  factory RideStatusPayloadDto.fromJson(Map<String, dynamic> json) =>
      _$RideStatusPayloadDtoFromJson(json);
}
