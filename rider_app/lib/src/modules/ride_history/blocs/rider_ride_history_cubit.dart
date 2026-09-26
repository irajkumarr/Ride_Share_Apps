import 'package:rider_app/src/data/remote/dto/rider_ride_history_dto.dart';
import 'package:rider_app/src/data/repo/ride_repo.dart';
import 'package:shared_core/core/utils/base_cubit.dart';

abstract class RiderRideHistoryState {}

class RiderRideHistoryInitial extends RiderRideHistoryState {}

class RiderRideHistoryLoading extends RiderRideHistoryState {}

class RiderRideHistoryLoaded extends RiderRideHistoryState {
  final List<RiderRideHistoryDto> rides;
  RiderRideHistoryLoaded({required this.rides});
}

class RiderRideHistoryFailure extends RiderRideHistoryState {
  final String message;
  RiderRideHistoryFailure(this.message);
}

class RiderRideHistoryCubit extends BaseCubit<RiderRideHistoryState> {
  RiderRideHistoryCubit(this._rideRepo) : super(RiderRideHistoryInitial());

  final RideRepo _rideRepo;

  Future<void> fetchRides() async {
    await safeCall(
      label: 'Fetch Rider Rides',
      call: () => _rideRepo.getAllRidesForRider(),
      loading: () => RiderRideHistoryLoading(),
      success: (rides) => RiderRideHistoryLoaded(rides: rides),
      failure: (error) => RiderRideHistoryFailure(error),
    );
  }
}
