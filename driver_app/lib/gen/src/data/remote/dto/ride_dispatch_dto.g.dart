// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../../../src/data/remote/dto/ride_dispatch_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RideRequestPayloadDto _$RideRequestPayloadDtoFromJson(
  Map<String, dynamic> json,
) => _RideRequestPayloadDto(
  rideId: json['rideId'] as String,
  riderName: json['riderName'] as String?,
  pickupAddress: json['pickupAddress'] as String,
  dropoffAddress: json['dropoffAddress'] as String,
  estimatedFare: (json['estimatedFare'] as num).toDouble(),
  distanceToPickupKm: (json['distanceToPickupKm'] as num?)?.toDouble(),
  pickupLat: (json['pickupLat'] as num?)?.toDouble(),
  pickupLng: (json['pickupLng'] as num?)?.toDouble(),
  dropoffLat: (json['dropoffLat'] as num?)?.toDouble(),
  dropoffLng: (json['dropoffLng'] as num?)?.toDouble(),
  vehicleCategory: json['vehicleCategory'] as String?,
  surgeBonus: (json['surgeBonus'] as num?)?.toDouble(),
  paymentType: json['paymentType'] as String?,
  riderRating: (json['riderRating'] as num?)?.toDouble(),
  riderTripsCount: (json['riderTripsCount'] as num?)?.toInt(),
  riderNote: json['riderNote'] as String?,
  estimatedDurationMin: (json['estimatedDurationMin'] as num?)?.toInt(),
);

Map<String, dynamic> _$RideRequestPayloadDtoToJson(
  _RideRequestPayloadDto instance,
) => <String, dynamic>{
  'rideId': instance.rideId,
  'riderName': instance.riderName,
  'pickupAddress': instance.pickupAddress,
  'dropoffAddress': instance.dropoffAddress,
  'estimatedFare': instance.estimatedFare,
  'distanceToPickupKm': instance.distanceToPickupKm,
  'pickupLat': instance.pickupLat,
  'pickupLng': instance.pickupLng,
  'dropoffLat': instance.dropoffLat,
  'dropoffLng': instance.dropoffLng,
  'vehicleCategory': instance.vehicleCategory,
  'surgeBonus': instance.surgeBonus,
  'paymentType': instance.paymentType,
  'riderRating': instance.riderRating,
  'riderTripsCount': instance.riderTripsCount,
  'riderNote': instance.riderNote,
  'estimatedDurationMin': instance.estimatedDurationMin,
};

_RideStatusPayloadDto _$RideStatusPayloadDtoFromJson(
  Map<String, dynamic> json,
) => _RideStatusPayloadDto(
  rideId: json['rideId'] as String,
  status: json['status'] as String,
  message: json['message'] as String?,
  driverData: json['driverData'] as Map<String, dynamic>?,
  vehicle: json['vehicle'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$RideStatusPayloadDtoToJson(
  _RideStatusPayloadDto instance,
) => <String, dynamic>{
  'rideId': instance.rideId,
  'status': instance.status,
  'message': instance.message,
  'driverData': instance.driverData,
  'vehicle': instance.vehicle,
};
