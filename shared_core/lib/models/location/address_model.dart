import 'package:equatable/equatable.dart';
import 'lat_lng_model.dart';

/// Represents a formatted physical address and point of interest.
class AddressModel extends Equatable {
  final String? id;
  final String title;
  final String formattedAddress;
  final LatLngModel coordinates;
  final String? placeId;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  const AddressModel({
    this.id,
    required this.title,
    required this.formattedAddress,
    required this.coordinates,
    this.placeId,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      formattedAddress: json['formattedAddress'] as String? ?? '',
      coordinates: LatLngModel.fromJson(json['coordinates'] as Map<String, dynamic>),
      placeId: json['placeId'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'formattedAddress': formattedAddress,
      'coordinates': coordinates.toJson(),
      if (placeId != null) 'placeId': placeId,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
      if (postalCode != null) 'postalCode': postalCode,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        formattedAddress,
        coordinates,
        placeId,
        city,
        state,
        country,
        postalCode,
      ];
}
