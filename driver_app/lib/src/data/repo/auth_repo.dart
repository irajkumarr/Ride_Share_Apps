import 'package:driver_app/src/data/local/auth_local_data_source.dart';
import 'package:driver_app/src/data/remote/auth_api_service.dart';
import 'package:driver_app/src/data/remote/dto/user_dto.dart';
import 'package:flutter/material.dart';
import 'package:shared_core/core/api/api_response.dart';
import 'package:shared_core/core/error/exceptions.dart';

class AuthRepo {
  AuthRepo({required this._api, required this._local});

  final AuthApiService _api;
  final AuthLocalDataSource _local;

  Future<Result<UserDataDto>> getCurrentDriver() async {
    final result = await _local.getCachedDriver();

    if (result == null) {
      return const ResultError('No signed-in driver was found.');
    }

    return ResultSuccess(result);
  }

  Future<UserDataDto> login({
    required String phone,
    required String password,
    required String fcmToken,
  }) async {
    final response = await _api.login(
      phone: phone,
      password: password,
      fcmToken: fcmToken,
    );
    final user = response.data;

    // Role validation: Only DRIVER can access the Driver App
    final role = user?.role?.toUpperCase();
    if (role != 'DRIVER') {
      await _local.clear();
      throw UnauthorizedException(
        message: 'Access denied. Only registered drivers can log in to Driver Partner App.',
      );
    }
    await _local.saveTokens(accessToken: user?.token ?? '');
    if (user != null) {
      await _local.cacheDriver(user);
    }
    await _local.setLoggedIn(true);

    return user!;
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
    if (response.data != null) {
      await _local.cacheDriver(response.data!);
    }
    await _local.setLoggedIn(true);

    return response.data!;
  }

  Future<UserDataDto> getCurrentUser() async {
    final response = await _api.getCurrentUser();
    if (response.data != null) {
      await _local.cacheDriver(response.data!);
    }
    return response.data!;
  }

  Future<void> logout() async {
    await _local.clear();
  }
}
