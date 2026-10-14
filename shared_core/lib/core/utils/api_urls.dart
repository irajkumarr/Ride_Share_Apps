import '../../config/env/environment.dart';

class ApiUrls {
  static final baseURL = Environment.apiBaseUrl;
  static final register = '$baseURL/auth/register';
  static final login = '$baseURL/auth/login';
  static final getUser = '$baseURL/users';
  static final currentUser = '$baseURL/users/me';
  static final forgotPassword = '$baseURL/forgot-password';
  static final verifyOtp = '$baseURL/verify-otp';
  static final resetPassword = '$baseURL/reset-password';
  static final googleLogin = '$baseURL/auth/google';

  // Rides & Driver Location
  static final rideRequest = '$baseURL/rides/request';
  static String rideCancel(String rideId) => '$baseURL/rides/$rideId/cancel';
  static String rideAccept(String rideId) => '$baseURL/rides/$rideId/accept';
  static String rideDecline(String rideId) => '$baseURL/rides/$rideId/decline';
  static String rideUpdateStatus(String rideId, String status) =>
      '$baseURL/rides/$rideId/status?status=$status';
  static final driverActiveRide = '$baseURL/rides/driver/active';
  static final driverAllRides = '$baseURL/rides/driver/all';
  static final riderActiveRide = '$baseURL/rides/rider/active';
  static final riderAllRides = '$baseURL/rides/rider/all';
  static final nearbyDrivers = '$baseURL/locations/nearby';

  // Driver Location & Status
  static final driverPing = '$baseURL/locations/driver/ping';
  static String driverStatus(String status) =>
      '$baseURL/locations/driver/status?status=$status';

  // Vehicles
  static final vehicles = '$baseURL/vehicles';
  static final myVehicles = '$baseURL/vehicles/my-vehicles';
}

