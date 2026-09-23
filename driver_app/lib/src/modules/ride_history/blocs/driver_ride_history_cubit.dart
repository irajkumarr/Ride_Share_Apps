import 'package:driver_app/src/data/remote/dto/driver_ride_history_dto.dart';
import 'package:driver_app/src/data/repo/driver_ride_repo.dart';
import 'package:shared_core/core/utils/base_cubit.dart';

abstract class DriverRideHistoryState {}

class DriverRideHistoryInitial extends DriverRideHistoryState {}

class DriverRideHistoryLoading extends DriverRideHistoryState {}

class DriverRideHistoryLoaded extends DriverRideHistoryState {
  final List<DriverRideHistoryDto> rides;
  DriverRideHistoryLoaded({required this.rides});
}

class DriverRideHistoryFailure extends DriverRideHistoryState {
  final String message;
  DriverRideHistoryFailure(this.message);
}

class DriverRideHistoryCubit extends BaseCubit<DriverRideHistoryState> {
  DriverRideHistoryCubit(this._driverRideRepo) : super(DriverRideHistoryInitial());

  final DriverRideRepo _driverRideRepo;

  Future<void> fetchRides() async {
    await safeCall(
      label: 'Fetch Driver Rides',
      call: () => _driverRideRepo.getAllRidesForDriver(),
      loading: () => DriverRideHistoryLoading(),
      success: (rides) => DriverRideHistoryLoaded(rides: rides),
      failure: (error) => DriverRideHistoryFailure(error),
    );
  }
}
