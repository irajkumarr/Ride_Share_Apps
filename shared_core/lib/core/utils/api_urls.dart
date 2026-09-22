import '../../config/env/environment.dart';

class ApiUrls {
  static final baseURL = Environment.apiBaseUrl;
  static final register = '$baseURL/auth/register';
  static final login = '$baseURL/auth/login';
  static final getUser = '$baseURL/users';
  static final forgotPassword = '$baseURL/forgot-password';
  static final verifyOtp = '$baseURL/verify-otp';
  static final resetPassword = '$baseURL/reset-password';
  static final googleLogin = '$baseURL/auth/google';

  // Rides & Driver Location
  static final rideRequest = '$baseURL/rides/request';
  static String rideCancel(String rideId) => '$baseURL/rides/$rideId/cancel';
  static final nearbyDrivers = '$baseURL/locations/nearby';
}

