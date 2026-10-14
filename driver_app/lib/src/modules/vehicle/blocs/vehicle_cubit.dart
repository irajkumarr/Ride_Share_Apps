import 'package:driver_app/src/data/remote/dto/vehicle_dto.dart';
import 'package:driver_app/src/data/repo/vehicle_repo.dart';
import 'package:shared_core/core/utils/base_cubit.dart';

abstract class VehicleState {}

class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehicleLoaded extends VehicleState {
  final List<VehicleDto> vehicles;
  final VehicleDto? activeVehicle;
  VehicleLoaded({required this.vehicles, this.activeVehicle});
}

class VehicleActionSuccess extends VehicleState {
  final String message;
  final VehicleDto vehicle;
  VehicleActionSuccess(this.message, this.vehicle);
}

class VehicleFailure extends VehicleState {
  final String message;
  VehicleFailure(this.message);
}

class VehicleCubit extends BaseCubit<VehicleState> {
  VehicleCubit(this._vehicleRepo) : super(VehicleInitial());

  final VehicleRepo _vehicleRepo;

  Future<void> fetchMyVehicles() async {
    await safeCall(
      label: 'Fetch My Vehicles',
      call: () => _vehicleRepo.getMyVehicles(),
      loading: () => VehicleLoading(),
      success: (vehicles) => VehicleLoaded(
        vehicles: vehicles,
        activeVehicle: vehicles.isNotEmpty ? vehicles.first : null,
      ),
      failure: (error) => VehicleFailure(error),
    );
  }

  Future<void> registerVehicle(Map<String, dynamic> vehicle) async {
    await safeCall(
      label: 'Register Vehicle',
      call: () => _vehicleRepo.registerVehicle(vehicle),
      loading: () => VehicleLoading(),
      success: (data) => VehicleActionSuccess('Vehicle registered successfully!', data),
      failure: (error) => VehicleFailure(error),
    );
  }

  void selectActiveVehicle(VehicleDto vehicle) {
    final current = state;
    if (current is VehicleLoaded) {
      emit(VehicleLoaded(vehicles: current.vehicles, activeVehicle: vehicle));
    }
  }
}
