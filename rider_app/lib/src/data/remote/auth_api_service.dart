// import 'package:jci_app/src/core/api/api_client.dart';
// import 'package:jci_app/src/core/api/interceptors/auth_interceptor.dart';
// import 'package:jci_app/src/core/utils/api_urls.dart';
// import 'package:jci_app/src/data/remote/dto/user_dto.dart';

// /// Service for handling authentication and user onboarding API requests.
// class AuthApiService {
//   /// Creates an instance of [AuthApiService] using the configured [ApiClient].
//   AuthApiService(this._apiClient);

//   final ApiClient _apiClient;

//   /// Authenticates a user with their [email] and [password].
//   ///
//   /// Sends credentials to the server endpoint without requiring an existing auth token.
//   /// Returns a [UserDto] containing authentication status and user/token payload.
//   Future<UserDto> login({
//     required String email,
//     required String password,
//   }) async {
//     final data = await _apiClient.post<Map<String, dynamic>>(
//       ApiUrls.login,
//       data: {'email': email, 'password': password},
//       options: skipAuthOptions,
//     );
//     return UserDto.fromJson(data);
//   }

//   /// Registers a new user account with [fullName], [email], [phone], and [password].
//   ///
//   /// Returns the raw server response map upon successful registration request.
//   Future<Map<String, dynamic>> register({
//     required String fullName,
//     required String email,
//     required String phone,
//     required String password,
//   }) async {
//     final data = await _apiClient.post<Map<String, dynamic>>(
//       ApiUrls.register,
//       data: {
//         'fullName': fullName,
//         'email': email,
//         'phone': phone,
//         'password': password,
//       },
//       options: skipAuthOptions,
//     );
//     return data;
//   }
// }

