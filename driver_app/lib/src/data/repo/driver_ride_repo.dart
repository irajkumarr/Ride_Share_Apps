import 'package:driver_app/src/data/remote/driver_ride_api_service.dart';
import 'package:driver_app/src/data/remote/dto/driver_ride_history_dto.dart';
import 'package:driver_app/src/data/remote/dto/ride_dispatch_dto.dart';

class DriverRideRepo {
  DriverRideRepo({required this._api});

  final DriverRideApiService _api;

  Future<void> updateDriverStatus(String status) async {
    await _api.updateDriverStatus(status);
  }

  Future<void> pingLocation({
    required double latitude,
    required double longitude,
    double? heading,
  }) async {
    await _api.pingLocation(
      latitude: latitude,
      longitude: longitude,
      heading: heading,
    );
  }

  Future<Map<String, dynamic>> acceptRide(String rideId) async {
    return await _api.acceptRide(rideId);
  }

  Future<void> declineRide(String rideId) async {
    await _api.declineRide(rideId);
  }

  Future<String> updateRideStatus({
    required String rideId,
    required String status,
  }) async {
    return await _api.updateRideStatus(rideId: rideId, status: status);
  }

  Future<List<DriverRideHistoryDto>> getAllRidesForDriver() async {
    return await _api.getAllRidesForDriver();
  }
}

