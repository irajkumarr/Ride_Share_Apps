import 'package:driver_app/src/data/remote/dto/vehicle_dto.dart';
import 'package:driver_app/src/data/remote/vehicle_api_service.dart';

class VehicleRepo {
  VehicleRepo({required this._api});

  final VehicleApiService _api;

  Future<VehicleDto> registerVehicle(Map<String, dynamic> vehicle) async {
    return await _api.registerVehicle(vehicle);
  }

  Future<List<VehicleDto>> getMyVehicles() async {
    return await _api.getMyVehicles();
  }
}
