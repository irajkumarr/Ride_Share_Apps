import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import '../../models/location/lat_lng_model.dart';

/// Abstract service contract for device GPS and location operations.
abstract class LocationService {
  /// Checks if location services are enabled on the device.
  Future<bool> isLocationServiceEnabled();

  /// Checks current location permission.
  Future<LocationPermission> checkPermission();

  /// Requests location permission.
  Future<LocationPermission> requestPermission();

  /// Ensures that location services are enabled and permissions are granted.
  Future<bool> ensurePermission();

  /// Fetches the current location once.
  Future<LatLngModel?> getCurrentLocation({
    LocationAccuracy accuracy = LocationAccuracy.high,
  });

  /// Streams real-time location updates.
  Stream<LatLngModel> getLocationStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 5,
    int intervalDurationInSeconds = 5,
    bool enableBackgroundNotification = false,
    String notificationTitle = 'Active Driver Online',
    String notificationText = 'Tracking location in background for active ride dispatch.',
  });

  /// Calculates distance in meters between two coordinates.
  double distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  );

  /// Calculates bearing between two coordinates in degrees.
  double bearingBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  );
}

/// Geolocator-backed implementation of [LocationService].
class LocationServiceImpl implements LocationService {
  @override
  Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<LocationPermission> checkPermission() async {
    return Geolocator.checkPermission();
  }

  @override
  Future<LocationPermission> requestPermission() async {
    return Geolocator.requestPermission();
  }

  @override
  Future<bool> ensurePermission() async {
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    var permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  @override
  Future<LatLngModel?> getCurrentLocation({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    final hasPermission = await ensurePermission();
    if (!hasPermission) return null;

    final position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        timeLimit: const Duration(seconds: 15),
      ),
    );

    return LatLngModel(
      latitude: position.latitude,
      longitude: position.longitude,
      heading: position.heading,
      speed: position.speed,
      altitude: position.altitude,
      accuracy: position.accuracy,
    );
  }

  @override
  Stream<LatLngModel> getLocationStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 5,
    int intervalDurationInSeconds = 5,
    bool enableBackgroundNotification = false,
    String notificationTitle = 'Active Driver Online',
    String notificationText = 'Tracking location in background for active ride dispatch.',
  }) {
    LocationSettings locationSettings;

    if (!kIsWeb && Platform.isAndroid && enableBackgroundNotification) {
      locationSettings = AndroidSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        forceLocationManager: true,
        intervalDuration: Duration(seconds: intervalDurationInSeconds),
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: notificationTitle,
          notificationText: notificationText,
          enableWakeLock: true,
        ),
      );
    } else {
      locationSettings = LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      );
    }

    return Geolocator.getPositionStream(locationSettings: locationSettings).map(
      (pos) => LatLngModel(
        latitude: pos.latitude,
        longitude: pos.longitude,
        heading: pos.heading,
        speed: pos.speed,
        altitude: pos.altitude,
        accuracy: pos.accuracy,
      ),
    );
  }

  @override
  double distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  @override
  double bearingBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}
