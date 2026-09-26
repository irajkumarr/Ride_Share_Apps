import 'package:rider_app/src/data/remote/dto/user_dto.dart';
import 'package:shared_core/core/api/api_client.dart';
import 'package:shared_core/core/api/interceptors/auth_interceptor.dart';
import 'package:shared_core/core/utils/api_urls.dart';

/// Service for handling authentication and user onboarding API requests.
class AuthApiService {
  /// Creates an instance of [AuthApiService] using the configured [ApiClient].
  AuthApiService(this._apiClient);

  final ApiClient _apiClient;

  /// Authenticates a user with their [email] and [password].
  ///
  /// Sends credentials to the server endpoint without requiring an existing auth token.
  /// Returns a [UserDto] containing authentication status and user/token payload.
  Future<UserDto> login({
    required String phone,
    required String password,
    required String fcmToken,
  }) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      ApiUrls.login,
      data: {'phone': phone, 'password': password,'fcmToken': fcmToken},
      options: skipAuthOptions,
    );
    return UserDto.fromJson(data);
  }

  /// Registers a new user account with [fullName], [email], [phone], and [password].
  ///
  /// Returns the User Dto response upon successful registration request.
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
        'role': 'USER',
      },
      options: skipAuthOptions,
    );
    return UserDto.fromJson(data);
  }

  /// Gets the currently authenticated rider's profile.
  Future<UserDto> getCurrentUser() async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      ApiUrls.currentUser,
    );
    return UserDto.fromJson(data);
  }
}
