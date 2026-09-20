// import 'package:jci_app/src/config/env/env.dart';
// import 'package:jci_app/src/core/api/api_response.dart';
// import 'package:jci_app/src/data/local/auth_local_data_source.dart';
// import 'package:jci_app/src/data/remote/auth_api_service.dart';
// import 'package:jci_app/src/data/remote/dto/user_dto.dart';

// class AuthRepo {
//   AuthRepo({required this._api, required this._local});

//   final AuthApiService _api;
//   final AuthLocalDataSource _local;

//   Future<Result<UserDataDto>> getCurrentUser() async {
//     final result = await _local.getCachedUser();

//     if (result == null) {
//       return const ResultError('No signed-in user was found.');
//     }

//     return ResultSuccess(result);
//   }

//   Future<UserDataDto> login({
//     required String email,
//     required String password,
//   }) async {
//     final response = await _api.login(email: email, password: password);

//     await _local.saveTokens(accessToken: response.data?.token ?? '');
//     await _local.cacheUser(response.data!);
//     await _local.setLoggedIn(true);

//     return response.data!;
//   }

//   Future<Map<String, dynamic>> register({
//     required String fullName,
//     required String email,
//     required String phone,
//     required String password,
//   }) async {
//     final response = await _api.register(
//       fullName: fullName,
//       email: email,
//       phone: phone,
//       password: password,
//     );

//     return response;
//   }

//   Future<String?> ensureBaseUserToken() async {
//     final baseToken = await _local.getBaseUserToken();
//     if (baseToken != null && baseToken.isNotEmpty) {
//       return baseToken;
//     }
//     final response = await _api.login(
//       email: Env.baseUserEmail,
//       password: Env.baseUserPassword,
//     );
//     final token = response.data?.token;
//     if (token != null && token.isNotEmpty) {
//       await _local.saveBaseUserToken(token);
//     }
//     return token;
//   }

//   Future<void> logout() async {
//     await _local.clear();
//   }
// }
