import 'package:driver_app/src/data/remote/dto/user_dto.dart';
import 'package:driver_app/src/data/repo/auth_repo.dart';
import 'package:shared_core/core/utils/base_cubit.dart';

abstract class CurrentUserState {}

class CurrentUserInitial extends CurrentUserState {}

class CurrentUserLoading extends CurrentUserState {}

class CurrentUserSuccess extends CurrentUserState {
  final UserDataDto user;
  final String message;
  CurrentUserSuccess(this.user, this.message);
}

class CurrentUserFailure extends CurrentUserState {
  final String message;
  CurrentUserFailure(this.message);
}

class CurrentUserCubit extends BaseCubit<CurrentUserState> {
  CurrentUserCubit(this._repo) : super(CurrentUserInitial());

  final AuthRepo _repo;

  Future<void> getCurrentUser() async {
    await safeCall(
      label: 'CurrentUser',
      call: () => _repo.getCurrentUser(),
      loading: () => CurrentUserLoading(),
      success: (data) => CurrentUserSuccess(data, 'CurrentUser fetched successful.'),
      failure: (error) => CurrentUserFailure(error),
    );
  }
}
