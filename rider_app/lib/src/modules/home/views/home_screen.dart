import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_core/shared_core.dart';

import '../../../data/remote/ride_api_service.dart';
import '../../../data/repo/places_repo.dart';
import '../../../data/repo/ride_repo.dart';
import '../../ride/views/ride_map_view.dart';
import '../../ride/widgets/map/ride_markers.dart';
import '../../ride/widgets/map/ride_polylines.dart';
import '../../ride/widgets/sheets/active_driver_sheet.dart';
import '../../ride/widgets/sheets/driver_searching_sheet.dart';
import '../../ride/widgets/sheets/ride_booking_sheet.dart';
import '../../ride/widgets/sheets/trip_completed_sheet.dart';
import '../blocs/active_ride_cubit.dart';
import '../blocs/ride_search_cubit.dart';
import '../widgets/destination_search_sheet.dart';
import '../widgets/home_idle_view.dart';
import '../widgets/pickup_address_picker_sheet.dart';

/// Main coordinator screen supporting the entire ride lifecycle:
/// - Idle dashboard with quick destination selection
/// - Route preview & booking
/// - Driver searching
/// - Driver assigned & trip in progress
/// - Trip completion and rating
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  LatLng _currentLocation = const LatLng(27.7172, 85.3240);
  // ignore: unused_field
  bool _isLoadingLocation = true;
  AddressModel? _currentAddressModel;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  BitmapDescriptor? _driverMarkerIcon;
  bool _isFetchingDriverRoute = false;

  // Dynamic screen offsets for floating callouts and pins
  Offset? _destinationScreenOffset;
  Offset? _pickupScreenOffset;
  Offset? _driverScreenOffset;
  bool _isUpdatingOffsets = false;

  late final AnimationController _radarAnimation;
  AnimationController? _routeAnimationController;
  List<LatLng> _fullRoutePoints = [];

  @override
  void initState() {
    super.initState();
    _radarAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _loadVehicleMarkerIcon();
    _fetchCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ActiveRideCubit>().checkActiveRide();
      }
    });
  }

  Future<void> _loadVehicleMarkerIcon() async {
    try {
      final icon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(44, 44)),
        'assets/icons/bike.png',
      );
      if (mounted) {
        setState(() => _driverMarkerIcon = icon);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _mapController = null;
    _radarAnimation.dispose();
    _routeAnimationController?.dispose();
    super.dispose();
  }

  bool get _isMapMounted {
    if (!mounted || _mapController == null) return false;
    final state = context.read<ActiveRideCubit>().state;
    return state is RoutePreviewReady ||
        state is DriverSearching ||
        state is DriverAssignedState ||
        state is TripCompletedState;
  }

  Future<void> _safeAnimateCamera(CameraUpdate update) async {
    if (!_isMapMounted) return;
    try {
      await _mapController?.animateCamera(update);
    } catch (_) {
      _mapController = null;
    }
  }

  Future<void> _fetchCurrentLocation({bool forceGps = false}) async {
    final placesRepo = sl<PlacesRepo>();

    // 1. If not forcing GPS, check if user previously chose and saved a custom pickup address.
    if (!forceGps) {
      final savedAddress = placesRepo.getSavedPickupAddress();
      if (savedAddress != null) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
            _currentAddressModel = savedAddress;
            _currentLocation = LatLng(
              savedAddress.coordinates.latitude,
              savedAddress.coordinates.longitude,
            );
          });
          context.read<RideSearchCubit>().setPickup(savedAddress);
          _safeAnimateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: _currentLocation, zoom: 16.2),
            ),
          );
        }
        return;
      }
    }

    setState(() => _isLoadingLocation = true);
    final locationService = sl<LocationService>();
    final hasPermission = await locationService.ensurePermission();

    if (hasPermission) {
      final pos = await locationService.getCurrentLocation();
      if (pos != null && mounted) {
        final currentLatLng = LatLng(pos.latitude, pos.longitude);
        _currentLocation = currentLatLng;

        // Reverse geocode strictly via API
        try {
          final resolvedAddress = await placesRepo.reverseGeocode(pos);
          if (mounted) {
            final address =
                resolvedAddress ??
                AddressModel(
                  id: 'current_gps',
                  title: 'Current Location',
                  formattedAddress:
                      '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}',
                  coordinates: pos,
                  country: 'Nepal',
                );
            setState(() {
              _isLoadingLocation = false;
              _currentAddressModel = address;
            });
            context.read<RideSearchCubit>().setPickup(address);
            await placesRepo.saveSavedPickupAddress(address);

            _safeAnimateCamera(
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

  Future<void> _openPickupLocationPicker() async {
    final chosenAddress = await PickupAddressPickerSheet.show(
      context,
      currentCoordinates: _currentLocation,
      currentAddress: _currentAddressModel,
    );

    if (chosenAddress != null && mounted) {
      await _onPickupAddressChosen(chosenAddress);
    }
  }

  Future<void> _onPickupAddressChosen(AddressModel address) async {
    setState(() {
      _currentAddressModel = address;
      _currentLocation = LatLng(
        address.coordinates.latitude,
        address.coordinates.longitude,
      );
    });

    await sl<PlacesRepo>().saveSavedPickupAddress(address);
    if (!mounted) return;

    context.read<RideSearchCubit>().setPickup(address);

    _safeAnimateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentLocation, zoom: 16.2),
      ),
    );
  }

  void _openSearchSheet({bool focusDestination = true}) {
    DestinationSearchSheet.show(
      context,
      currentPosition: _currentAddressModel?.coordinates,
      initialFocusDestination: focusDestination,
    );
  }

  void _selectQuickDestination(AddressModel place) {
    _currentAddressModel ??= AddressModel(
      id: 'current_gps',
      title: 'Your location',
      formattedAddress: 'Current GPS Location',
      coordinates: LatLngModel(
        latitude: _currentLocation.latitude,
        longitude: _currentLocation.longitude,
      ),
      country: 'Nepal',
    );
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
      _markers = RideMarkers.buildPreviewMarkers(
        pickup: pLatLng,
        pickupTitle: state.pickup.title,
        destination: dLatLng,
        destinationTitle: state.destination.title,
      );

      _polylines = polylinePoints.isNotEmpty
          ? {
              RidePolylines.createBackdropPolyline(
                points: polylinePoints,
                color: Colors.black,
                width: 7,
              ),
            }
          : {};
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
        _polylines = RidePolylines.buildAnimatedRoutePolylines(
          fullRoutePoints: _fullRoutePoints,
          animatedCurrentPoints: currentPath,
        );
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

    final polylinePoints = state.booking.route.points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    setState(() {
      _markers = RideMarkers.buildPreviewMarkers(
        pickup: pLatLng,
        pickupTitle: state.booking.pickup.title,
        destination: dLatLng,
        destinationTitle: state.booking.destination.title,
      );

      _polylines = RidePolylines.buildStaticRoutePolylines(
        points: polylinePoints,
        color: Colors.black,
        width: 5,
      );
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

    final isOnTrip = state.booking.status == RideStatus.tripInProgress;

    final markers = RideMarkers.buildDriverAssignedMarkers(
      driverPosition: dPos,
      driver: state.driver,
      driverHeading: state.driverPosition.heading ?? 0.0,
      driverIcon: _driverMarkerIcon,
      pickup: pLatLng,
      pickupTitle: state.booking.pickup.title,
      destination: dLatLng,
      destinationTitle: state.booking.destination.title,
      isTripInProgress: isOnTrip,
    );

    final targetLatLng = isOnTrip ? dLatLng : pLatLng;
    final liveRoutePoints = _getRemainingRoutePoints(dPos, targetLatLng);

    setState(() {
      _markers = markers;
      _polylines = RidePolylines.buildStaticRoutePolylines(
        points: liveRoutePoints,
        color: const Color(0xFF0F172A),
        width: 5,
      );
    });

    if (isOnTrip) {
      _safeAnimateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: dPos,
            zoom: 17.2,
            tilt: 35.0,
            bearing: state.driverPosition.heading ?? 0.0,
          ),
        ),
      ).then((_) {
        _updateMapScreenPositions();
      });
    } else {
      _fitRouteBounds([dPos, pLatLng], pickup: dPos, destination: pLatLng);
    }

    if (_fullRoutePoints.isEmpty) {
      _fetchDriverRouteIfNeeded(state);
    }
  }

  List<LatLng> _getRemainingRoutePoints(LatLng currentPos, LatLng targetPos) {
    if (_fullRoutePoints.isEmpty) {
      return [currentPos, targetPos];
    }
    int closestIndex = 0;
    double minDistance = double.infinity;
    for (int i = 0; i < _fullRoutePoints.length; i++) {
      final p = _fullRoutePoints[i];
      final dLat = p.latitude - currentPos.latitude;
      final dLng = p.longitude - currentPos.longitude;
      final distSq = dLat * dLat + dLng * dLng;
      if (distSq < minDistance) {
        minDistance = distSq;
        closestIndex = i;
      }
    }
    return [currentPos, ..._fullRoutePoints.sublist(closestIndex)];
  }

  Future<void> _fetchDriverRouteIfNeeded(DriverAssignedState state) async {
    if (_isFetchingDriverRoute) return;
    _isFetchingDriverRoute = true;
    try {
      final target = state.booking.status == RideStatus.tripInProgress
          ? state.booking.destination.coordinates
          : state.booking.pickup.coordinates;
      final route = await sl<RideRepo>().getRouteBetweenCoordinates(
        origin: state.driverPosition,
        destination: target,
      );
      if (mounted) {
        final pts = route.points
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList();
        _fullRoutePoints = pts;
        setState(() {
          _polylines = RidePolylines.buildStaticRoutePolylines(
            points: pts,
            color: const Color(0xFF0F172A),
            width: 5,
          );
        });
      }
    } catch (_) {
      // Ignored: fallback polyline is already displayed
    } finally {
      _isFetchingDriverRoute = false;
    }
  }

  double _calculateLiveDistanceKm(DriverAssignedState state) {
    final target = state.booking.status == RideStatus.tripInProgress
        ? state.booking.destination.coordinates
        : state.booking.pickup.coordinates;
    return MapUtils.calculateDistance(state.driverPosition, target);
  }

  int _calculateLiveEtaMinutes(DriverAssignedState state) {
    final distKm = _calculateLiveDistanceKm(state);
    if (distKm < 0.1) return 1;
    final mins = (distKm / 28.0 * 60).round();
    return mins.clamp(1, 180);
  }

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

  void _fitRouteBounds(
    List<LatLng> points, {
    LatLng? pickup,
    LatLng? destination,
  }) {
    if (!_isMapMounted) return;

    final List<LatLng> targetPoints = [?pickup, ?destination, ...points];

    if (targetPoints.isEmpty) return;

    final bounds = MapUtils.boundsFromLatLngList(targetPoints);

    _safeAnimateCamera(CameraUpdate.newLatLngBounds(bounds, 48.0)).then((_) {
      _updateMapScreenPositions();
    });
  }

  Future<void> _updateMapScreenPositions() async {
    if (!_isMapMounted || !mounted || _isUpdatingOffsets) return;
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
    _mapController = null;
    setState(() {
      _markers.clear();
      _polylines.clear();
    });
  }

  void _finishTrip() {
    _routeAnimationController?.stop();
    _fullRoutePoints.clear();
    context.read<RideSearchCubit>().clearDestination();
    context.read<ActiveRideCubit>().resetTrip();
    _mapController = null;
    setState(() {
      _markers.clear();
      _polylines.clear();
    });
  }

  void _onRideCancelled(String message) {
    _routeAnimationController?.stop();
    _fullRoutePoints.clear();
    context.read<RideSearchCubit>().clearDestination();
    context.read<ActiveRideCubit>().resetTrip();
    _mapController = null;
    setState(() {
      _markers.clear();
      _polylines.clear();
    });
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
              _mapController = null;
              _onRideCancelled(state.message);
            } else if (state is ActiveRideInitial) {
              _mapController = null;
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
                if (isRideActive) ...[
                  RideMapView(
                    activeState: activeState,
                    initialCameraPosition: _currentLocation,
                    markers: _markers,
                    polylines: _polylines,
                    bottomSheetHeight: _getBottomSheetHeight(activeState),
                    destinationScreenOffset: _destinationScreenOffset,
                    pickupScreenOffset: _pickupScreenOffset,
                    driverScreenOffset: _driverScreenOffset,
                    radarAnimation: _radarAnimation,
                    liveEtaMinutes: activeState is DriverAssignedState
                        ? _calculateLiveEtaMinutes(activeState)
                        : null,
                    liveDistanceKm: activeState is DriverAssignedState
                        ? _calculateLiveDistanceKm(activeState)
                        : null,
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
                    onClearTrip: _clearTrip,
                    onFinishTrip: _finishTrip,
                    onRecenter: () {
                      if (activeState is RoutePreviewReady) {
                        final pLatLng = LatLng(
                          activeState.pickup.coordinates.latitude,
                          activeState.pickup.coordinates.longitude,
                        );
                        final dLatLng = LatLng(
                          activeState.destination.coordinates.latitude,
                          activeState.destination.coordinates.longitude,
                        );
                        final polylinePoints = activeState.route.points
                            .map((p) => LatLng(p.latitude, p.longitude))
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
                        _fetchCurrentLocation(forceGps: true);
                      }
                    },
                  ),
                ] else ...[
                  HomeIdleView(
                    pickupTitle: _currentAddressModel?.title ?? 'Your location',
                    onOpenPickupLocationPicker: _openPickupLocationPicker,
                    onOpenSearchSheet: () =>
                        _openSearchSheet(focusDestination: true),
                    onSelectDestination: _selectQuickDestination,
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
                    child: DriverSearchingSheet(
                      booking: activeState.booking,
                      onCancel: _clearTrip,
                    ),
                  ),

                if (activeState is DriverAssignedState)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ActiveDriverSheet(
                      booking: activeState.booking,
                      driver: activeState.driver,
                      statusText: stateTextForDriver(activeState),
                      onCancel: _clearTrip,
                      etaMinutes: _calculateLiveEtaMinutes(activeState),
                      distanceKm: _calculateLiveDistanceKm(activeState),
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
