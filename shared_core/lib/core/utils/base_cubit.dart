import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../error/exceptions.dart';

/// BaseCubit provides reusable helpers for Cubit state management.
///
/// It simplifies common patterns like handling loading, success, and error states
/// for asynchronous operations.
abstract class BaseCubit<State> extends Cubit<State> {
  BaseCubit(super.initialState);

  /// A reusable helper for safe asynchronous calls within a Cubit.
  ///
  /// This method automatically handles:
  /// 1. Emitting a loading state. Call [loading] to get the loading state.
  /// 2. Executing the asynchronous [call].
  /// 3. Emitting a success state with the result. Call [success] with the result.
  /// 4. Catching exceptions and emitting a failure state. Call [failure] with the error message.
  ///
  /// Example Usage:
  /// ```dart
  /// Future<void> getProfiles() async {
  ///   await safeCall(
  ///     call: () => _repo.getProfiles(),
  ///     loading: () => ProfilesLoading(),
  ///     success: (data) => ProfilesSuccess(data),
  ///     failure: (error) => ProfilesFailure(error),
  ///     label: 'GetProfiles',
  ///   );
  /// }
  /// ```
  Future<void> safeCall<T>({
    required Future<T> Function() call,
    required State Function() loading,
    required State Function(T result) success,
    required State Function(String error) failure,
    String? label,
  }) async {
    emit(loading());
    try {
      final result = await call();
      emit(success(result));
    } catch (e, st) {
      final errorMessage = e is AppException ? e.message : e.toString();

      if (label != null) {
        log('[$label] Error: $errorMessage', stackTrace: st);
      } else {
        log('Error: $errorMessage', stackTrace: st);
      }

      emit(failure(errorMessage));
    }
  }
}

// Usage
// abstract class LoginState {}

// class LoginInitial extends LoginState {}

// class LoginLoading extends LoginState {}

// class LoginSuccess extends LoginState {
//   final LoginResponse response;

//   LoginSuccess(this.response);
// }

// class LoginFailure extends LoginState {
//   final String message;

//   LoginFailure(this.message);
// }

// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../data/models/login_response.dart';
// import '../../domain/repositories/auth_repository.dart';
// import '../../../../core/base/base_cubit.dart';

// class LoginCubit extends BaseCubit<LoginState> {
//   final AuthRepository _repo;

//   LoginCubit(this._repo) : super(LoginInitial());

//   Future<void> login({
//     required String emailOrPhone,
//     required String password,
//   }) async {
//     await safeCall(
//       label: 'Login',
//       call: () => _repo.login(emailOrPhone, password),
//       loading: () => LoginLoading(),
//       success: (data) => LoginSuccess(data),
//       failure: (error) => LoginFailure(error),
//     );
//   }
// }
