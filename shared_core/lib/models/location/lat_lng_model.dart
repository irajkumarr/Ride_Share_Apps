import 'package:equatable/equatable.dart';

/// Represents geographic coordinates with optional altitude, heading, speed, and accuracy.
class LatLngModel extends Equatable {
  final double latitude;
  final double longitude;
  final double? heading;
  final double? speed;
  final double? altitude;
  final double? accuracy;

  const LatLngModel({
    required this.latitude,
    required this.longitude,
    this.heading,
    this.speed,
    this.altitude,
    this.accuracy,
  });

  factory LatLngModel.fromJson(Map<String, dynamic> json) {
    return LatLngModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (heading != null) 'heading': heading,
      if (speed != null) 'speed': speed,
      if (altitude != null) 'altitude': altitude,
      if (accuracy != null) 'accuracy': accuracy,
    };
  }

  LatLngModel copyWith({
    double? latitude,
    double? longitude,
    double? heading,
    double? speed,
    double? altitude,
    double? accuracy,
  }) {
    return LatLngModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heading: heading ?? this.heading,
      speed: speed ?? this.speed,
      altitude: altitude ?? this.altitude,
      accuracy: accuracy ?? this.accuracy,
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, heading, speed, altitude, accuracy];
}
