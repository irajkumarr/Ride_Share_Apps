
import 'package:rider_app/src/data/repo/auth_repo.dart';
import 'package:shared_core/core/utils/base_cubit.dart';

import '../../../data/remote/dto/user_dto.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final UserDataDto user;
  final String message;
  LoginSuccess(this.user, this.message);
}

class LoginFailure extends LoginState {
  final String message;
  LoginFailure(this.message);
}

class LoginCubit extends BaseCubit<LoginState> {
  LoginCubit(this._repo) : super(LoginInitial());

  final AuthRepo _repo;

  Future<void> login({required String phone, required String password,required String fcmToken}) async {
    await safeCall(
      label: 'Login',
      call: () => _repo.login(phone: phone, password: password, fcmToken: fcmToken),
      loading: () => LoginLoading(),
      success: (data) => LoginSuccess(data, 'Login successful.'),
      failure: (error) => LoginFailure(error),
    );
  }
}
