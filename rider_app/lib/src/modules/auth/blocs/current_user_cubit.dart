import 'package:rider_app/src/data/remote/dto/user_dto.dart';
import 'package:rider_app/src/data/repo/auth_repo.dart';
import 'package:shared_core/core/utils/base_cubit.dart';
import 'package:shared_core/shared_core.dart';

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
    // If we have cached user, emit immediately first
    final cachedResult = await _repo.getCurrentUser();
    cachedResult.fold(
      onSuccess: (user) {
        emit(CurrentUserSuccess(user, 'Loaded cached user'));
      },
      onError: (_) {},
    );

    // Then fetch fresh data from API
    await safeCall(
      label: 'CurrentUser',
      call: () => _repo.fetchCurrentUser(),
      loading: () => state is CurrentUserSuccess ? state : CurrentUserLoading(),
      success: (data) =>
          CurrentUserSuccess(data, 'CurrentUser fetched successfully.'),
      failure: (error) {
        if (state is CurrentUserSuccess) {
          return state; // Retain cached profile on network error
        }
        return CurrentUserFailure(error);
      },
    );
  }
}
