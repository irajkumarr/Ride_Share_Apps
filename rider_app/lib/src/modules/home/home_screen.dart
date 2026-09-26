import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rider_app/src/data/remote/ride_api_service.dart';
import 'package:shared_core/shared_core.dart';

import '../../data/repo/places_repo.dart';
import 'blocs/active_ride_cubit.dart';
import 'blocs/ride_search_cubit.dart';
import 'widgets/active_driver_card.dart';
import 'widgets/destination_search_sheet.dart';
import 'widgets/driver_searching_view.dart';
import 'widgets/ride_booking_sheet.dart';
import 'widgets/ridenest_illustrations.dart';
import 'widgets/trip_completed_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  LatLng _currentLocation = const LatLng(27.7172, 85.3240);
  bool _isLoadingLocation = true;
  AddressModel? _currentAddressModel;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  // Dynamic screen offsets for floating callouts and pins
  Offset? _destinationScreenOffset;
  Offset? _pickupScreenOffset;
  Offset? _driverScreenOffset;
  bool _isUpdatingOffsets = false;

  late final AnimationController _radarAnimation;
  AnimationController? _routeAnimationController;
  List<LatLng> _fullRoutePoints = [];

  final List<_RecentPlaceItem> _defaultRecents = const [
    _RecentPlaceItem(
      title: 'Ward 2',
      subtitle: 'Madhyapur Thimi Mu...pur District, Bagmati',
      etaText: '10 min',
      latLng: LatLngModel(latitude: 27.6802, longitude: 85.3855),
    ),
    _RecentPlaceItem(
      title: 'Kaushaltar - Biruwa Rd 3',
      subtitle: 'Ward 1, Suryabinayak ...pur District, Bagmati',
      etaText: '12 min',
      latLng: LatLngModel(latitude: 27.6745, longitude: 85.3720),
    ),
    _RecentPlaceItem(
      title: 'Balkot Chowk',
      subtitle: 'Bagmati, Bhaktapur ...shaltar - Biruwa Road',
      etaText: '17 min',
      latLng: LatLngModel(latitude: 27.6690, longitude: 85.3650),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _radarAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _fetchCurrentLocation();
  }

  @override
  void dispose() {
    _radarAnimation.dispose();
    _routeAnimationController?.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    final locationService = sl<LocationService>();
    final hasPermission = await locationService.ensurePermission();

    if (hasPermission) {
      final pos = await locationService.getCurrentLocation();
      if (pos != null && mounted) {
        final currentLatLng = LatLng(pos.latitude, pos.longitude);
        _currentLocation = currentLatLng;

        // Reverse geocode strictly via API
        final placesRepo = sl<PlacesRepo>();
        try {
          final resolvedAddress = await placesRepo.reverseGeocode(pos);
          if (mounted) {
            setState(() {
              _isLoadingLocation = false;
              _currentAddressModel =
                  resolvedAddress ??
                  AddressModel(
                    id: 'current_gps',
                    title: 'Current Location',
                    formattedAddress:
                        '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}',
                    coordinates: pos,
                    country: 'Nepal',
                  );
            });
            context.read<RideSearchCubit>().setPickup(_currentAddressModel!);

            _mapController?.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: _currentLocation, zoom: 16.2),
              ),
            );
            return;
          }
        } catch (_) {}
      }
    }

    if (mounted) {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _openSearchSheet({bool focusDestination = true}) {
    DestinationSearchSheet.show(
      context,
      currentPosition: _currentAddressModel?.coordinates,
      initialFocusDestination: focusDestination,
    );
  }

  void _selectQuickDestination(AddressModel place) {
    if (_currentAddressModel == null) {
      _currentAddressModel = AddressModel(
        id: 'current_gps',
        title: 'Your location',
        formattedAddress: 'Current GPS Location',
        coordinates: LatLngModel(
          latitude: _currentLocation.latitude,
          longitude: _currentLocation.longitude,
        ),
        country: 'Nepal',
      );
    }
    context.read<RideSearchCubit>().setPickup(_currentAddressModel!);
    context.read<RideSearchCubit>().setDestination(place);
  }

  void _onRoutePreviewReady(RoutePreviewReady state) {
    final pLatLng = LatLng(
      state.pickup.coordinates.latitude,
      state.pickup.coordinates.longitude,
    );
    final dLatLng = LatLng(
      state.destination.coordinates.latitude,
      state.destination.coordinates.longitude,
    );

    final polylinePoints = state.route.points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    _fullRoutePoints = polylinePoints;

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('pickup_marker'),
          position: pLatLng,
          infoWindow: InfoWindow(title: 'Pickup', snippet: state.pickup.title),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
        Marker(
          markerId: const MarkerId('destination_marker'),
          position: dLatLng,
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: state.destination.title,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };

      // Subtle dashed/faded background polyline showing complete path
      _polylines = {
        if (polylinePoints.isNotEmpty)
          Polyline(
            polylineId: const PolylineId('trip_route_backdrop'),
            points: polylinePoints,
            color: Colors.black,
            width: 7,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
      };
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitRouteBounds(polylinePoints, pickup: pLatLng, destination: dLatLng);
      _startRouteAnimation(polylinePoints);
    });
  }

  /// Progressively animates the polyline from pickup to destination for a sleek, premium experience
  void _startRouteAnimation(List<LatLng> points) {
    if (points.isEmpty) return;

    _routeAnimationController?.dispose();
    _routeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    final animation = CurvedAnimation(
      parent: _routeAnimationController!,
      curve: Curves.easeOutCubic,
    );

    animation.addListener(() {
      if (!mounted || _fullRoutePoints.isEmpty) return;
      final progress = animation.value;
      final totalPoints = _fullRoutePoints.length;
      final currentPointCount = (totalPoints * progress).ceil().clamp(
        1,
        totalPoints,
      );
      final currentPath = _fullRoutePoints.take(currentPointCount).toList();

      setState(() {
        _polylines = {
          // 1. Subtle light backdrop path
          Polyline(
            polylineId: const PolylineId('trip_route_backdrop'),
            points: _fullRoutePoints,
            color: const Color(0xFFE2E8F0),
            width: 7,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
          // 2. Animated active gradient-look polyline expanding smoothly to destination
          Polyline(
            polylineId: const PolylineId('trip_route_line'),
            points: currentPath,
            color: const Color(0xFF0F172A),
            width: 5,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        };
      });
    });

    _routeAnimationController?.forward();
  }

  void _onDriverSearching(DriverSearching state) {
    final pLatLng = LatLng(
      state.booking.pickup.coordinates.latitude,
      state.booking.pickup.coordinates.longitude,
    );
    final dLatLng = LatLng(
      state.booking.destination.coordinates.latitude,
      state.booking.destination.coordinates.longitude,
    );

    final polylinePoints = state.booking.route != null
        ? state.booking.route!.points
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList()
        : <LatLng>[pLatLng, dLatLng];

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('pickup_marker'),
          position: pLatLng,
          infoWindow: InfoWindow(
            title: 'Pickup',
            snippet: state.booking.pickup.title,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
        Marker(
          markerId: const MarkerId('destination_marker'),
          position: dLatLng,
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: state.booking.destination.title,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };

      if (polylinePoints.isNotEmpty) {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('trip_route_line'),
            points: polylinePoints,
            color: Colors.black,
            width: 5,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        };
      }
    });

    _fitRouteBounds(polylinePoints, pickup: pLatLng, destination: dLatLng);
  }

  void _onDriverUpdated(DriverAssignedState state) {
    final dPos = LatLng(
      state.driverPosition.latitude,
      state.driverPosition.longitude,
    );
    final dLatLng = LatLng(
      state.booking.destination.coordinates.latitude,
      state.booking.destination.coordinates.longitude,
    );
    final pLatLng = LatLng(
      state.booking.pickup.coordinates.latitude,
      state.booking.pickup.coordinates.longitude,
    );

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('driver_marker'),
          position: dPos,
          infoWindow: InfoWindow(
            title: state.driver.name,
            snippet:
                '${state.driver.vehicleColor} ${state.driver.vehicleModel} (${state.driver.licensePlate})',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
        Marker(
          markerId: const MarkerId('pickup_marker'),
          position: pLatLng,
          infoWindow: InfoWindow(
            title: 'Pickup',
            snippet: state.booking.pickup.title,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
        Marker(
          markerId: const MarkerId('destination_marker'),
          position: dLatLng,
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: state.booking.destination.title,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };
    });

    if (state.booking.status == RideStatus.tripInProgress) {
      // In trip: Zoom in closely on driver position with bike navigation tracking (zoom 17.5)
      // so the rider can clearly see the real-time driver bike moving along the streets
      _mapController
          ?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: dPos, zoom: 17.5, tilt: 30.0),
            ),
          )
          .then((_) {
            _updateMapScreenPositions();
          });
    } else if (state.booking.status == RideStatus.driverArriving) {
      // Driver arrived at pickup: frame tightly around pickup and driver (zoom ~17.0)
      _fitRouteBounds([dPos, pLatLng], pickup: dPos, destination: pLatLng);
    } else {
      // Driver on the way to pickup: fit driver and pickup coordinate
      _fitRouteBounds([dPos, pLatLng], pickup: dPos, destination: pLatLng);
    }
  }

  /// Dynamically computes distance in km between two [LatLng] points.
  double _calculateDistanceKm(LatLng start, LatLng end) {
    const double earthRadiusKm = 6371.0;
    final double dLat = _degreesToRadians(end.latitude - start.latitude);
    final double dLng = _degreesToRadians(end.longitude - start.longitude);

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(start.latitude)) *
            math.cos(_degreesToRadians(end.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  /// Calculates dynamic zoom level based on the distance in kilometers.
  /// Closer / shorter distances zoom in closely; longer distances scale smoothly
  /// based on continuous logarithmic projection rather than coarse step caps.
  double _calculateDynamicZoom(double distanceKm) {
    if (distanceKm <= 0.2) return 17.5;
    if (distanceKm <= 0.5) return 16.8;
    if (distanceKm <= 1.0) return 16.0;
    if (distanceKm <= 2.5) return 15.2;
    if (distanceKm <= 5.0) return 14.4;
    if (distanceKm <= 10.0) return 13.5;
    if (distanceKm <= 20.0) return 12.5;
    if (distanceKm <= 40.0) return 11.5;
    if (distanceKm <= 80.0) return 10.5;
    if (distanceKm <= 150.0) return 9.5;
    if (distanceKm <= 300.0) return 8.5;
    return 7.5;
  }

  /// Dynamically computes the height of the bottom sheet based on active ride state.
  double _getBottomSheetHeight(ActiveRideState activeState) {
    if (activeState is RoutePreviewReady) {
      return 390.0;
    } else if (activeState is DriverSearching) {
      return 290.0;
    } else if (activeState is DriverAssignedState) {
      return 350.0;
    } else if (activeState is TripCompletedState) {
      return 390.0;
    }
    return 0.0;
  }

  /// Centers the map on the route with native Google Maps bounds fitting,
  /// ensuring pickup, destination, and the entire polyline are fully visible inside
  /// the unobstructed map viewport above the bottom sheet across all distance scales and screen ratios.
  void _fitRouteBounds(
    List<LatLng> points, {
    LatLng? pickup,
    LatLng? destination,
    double bottomOffset = 0,
  }) {
    if (_mapController == null) return;

    final List<LatLng> targetPoints = [
      if (pickup != null) pickup,
      if (destination != null) destination,
      ...points,
    ];

    if (targetPoints.isEmpty) return;

    final bounds = MapUtils.boundsFromLatLngList(targetPoints);

    // With map padding dynamically configured on the GoogleMap widget
    // (with bottom equal to sheet height + safe margins, and top equal to status bar + header),
    // CameraUpdate.newLatLngBounds centers all points perfectly inside the visible viewport.
    _mapController
        ?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 48.0))
        .then((_) {
          _updateMapScreenPositions();
        });
  }

  /// Calculates the physical screen coordinates of key coordinates (pickup, destination, driver)
  /// so that floating pins and callouts track seamlessly with the map rather than being fixed.
  Future<void> _updateMapScreenPositions() async {
    if (_mapController == null || !mounted || _isUpdatingOffsets) return;
    _isUpdatingOffsets = true;

    try {
      final activeState = context.read<ActiveRideCubit>().state;
      final pixelRatio = MediaQuery.of(context).devicePixelRatio;

      LatLng? targetDest;
      LatLng? targetPickup;
      LatLng? targetDriver;

      if (activeState is RoutePreviewReady) {
        targetDest = LatLng(
          activeState.destination.coordinates.latitude,
          activeState.destination.coordinates.longitude,
        );
        targetPickup = LatLng(
          activeState.pickup.coordinates.latitude,
          activeState.pickup.coordinates.longitude,
        );
      } else if (activeState is DriverSearching) {
        targetPickup = LatLng(
          activeState.booking.pickup.coordinates.latitude,
          activeState.booking.pickup.coordinates.longitude,
        );
        targetDest = LatLng(
          activeState.booking.destination.coordinates.latitude,
          activeState.booking.destination.coordinates.longitude,
        );
      } else if (activeState is DriverAssignedState) {
        targetDriver = LatLng(
          activeState.driverPosition.latitude,
          activeState.driverPosition.longitude,
        );
        targetPickup = LatLng(
          activeState.booking.pickup.coordinates.latitude,
          activeState.booking.pickup.coordinates.longitude,
        );
        targetDest = LatLng(
          activeState.booking.destination.coordinates.latitude,
          activeState.booking.destination.coordinates.longitude,
        );
      }

      Offset? newDestOffset;
      Offset? newPickupOffset;
      Offset? newDriverOffset;

      if (targetDest != null) {
        final coord = await _mapController!.getScreenCoordinate(targetDest);
        newDestOffset = Offset(coord.x / pixelRatio, coord.y / pixelRatio);
      }
      if (targetPickup != null) {
        final coord = await _mapController!.getScreenCoordinate(targetPickup);
        newPickupOffset = Offset(coord.x / pixelRatio, coord.y / pixelRatio);
      }
      if (targetDriver != null) {
        final coord = await _mapController!.getScreenCoordinate(targetDriver);
        newDriverOffset = Offset(coord.x / pixelRatio, coord.y / pixelRatio);
      }

      if (mounted) {
        setState(() {
          _destinationScreenOffset = newDestOffset;
          _pickupScreenOffset = newPickupOffset;
          _driverScreenOffset = newDriverOffset;
        });
      }
    } catch (_) {
      // Ignore coordinate conversion errors during fast transitions
    } finally {
      _isUpdatingOffsets = false;
    }
  }

  void _clearTrip() {
    _routeAnimationController?.stop();
    _fullRoutePoints.clear();
    context.read<RideSearchCubit>().clearDestination();
    context.read<ActiveRideCubit>().cancelRide();
    setState(() {
      _markers.clear();
      _polylines.clear();
    });
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentLocation, zoom: 16.0),
      ),
    );
  }

  /// Cleanly completes and resets after a finished trip without calling cancel
  void _finishTrip() {
    _routeAnimationController?.stop();
    _fullRoutePoints.clear();
    context.read<RideSearchCubit>().clearDestination();
    context.read<ActiveRideCubit>().resetTrip();
    setState(() {
      _markers.clear();
      _polylines.clear();
    });
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentLocation, zoom: 16.0),
      ),
    );
  }

  void _onRideCancelled(String message) {
    _routeAnimationController?.stop();
    _fullRoutePoints.clear();
    context.read<RideSearchCubit>().clearDestination();
    setState(() {
      _markers.clear();
      _polylines.clear();
    });
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentLocation, zoom: 16.0),
      ),
    );
    AppAlerts.warning(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<RideSearchCubit, RideSearchState>(
          listener: (context, state) {
            if (state is RideLocationsSelected) {
              context.read<ActiveRideCubit>().prepareRoutePreview(
                pickup: state.pickup,
                destination: state.destination,
              );
            }
          },
        ),
        BlocListener<ActiveRideCubit, ActiveRideState>(
          listener: (context, state) {
            if (state is RoutePreviewReady) {
              _onRoutePreviewReady(state);
            } else if (state is DriverSearching) {
              _onDriverSearching(state);
            } else if (state is DriverAssignedState) {
              _onDriverUpdated(state);
            } else if (state is TripCompletedState) {
              // Stay on map and present TripCompletedSheet
            } else if (state is RideCancelledState) {
              _onRideCancelled(state.message);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<ActiveRideCubit, ActiveRideState>(
          builder: (context, activeState) {
            final isRideActive =
                activeState is RoutePreviewReady ||
                activeState is DriverSearching ||
                activeState is DriverAssignedState ||
                activeState is TripCompletedState;

            return Stack(
              children: [
                // 1. If a ride is active, show the interactive live Google Map
                if (isRideActive) ...[
                  CustomMapView(
                    initialCameraPosition: _currentLocation,
                    initialZoom: 15.5,
                    markers: _markers,
                    polylines: _polylines,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 55,
                      bottom: _getBottomSheetHeight(activeState) + 16,
                      left: 24,
                      right: 24,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        final currentActiveState = context
                            .read<ActiveRideCubit>()
                            .state;
                        if (currentActiveState is RoutePreviewReady) {
                          final pLatLng = LatLng(
                            currentActiveState.pickup.coordinates.latitude,
                            currentActiveState.pickup.coordinates.longitude,
                          );
                          final dLatLng = LatLng(
                            currentActiveState.destination.coordinates.latitude,
                            currentActiveState
                                .destination
                                .coordinates
                                .longitude,
                          );
                          final polylinePoints = currentActiveState.route.points
                              .map((p) => LatLng(p.latitude, p.longitude))
                              .toList();
                          _fitRouteBounds(
                            polylinePoints,
                            pickup: pLatLng,
                            destination: dLatLng,
                          );
                        } else if (currentActiveState is DriverSearching) {
                          _onDriverSearching(currentActiveState);
                        } else if (currentActiveState is DriverAssignedState) {
                          _onDriverUpdated(currentActiveState);
                        }
                        _updateMapScreenPositions();
                      });
                    },
                    onCameraMove: (position) {
                      _currentLocation = position.target;
                      _updateMapScreenPositions();
                    },
                    onCameraIdle: () {
                      _updateMapScreenPositions();
                    },
                  ),

                  // Radar rings overlay during Driver Searching state
                  if (activeState is DriverSearching) ...[
                    // Concentric expanding scanning rings originating from the pickup point
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _radarAnimation,
                          builder: (context, child) {
                            return RadarOverlayWidget(
                              animation: _radarAnimation,
                              centerOffset: _pickupScreenOffset,
                            );
                          },
                        ),
                      ),
                    ),

                    // Red Person Pin Callout anchored at Pickup Location
                    Builder(
                      builder: (context) {
                        final screenSize = MediaQuery.of(context).size;
                        final topPadding = MediaQuery.of(context).padding.top;
                        const pinWidth = 56.0;
                        const pinHeight = 74.0;

                        final double posX;
                        final double posY;

                        if (_pickupScreenOffset != null) {
                          // Center horizontally above pickup
                          posX = (_pickupScreenOffset!.dx - (pinWidth / 2))
                              .clamp(16.0, screenSize.width - pinWidth - 16.0);
                          // Place base of the pin right onto the pickup screen coordinate
                          posY = (_pickupScreenOffset!.dy - pinHeight).clamp(
                            topPadding + 65.0,
                            screenSize.height - 300.0,
                          );
                        } else {
                          // Fallback to top center if offset not yet calculated
                          posX = (screenSize.width - pinWidth) / 2;
                          posY = screenSize.height * 0.35;
                        }

                        return Positioned(
                          left: posX,
                          top: posY,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF4824),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF4824)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                              Container(
                                width: 14,
                                height: 14,
                                margin: const EdgeInsets.only(top: 6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 3.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],

                  // Floating Top Controls & Map Markers for Driver Assigned
                  if (activeState is DriverAssignedState) ...[
                    // ─────────────────────────────────────────────────────────
                    // TOP BAR CONTROLS
                    // ─────────────────────────────────────────────────────────
                    // Top Left White Circular Back Button
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 10,
                      left: 18,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xFF0F172A),
                            size: 22,
                          ),
                          onPressed: _clearTrip,
                        ),
                      ),
                    ),

                    if (activeState.booking.status ==
                        RideStatus.tripInProgress) ...[
                      // ── UI #1: ON TRIP (Trip in Progress) ──
                      // Top Center Pill Badge: 🟢 ON TRIP | BA 2 PA 4092
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        left: 76,
                        right: 76,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF062828),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.22),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'ON TRIP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '|',
                                style: TextStyle(
                                  color: Color(0xFF334155),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                activeState.driver.licensePlate.isNotEmpty
                                    ? activeState.driver.licensePlate
                                    : 'BA  2  PA  4092',
                                style: const TextStyle(
                                  color: Color(0xFF34D399),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Destination ETA Box & Flag Pin dynamically anchored over destination location
                      Builder(
                        builder: (context) {
                          final screenSize = MediaQuery.of(context).size;
                          final topPadding = MediaQuery.of(context).padding.top;
                          const boxWidth = 190.0;
                          const boxHeight = 90.0;

                          final double posX;
                          final double posY;

                          if (_destinationScreenOffset != null) {
                            posX =
                                (_destinationScreenOffset!.dx - (boxWidth / 2))
                                    .clamp(
                                      16.0,
                                      screenSize.width - boxWidth - 16.0,
                                    );
                            posY =
                                (_destinationScreenOffset!.dy - boxHeight - 8.0)
                                    .clamp(
                                      topPadding + 65.0,
                                      screenSize.height - 380.0,
                                    );
                          } else {
                            posX = screenSize.width - boxWidth - 20.0;
                            posY = topPadding + 65.0;
                          }

                          return Positioned(
                            left: posX,
                            top: posY,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.12,
                                        ),
                                        blurRadius: 14,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFFF9800),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            activeState
                                                    .booking
                                                    .destination
                                                    .title
                                                    .isNotEmpty
                                                ? activeState
                                                      .booking
                                                      .destination
                                                      .title
                                                : 'Sirjana nagar',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'ETA ${TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 6))).format(context)} (6 min)',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFFF97316),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // Destination Black Flag Pin anchored directly underneath
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F172A),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.flag_rounded,
                                      color: Color(0xFFFF9800),
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Driver Position Floating Badge: 🟢 Driver Name • 35 km/h anchored above driver
                      // if (_driverScreenOffset != null)
                      //   Builder(
                      //     builder: (context) {
                      //       final screenSize = MediaQuery.of(context).size;
                      //       final topPadding = MediaQuery.of(context)
                      //           .padding
                      //           .top;
                      //       const badgeWidth = 130.0;
                      //       final posX =
                      //           (_driverScreenOffset!.dx - (badgeWidth / 2))
                      //               .clamp(
                      //                 16.0,
                      //                 screenSize.width - badgeWidth - 16.0,
                      //               );
                      //       final posY = (_driverScreenOffset!.dy - 46.0).clamp(
                      //         topPadding + 65.0,
                      //         screenSize.height - 380.0,
                      //       );

                      //       return Positioned(
                      //         left: posX,
                      //         top: posY,
                      //         child: Container(
                      //           padding: const EdgeInsets.symmetric(
                      //             horizontal: 10,
                      //             vertical: 4,
                      //           ),
                      //           decoration: BoxDecoration(
                      //             color: const Color(0xFF0A0F1D),
                      //             borderRadius: BorderRadius.circular(14),
                      //             boxShadow: [
                      //               BoxShadow(
                      //                 color: Colors.black.withValues(
                      //                   alpha: 0.18,
                      //                 ),
                      //                 blurRadius: 8,
                      //               ),
                      //             ],
                      //           ),
                      //           child: Row(
                      //             mainAxisSize: MainAxisSize.min,
                      //             children: [
                      //               Container(
                      //                 width: 6,
                      //                 height: 6,
                      //                 decoration: const BoxDecoration(
                      //                   color: Color(0xFF10B981),
                      //                   shape: BoxShape.circle,
                      //                 ),
                      //               ),
                      //               const SizedBox(width: 5),
                      //               Text(
                      //                 activeState.driver.name.isNotEmpty
                      //                     ? activeState.driver.name
                      //                           .split(' ')
                      //                           .first
                      //                     : 'Driver',
                      //                 style: const TextStyle(
                      //                   color: Colors.white,
                      //                   fontSize: 11.5,
                      //                   fontWeight: FontWeight.w800,
                      //                 ),
                      //               ),
                      //               const Text(
                      //                 ' • 35 km/h',
                      //                 style: TextStyle(
                      //                   color: Color(0xFF94A3B8),
                      //                   fontSize: 11,
                      //                   fontWeight: FontWeight.w600,
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       );
                      //     },
                      //   ),

                      // Live Speedometer Capsule & Motorcycle Halo Marker
                      // Reasonably anchored above the active driver card
                      // Positioned(
                      //   bottom: 330,
                      //   left: 20,
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Container(
                      //         padding: const EdgeInsets.symmetric(
                      //           horizontal: 14,
                      //           vertical: 8,
                      //         ),
                      //         decoration: BoxDecoration(
                      //           color: Colors.white,
                      //           borderRadius: BorderRadius.circular(20),
                      //           boxShadow: [
                      //             BoxShadow(
                      //               color: Colors.black.withValues(alpha: 0.12),
                      //               blurRadius: 10,
                      //               offset: const Offset(0, 3),
                      //             ),
                      //           ],
                      //         ),
                      //         child: Row(
                      //           children: [
                      //             Container(
                      //               width: 7,
                      //               height: 7,
                      //               decoration: const BoxDecoration(
                      //                 color: Color(0xFF10B981),
                      //                 shape: BoxShape.circle,
                      //               ),
                      //             ),
                      //             const SizedBox(width: 6),
                      //             const Text(
                      //               '2.1 km left',
                      //               style: TextStyle(
                      //                 fontSize: 13,
                      //                 fontWeight: FontWeight.w900,
                      //                 color: Color(0xFF0F172A),
                      //               ),
                      //             ),
                      //             const SizedBox(width: 8),
                      //             const Text(
                      //               '•',
                      //               style: TextStyle(
                      //                 color: Color(0xFFCBD5E1),
                      //                 fontSize: 12,
                      //               ),
                      //             ),
                      //             const SizedBox(width: 8),
                      //             const Text(
                      //               '35 km/h',
                      //               style: TextStyle(
                      //                 fontSize: 13,
                      //                 fontWeight: FontWeight.w800,
                      //                 color: Color(0xFFF97316),
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //       const SizedBox(width: 8),
                      //       // Orange ring with black motorcycle icon
                      //       Container(
                      //         width: 44,
                      //         height: 44,
                      //         decoration: BoxDecoration(
                      //           color: const Color(0xFF0F172A),
                      //           shape: BoxShape.circle,
                      //           border: Border.all(
                      //             color: const Color(0xFFFF9800),
                      //             width: 2.5,
                      //           ),
                      //           boxShadow: [
                      //             BoxShadow(
                      //               color: const Color(0xFFFF9800)
                      //                   .withValues(alpha: 0.35),
                      //               blurRadius: 8,
                      //               offset: const Offset(0, 2),
                      //             ),
                      //           ],
                      //         ),
                      //         child: const Center(
                      //           child: Icon(
                      //             Icons.two_wheeler_rounded,
                      //             color: Color(0xFFFF9800),
                      //             size: 22,
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ] else if (activeState.booking.status ==
                        RideStatus.driverArriving) ...[
                      // ── UI #2: DRIVER ARRIVED AT PICKUP ──
                      // Top Center Pill Badge: 🟢 DRIVER ARRIVED | BA 2 PA 4092
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        left: 60,
                        right: 60,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.22),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'DRIVER ARRIVED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '|',
                                style: TextStyle(
                                  color: Color(0xFF475569),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  activeState.driver.licensePlate.isNotEmpty
                                      ? activeState.driver.licensePlate
                                      : 'BA 2 PA 4092',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF34D399),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      // ── UI #3: DRIVER ACCEPTED / ON THE WAY (Screenshot 2) ──

                      // Top Right Driver ETA Pill Badge: 🟢 3 min • BA 2 PA 4092
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 70,
                        right: 18,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A0F1D), // Dark navy capsule
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                '3 min',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '•  ${activeState.driver.licensePlate.isNotEmpty ? activeState.driver.licensePlate : 'BA 2 PA 4092'}',
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Pickup Point Location Pin dynamically anchored at pickup coordinate
                      Builder(
                        builder: (context) {
                          final screenSize = MediaQuery.of(context).size;
                          final topPadding = MediaQuery.of(context).padding.top;
                          const pinWidth = 56.0;
                          const pinHeight = 74.0;

                          final double posX;
                          final double posY;

                          if (_pickupScreenOffset != null) {
                            posX = (_pickupScreenOffset!.dx - (pinWidth / 2))
                                .clamp(
                                  16.0,
                                  screenSize.width - pinWidth - 16.0,
                                );
                            posY = (_pickupScreenOffset!.dy - pinHeight).clamp(
                              topPadding + 65.0,
                              screenSize.height - 300.0,
                            );
                          } else {
                            posX = (screenSize.width - pinWidth) / 2;
                            posY = screenSize.height * 0.35;
                          }

                          return Positioned(
                            left: posX,
                            top: posY,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF4824),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF4824)
                                            .withValues(alpha: 0.4),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.person_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 14,
                                  height: 14,
                                  margin: const EdgeInsets.only(top: 6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 3.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Approaching Red Motorcycle Marker dynamically anchored at driver position
                      Builder(
                        builder: (context) {
                          final screenSize = MediaQuery.of(context).size;
                          final topPadding = MediaQuery.of(context).padding.top;
                          const markerSize = 44.0;

                          final double posX;
                          final double posY;

                          if (_driverScreenOffset != null) {
                            posX = (_driverScreenOffset!.dx - (markerSize / 2))
                                .clamp(
                                  16.0,
                                  screenSize.width - markerSize - 16.0,
                                );
                            posY = (_driverScreenOffset!.dy - (markerSize / 2))
                                .clamp(
                                  topPadding + 65.0,
                                  screenSize.height - 300.0,
                                );
                          } else {
                            posX = screenSize.width - markerSize - 24.0;
                            posY = topPadding + 85.0;
                          }

                          return Positioned(
                            left: posX,
                            top: posY,
                            child: Container(
                              width: markerSize,
                              height: markerSize,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFFF4824),
                                  width: 2.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.two_wheeler_rounded,
                                  color: Color(0xFFFF4824),
                                  size: 22,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],

                  // Floating Top Controls for Trip Completed (Back Button, RIDE COMPLETED badge, Close X Button)
                  if (activeState is TripCompletedState) ...[
                    // Top Left Back Button
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 10,
                      left: 18,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xFF0F172A),
                            size: 22,
                          ),
                          onPressed: _finishTrip,
                        ),
                      ),
                    ),

                    // Top Right Close / X Button
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 10,
                      right: 18,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF0F172A),
                            size: 22,
                          ),
                          onPressed: _finishTrip,
                        ),
                      ),
                    ),

                    // Top Center Pill Badge: 🟢 RIDE COMPLETED • BA 2 PA 4092
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 10,
                      left: 76,
                      right: 76,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF062828,
                          ), // Deep dark spruce teal
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.22),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'RIDE COMPLETED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '•',
                              style: TextStyle(
                                color: Color(0xFF334155),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                activeState.driver?.licensePlate.isNotEmpty ==
                                        true
                                    ? activeState.driver!.licensePlate
                                    : 'BA 2 PA 4092',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF34D399),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Floating Destination ETA Callout Pin (Orange '5 MIN' badge with 'arrive at X:XX PM')
                  // Dynamically anchored above the destination marker on the map with boundary clamping
                  if (activeState is RoutePreviewReady)
                    Builder(
                      builder: (context) {
                        final screenSize = MediaQuery.of(context).size;
                        final topPadding = MediaQuery.of(context).padding.top;
                        const calloutWidth = 140.0;
                        const calloutHeight = 85.0;

                        // Calculate clamped screen position so it never overflows or collides with top/bottom bars
                        final double posX;
                        final double posY;

                        if (_destinationScreenOffset != null) {
                          // Center horizontally over the destination coordinate
                          posX =
                              (_destinationScreenOffset!.dx -
                                      (calloutWidth / 2))
                                  .clamp(
                                    16.0,
                                    screenSize.width - calloutWidth - 16.0,
                                  );
                          // Place vertically above the destination marker pin (offset upwards by callout height + pin height)
                          posY =
                              (_destinationScreenOffset!.dy -
                                      calloutHeight -
                                      14.0)
                                  .clamp(
                                    topPadding + 65.0,
                                    screenSize.height - 420.0,
                                  );
                        } else {
                          // Fallback safe position before first map render frame
                          posX = screenSize.width - calloutWidth - 20.0;
                          posY = topPadding + 75.0;
                        }

                        return Positioned(
                          left: posX,
                          top: posY,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF4824),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF4824)
                                          .withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${activeState.durationMins}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        height: 1.0,
                                      ),
                                    ),
                                    const Text(
                                      'MIN',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.12,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'arrive at ${TimeOfDay.fromDateTime(DateTime.now().add(Duration(minutes: activeState.durationMins))).format(context)}',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  // Floating Back Button (Circular white with black arrow) for Preview and Searching
                  if (activeState is! DriverAssignedState &&
                      activeState is! TripCompletedState) ...[
                    Positioned(
                      bottom: _getBottomSheetHeight(activeState) + 16,
                      left: 20,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.14),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.black,
                            size: 24,
                          ),
                          onPressed: _clearTrip,
                        ),
                      ),
                    ),
                  ],
                  // Floating GPS Recenter Target Button
                  activeState is DriverSearching ||
                          activeState is DriverAssignedState ||
                          activeState is RoutePreviewReady
                      ? Positioned(
                          bottom: _getBottomSheetHeight(activeState) + 16,
                          right: 20,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.14),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.my_location_rounded,
                                color: Colors.black,
                                size: 24,
                              ),
                              onPressed: () {
                                if (activeState is RoutePreviewReady) {
                                  final pLatLng = LatLng(
                                    activeState.pickup.coordinates.latitude,
                                    activeState.pickup.coordinates.longitude,
                                  );
                                  final dLatLng = LatLng(
                                    activeState
                                        .destination
                                        .coordinates
                                        .latitude,
                                    activeState
                                        .destination
                                        .coordinates
                                        .longitude,
                                  );
                                  final polylinePoints = activeState
                                      .route
                                      .points
                                      .map(
                                        (p) => LatLng(p.latitude, p.longitude),
                                      )
                                      .toList();
                                  _fitRouteBounds(
                                    polylinePoints,
                                    pickup: pLatLng,
                                    destination: dLatLng,
                                  );
                                } else if (activeState is DriverSearching) {
                                  _onDriverSearching(activeState);
                                } else if (activeState is DriverAssignedState) {
                                  _onDriverUpdated(activeState);
                                } else {
                                  _fetchCurrentLocation();
                                }
                              },
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                ] else ...[
                  // 2. Main Idle Redesigned RideNest Home Dashboard
                  SafeArea(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          // Top Branding Bar & Hamburger Menu
                          _buildHeader(),
                          const SizedBox(height: 6),

                          // Location Picker Pill
                          _buildLocationPill(),
                          const SizedBox(height: 18),

                          // 2x2 Service Grid (Cargo, Delivery, Bike, Rides)
                          // _buildServiceGrid(),
                          // const SizedBox(height: 22),

                          // "Where to?" rounded pill input bar
                          _buildWhereToBar(),
                          const SizedBox(height: 20),

                          // Recent Destinations List
                          _buildRecentDestinations(),
                          const SizedBox(height: 24),

                          // Promotional Banner Cards (Safe Rides, Need Help?)
                          // _buildPromoBanners(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],

                // Bottom Ride Sheet Panels for active trip states
                if (activeState is RoutePreviewReady)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: RideBookingSheet(
                      pickup:
                          statePickupFromSearch(context) ?? activeState.pickup,
                      destination:
                          stateDestinationFromSearch(context) ??
                          activeState.destination,
                      route: activeState.route,
                      distanceKm: activeState.distanceKm,
                      durationMins: activeState.durationMins,
                      onCancel: _clearTrip,
                      onConfirmBooking:
                          ({
                            required selectedTier,
                            required fareNpr,
                            required paymentMethod,
                            promoCode,
                          }) {
                            context.read<ActiveRideCubit>().bookRide(
                              pickup: activeState.pickup,
                              destination: activeState.destination,
                              route: activeState.route,
                              vehicleTier: selectedTier.name,
                              fareNpr: fareNpr,
                              paymentMethod: paymentMethod,
                              promoCode: promoCode,
                            );
                          },
                    ),
                  ),

                if (activeState is DriverSearching)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: DriverSearchingView(
                      booking: activeState.booking,
                      onCancel: _clearTrip,
                    ),
                  ),

                if (activeState is DriverAssignedState)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ActiveDriverCard(
                      booking: activeState.booking,
                      driver: activeState.driver,
                      statusText: stateTextForDriver(activeState),
                      onCancel: _clearTrip,
                    ),
                  ),

                if (activeState is TripCompletedState)
                  Positioned.fill(
                    child: TripCompletedSheet(
                      booking: activeState.booking,
                      driver: activeState.driver,
                      message: activeState.message,
                      onDismiss: _finishTrip,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ───────────────────────── UI Components ─────────────────────────

  /// Top Brand Header: RIDENEST + Hamburger icon
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: -0.8,
            ),
            children: [
              TextSpan(
                text: 'RIDE',
                style: TextStyle(color: Color(0xFF111827)),
              ),
              TextSpan(
                text: 'NEST',
                style: TextStyle(color: Color(0xFFFF3B30)),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            context.push(AppRoutes.profile);
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(
            Icons.menu_rounded,
            size: 32,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  /// Location Pill: "Your location >"
  Widget _buildLocationPill() {
    final title = _currentAddressModel?.title ?? 'Your location';
    return InkWell(
      onTap: () => _openSearchSheet(focusDestination: false),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                title.length > 25 ? '${title.substring(0, 25)}...' : title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 2x2 Services Grid: Cargo (-10%), Delivery (-20%), Bike, Rides (from 4 min)
  Widget _buildServiceGrid() {
    return Column(
      children: [
        // Row 1: Cargo & Delivery
        Row(
          children: [
            Expanded(
              child: _buildServiceCard(
                title: 'Cargo',
                badgeText: '-10%',
                badgeColor: const Color(0xFFFF3B30),
                illustration: const CargoIllustration(size: 88),
                onTap: () => _openSearchSheet(focusDestination: true),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildServiceCard(
                title: 'Delivery',
                badgeText: '-20%',
                badgeColor: const Color(0xFF111827),
                illustration: const DeliveryIllustration(size: 88),
                onTap: () => _openSearchSheet(focusDestination: true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Row 2: Bike & Rides
        Row(
          children: [
            Expanded(
              child: _buildServiceCard(
                title: 'Bike',
                illustration: const BikeIllustration(size: 96),
                onTap: () => _openSearchSheet(focusDestination: true),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildServiceCard(
                title: 'Rides',
                subtitle: 'from 4 min',
                illustration: const CarIllustration(size: 102),
                onTap: () => _openSearchSheet(focusDestination: true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required String title,
    String? subtitle,
    String? badgeText,
    Color? badgeColor,
    required Widget illustration,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Column(
        children: [
          Container(
            height: 122,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4F6),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Discount Badge at top right
                if (badgeText != null)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor ?? const Color(0xFFFF3B30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                // Illustration in Center/Bottom
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: illustration,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Category Label + optional subtitle
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
              children: [
                if (subtitle != null) ...[
                  const TextSpan(
                    text: '  •  ',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  TextSpan(
                    text: subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// "Where to?" Search Bar
  Widget _buildWhereToBar() {
    return GestureDetector(
      onTap: () => _openSearchSheet(focusDestination: true),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4F6),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.directions_car_filled_rounded,
              color: Color(0xFF334155),
              size: 26,
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Where to?',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Recent Destinations list with Pin Icon, Address, and Travel Time ETA
  Widget _buildRecentDestinations() {
    return BlocBuilder<RideSearchCubit, RideSearchState>(
      builder: (context, state) {
        List<_RecentPlaceItem> items = [];

        if (state is RideSearchInitial && state.recents.isNotEmpty) {
          final times = ['10 min', '12 min', '17 min', '20 min'];
          items = state.recents.take(3).toList().asMap().entries.map((e) {
            final place = e.value;
            return _RecentPlaceItem(
              title: place.title,
              subtitle: place.formattedAddress,
              etaText: times[e.key % times.length],
              latLng: place.coordinates,
            );
          }).toList();
        } else {
          items = _defaultRecents;
        }

        return Column(
          children: items.map((item) {
            return InkWell(
              onTap: () {
                _selectQuickDestination(
                  AddressModel(
                    id: item.title,
                    title: item.title,
                    formattedAddress: item.subtitle,
                    coordinates: item.latLng,
                    country: 'Nepal',
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    // Grey circular pin badge
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFF94A3B8),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Destination Title & Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Travel Time ETA
                    Text(
                      item.etaText,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// Promotional / Feature Cards: SAFE RIDES and NEED HELP?
  Widget _buildPromoBanners() {
    return Row(
      children: [
        // Safe Rides Banner
        Expanded(
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background artistic biker silhouette / icon overlay
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Icon(
                    Icons.two_wheeler_rounded,
                    size: 96,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                // Text
                const Padding(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SAFE\nRIDES',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.15,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.verified_user_rounded,
                            color: Color(0xFF38BDF8),
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Need Help Banner
        Expanded(
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF475569), Color(0xFF334155)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background artistic support icon overlay
                Positioned(
                  right: -8,
                  bottom: -8,
                  child: Icon(
                    Icons.support_agent_rounded,
                    size: 96,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                // Text
                const Padding(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NEED\nHELP?',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.15,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_rounded,
                            color: Color(0xFFFFB300),
                            size: 15,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '24/7 Support',
                            style: TextStyle(
                              color: Color(0xFFFFB300),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────────────── State Helpers ─────────────────────────

  AddressModel? statePickupFromSearch(BuildContext context) {
    final searchCubit = context.read<RideSearchCubit>();
    return searchCubit.currentPickup;
  }

  AddressModel? stateDestinationFromSearch(BuildContext context) {
    final searchCubit = context.read<RideSearchCubit>();
    return searchCubit.currentDestination;
  }

  String stateTextForDriver(DriverAssignedState state) {
    return state.statusText;
  }
}

class _RecentPlaceItem {
  final String title;
  final String subtitle;
  final String etaText;
  final LatLngModel latLng;

  const _RecentPlaceItem({
    required this.title,
    required this.subtitle,
    required this.etaText,
    required this.latLng,
  });
}
