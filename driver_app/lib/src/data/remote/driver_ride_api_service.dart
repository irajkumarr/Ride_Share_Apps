import 'package:driver_app/src/data/remote/dto/driver_ride_history_dto.dart';
import 'package:shared_core/core/api/api_client.dart';
import 'package:shared_core/core/utils/api_urls.dart';

/// REST API service for driver location pings, status transitions, and ride actions.
class DriverRideApiService {
  DriverRideApiService(this._apiClient);

  final ApiClient _apiClient;

  /// Updates driver online/offline status in backend.
  /// status can be: "AVAILABLE", "OFFLINE", "ON_RIDE"
  Future<void> updateDriverStatus(String status) async {
    await _apiClient.post<dynamic>(ApiUrls.driverStatus(status));
  }

  /// Pings driver current latitude, longitude, and heading.
  Future<void> pingLocation({
    required double latitude,
    required double longitude,
    double? heading,
  }) async {
    await _apiClient.post<dynamic>(
      ApiUrls.driverPing,
      data: {
        'latitude': latitude,
        'longitude': longitude,
        ...?heading != null ? {'heading': heading} : null,
      },
    );
  }

  /// Driver accepts an incoming ride dispatch.
  Future<Map<String, dynamic>> acceptRide(String rideId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiUrls.rideAccept(rideId),
    );
    return response;
  }

  /// Driver declines an incoming ride dispatch.
  Future<void> declineRide(String rideId) async {
    await _apiClient.post<dynamic>(ApiUrls.rideDecline(rideId));
  }

  /// Updates status of active ride (e.g., ARRIVED_AT_PICKUP, IN_PROGRESS, COMPLETED).
  Future<String> updateRideStatus({
    // Future<RideStatusPayloadDto> updateRideStatus({
    required String rideId,
    required String status,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiUrls.rideUpdateStatus(rideId, status),
    );
    return response['message'] as String;
  }

  /// Gets the currently active ride for this driver, if any (ACCEPTED, ARRIVED, IN_PROGRESS).
  Future<Map<String, dynamic>?> getActiveRide() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiUrls.driverActiveRide,
      );
      if (response != null && response['id'] != null) {
        return response;
      }
      return null;
    } catch (e) {}
  }

  /// Gets all rides (history & ongoing) for the authenticated driver.
  Future<List<DriverRideHistoryDto>> getAllRidesForDriver() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiUrls.driverAllRides,
    );
    final responseList = response['data'] as List<dynamic>?;
    return (responseList ?? [])
        .map((e) => DriverRideHistoryDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
