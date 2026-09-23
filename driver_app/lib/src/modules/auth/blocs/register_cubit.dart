import 'package:driver_app/src/data/repo/auth_repo.dart';
import 'package:shared_core/core/utils/base_cubit.dart';

abstract class RegisterState {}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final String message;
  RegisterSuccess(this.message);
}

class RegisterFailure extends RegisterState {
  final String message;
  RegisterFailure(this.message);
}

class RegisterCubit extends BaseCubit<RegisterState> {
  RegisterCubit(this._authRepo) : super(RegisterInitial());

  final AuthRepo _authRepo;

  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    await safeCall(
      label: 'Register',
      call: () async {
        return _authRepo.register(
          fullName: fullName,
          email: email,
          phone: phone,
          password: password,
        );
      },
      loading: () => RegisterLoading(),
      success: (data) => RegisterSuccess('Registration successful.'),
      failure: (error) => RegisterFailure(error),
    );
  }
}
