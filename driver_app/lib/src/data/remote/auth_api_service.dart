import 'package:driver_app/src/data/remote/dto/user_dto.dart';
import 'package:shared_core/core/api/api_client.dart';
import 'package:shared_core/core/api/interceptors/auth_interceptor.dart';
import 'package:shared_core/core/utils/api_urls.dart';

/// Service for handling driver authentication and onboarding API requests.
class AuthApiService {
  AuthApiService(this._apiClient);

  final ApiClient _apiClient;

  /// Authenticates a driver with phone and password.
  Future<UserDto> login({
    required String phone,
    required String password,
    required String fcmToken,
  }) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      ApiUrls.login,
      data: {'phone': phone, 'password': password, 'fcmToken': fcmToken},
      options: skipAuthOptions,
    );
    return UserDto.fromJson(data);
  }

  /// Registers a new driver account with role 'DRIVER'.
  Future<UserDto> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      ApiUrls.register,
      data: {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'role': 'DRIVER',
      },
      options: skipAuthOptions,
    );
    return UserDto.fromJson(data);
  }

  /// Get current user
  Future<UserDto> getCurrentUser() async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      ApiUrls.currentUser,
    );
    return UserDto.fromJson(data);
  }
}
