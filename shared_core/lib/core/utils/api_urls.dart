import '../../config/env/environment.dart';

class ApiUrls {
  static final baseURL = Environment.apiBaseUrl;
  static final register = '$baseURL/register';
  static final login = '$baseURL/login';
  static final getUser = '$baseURL/users';
  static final forgotPassword = '$baseURL/forgot-password';
  static final verifyOtp = '$baseURL/verify-otp';
  static final resetPassword = '$baseURL/reset-password';
  static final googleLogin = '$baseURL/auth/google';
}
