class DriverRideHistoryDto {
  final String? id;
  final String? status;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final String? vehicleMakeModel;
  final String? licensePlate;
  final double? estimatedFare;
  final double? finalFare;
  final double? pickupLat;
  final double? pickupLng;
  final String? pickupAddress;
  final double? dropoffLat;
  final double? dropoffLng;
  final String? dropoffAddress;
  final String? riderId;
  final String? riderName;
  final String? riderPhone;
  final String? createdAt;

  const DriverRideHistoryDto({
    this.id,
    this.status,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.vehicleMakeModel,
    this.licensePlate,
    this.estimatedFare,
    this.finalFare,
    this.pickupLat,
    this.pickupLng,
    this.pickupAddress,
    this.dropoffLat,
    this.dropoffLng,
    this.dropoffAddress,
    this.riderId,
    this.riderName,
    this.riderPhone,
    this.createdAt,
  });

  factory DriverRideHistoryDto.fromJson(Map<String, dynamic> json) {
    return DriverRideHistoryDto(
      id: json['id']?.toString(),
      status: json['status']?.toString(),
      driverId: json['driverId']?.toString(),
      driverName: json['driverName']?.toString(),
      driverPhone: json['driverPhone']?.toString(),
      vehicleMakeModel: json['vehicleMakeModel']?.toString(),
      licensePlate: json['licensePlate']?.toString(),
      estimatedFare: (json['estimatedFare'] as num?)?.toDouble(),
      finalFare: (json['finalFare'] as num?)?.toDouble(),
      pickupLat: (json['pickupLat'] as num?)?.toDouble(),
      pickupLng: (json['pickupLng'] as num?)?.toDouble(),
      pickupAddress: json['pickupAddress']?.toString(),
      dropoffLat: (json['dropoffLat'] as num?)?.toDouble(),
      dropoffLng: (json['dropoffLng'] as num?)?.toDouble(),
      dropoffAddress: json['dropoffAddress']?.toString(),
      riderId: json['riderId']?.toString(),
      riderName: json['riderName']?.toString(),
      riderPhone: json['riderPhone']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'vehicleMakeModel': vehicleMakeModel,
      'licensePlate': licensePlate,
      'estimatedFare': estimatedFare,
      'finalFare': finalFare,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'pickupAddress': pickupAddress,
      'dropoffLat': dropoffLat,
      'dropoffLng': dropoffLng,
      'dropoffAddress': dropoffAddress,
      'riderId': riderId,
      'riderName': riderName,
      'riderPhone': riderPhone,
      'createdAt': createdAt,
    };
  }
}
