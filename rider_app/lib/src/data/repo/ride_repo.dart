import 'package:shared_core/shared_core.dart';
import '../remote/ride_api_service.dart';

class RideRepo {
  final RideApiService _api;

  RideRepo({required RideApiService api}) : _api = api;

  Future<RouteModel> getRouteBetweenCoordinates({
    required LatLngModel origin,
    required LatLngModel destination,
  }) {
    return _api.getRouteBetweenCoordinates(
      origin: origin,
      destination: destination,
    );
  }

  Future<RideBookingModel> requestRide(RideBookingModel request) {
    return _api.createBookingRequest(request);
  }

  Future<String?> cancelRide(String rideId) {
    return _api.cancelRide(rideId);
  }
}

