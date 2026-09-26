import 'package:rider_app/src/data/local/auth_local_data_source.dart';
import 'package:rider_app/src/data/remote/auth_api_service.dart';
import 'package:rider_app/src/data/remote/dto/user_dto.dart';
import 'package:shared_core/core/api/api_response.dart';

class AuthRepo {
  AuthRepo({required this._api, required this._local});

  final AuthApiService _api;
  final AuthLocalDataSource _local;

  Future<Result<UserDataDto>> getCurrentUser() async {
    final result = await _local.getCachedUser();

    if (result == null) {
      return const ResultError('No signed-in user was found.');
    }

    return ResultSuccess(result);
  }

  Future<UserDataDto> fetchCurrentUser() async {
    final response = await _api.getCurrentUser();
    if (response.data != null) {
      await _local.cacheUser(response.data!);
    }
    return response.data!;
  }

  Future<UserDataDto> login({
    required String phone,
    required String password,
    required String fcmToken,
  }) async {
    final response = await _api.login(phone: phone, password: password,fcmToken: fcmToken);

    await _local.saveTokens(accessToken: response.data?.token ?? '');
    await _local.cacheUser(response.data!);
    await _local.setLoggedIn(true);

    return response.data!;
  }

  Future<UserDataDto> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _api.register(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
    );
    await _local.saveTokens(accessToken: response.data?.token ?? '');
    await _local.cacheUser(response.data!);
    await _local.setLoggedIn(true);

    return response.data!;
  }

  Future<void> logout() async {
    await _local.clear();
  }
}
