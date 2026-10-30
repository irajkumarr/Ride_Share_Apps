import 'dart:convert';

import 'package:shared_core/core/storage/local_storage_service.dart';
import 'package:shared_core/core/storage/secure_storage_service.dart';

import '../remote/dto/user_dto.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._localStorage, this._secureStorage);

  final LocalStorageService _localStorage;
  final SecureStorageService _secureStorage;

  static const String _driverKey = 'cached_driver';

  Future<void> cacheDriver(UserDataDto driver) async {
    await _localStorage.setString(
      _driverKey,
      value: jsonEncode(driver.toJson()),
    );
  }

  Future<void> setLoggedIn(bool value) async {
    await _localStorage.setBool(LocalStorageKeys.isLoggedIn, value: value);
  }

  Future<UserDataDto?> getCachedDriver() async {
    final jsonString = _localStorage.getString(_driverKey);
    if (jsonString == null) return null;
    return UserDataDto.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  Future<void> saveTokens({required String accessToken}) async {
    await _secureStorage.saveAccessToken(accessToken);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.getAccessToken();
  }

  Future<void> clear() async {
    await _secureStorage.deleteTokens();
    await _localStorage.remove(_driverKey);
    await _localStorage.setBool(LocalStorageKeys.isLoggedIn, value: false);
  }
}
