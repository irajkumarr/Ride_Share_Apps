import 'package:driver_app/src/data/remote/dto/vehicle_dto.dart';
import 'package:flutter/material.dart';
import 'package:shared_core/core/api/api_client.dart';
import 'package:shared_core/core/utils/api_urls.dart';

/// Service for managing driver vehicle registration and retrieval.
class VehicleApiService {
  VehicleApiService(this._apiClient);

  final ApiClient _apiClient;

  /// Registers a new vehicle for the authenticated driver.
  Future<VehicleDto> registerVehicle(Map<String, dynamic> vehicle) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiUrls.vehicles,
      data: vehicle,
    );
    final Map<String, dynamic> responseMap =
        response['data'] as Map<String, dynamic>;
    return VehicleDto.fromJson(responseMap);
  }

  /// Fetches vehicles owned by the authenticated driver.
  Future<List<VehicleDto>> getMyVehicles() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiUrls.myVehicles,
    );
    final List<dynamic> responseList = response['data'] as List<dynamic>;

    return responseList
        .map((item) => VehicleDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
