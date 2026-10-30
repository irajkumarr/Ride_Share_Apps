import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver_app/src/data/local/auth_local_data_source.dart';
import 'package:driver_app/src/data/remote/dto/ride_dispatch_dto.dart';
import 'package:driver_app/src/data/remote/dto/user_dto.dart';
import 'package:driver_app/src/data/remote/dto/vehicle_dto.dart';
import 'package:driver_app/src/modules/home/blocs/driver_status_cubit.dart';
import 'package:driver_app/src/modules/home/widgets/driver_map_markers.dart';
import 'package:driver_app/src/modules/home/widgets/driver_status_top_bar.dart';
import 'package:driver_app/src/modules/home/widgets/driver_vehicle_card.dart';
import 'package:driver_app/src/modules/ride/blocs/ride_dispatch_cubit.dart';
import 'package:driver_app/src/modules/ride/utils/ride_notification_alert_service.dart';
import 'package:driver_app/src/modules/ride/views/ride_request_map_markers.dart';
import 'package:driver_app/src/modules/ride/views/ride_request_sheet.dart';
import 'package:driver_app/src/modules/trip/utils/trip_location_utils.dart';
import 'package:driver_app/src/modules/trip/views/active_trip_panel.dart';
import 'package:driver_app/src/modules/trip/views/trip_summary_sheet.dart';
import 'package:driver_app/src/modules/vehicle/blocs/vehicle_cubit.dart';
import 'package:shared_core/shared_core.dart';
import 'package:go_router/go_router.dart';

/// Driver Partner Home Dashboard:
/// - Authoritative Google Map with custom driver puck and dynamic route lines
/// - Real-time calculations for distance and ETA (zero mock data)
/// - Top bar with profile avatar initials, online/offline shift status, layers, and GPS recenter
/// - Responsive bottom sheets for Idle, Incoming Request, Active Trip, and Trip Completion
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  LatLng _currentLocation = const LatLng(
    27.6745,
    85.3720,
  ); // Lokanthali / Balkumari fallback
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Set<Circle> _circles = {};
  UserDataDto? _driverProfile;
  VehicleDto? _selectedVehicleOverride;
  bool _isDarkMap = false;
  bool _isMuted = false;
  bool _isFullScreenMap = false;

  @override
  void initState() {
    super.initState();
    _loadDriverProfile();
    _fetchCurrentLocation();
    context.read<VehicleCubit>().fetchMyVehicles();
    context.read<RideDispatchCubit>().subscribeToTopics();
    context.read<RideDispatchCubit>().checkActiveRide();
  }

  Future<void> _safeAnimateCamera(CameraUpdate update) async {
    if (!mounted || _mapController == null) return;
    try {
      await _mapController?.animateCamera(update);
    } catch (e) {
      debugPrint('Safe animateCamera prevented error: $e');
    }
  }

  Future<void> _loadDriverProfile() async {
    final driver = await sl<AuthLocalDataSource>().getCachedDriver();
    if (mounted) {
      setState(() {
        _driverProfile = driver;
      });
    }
  }

  Future<void> _fetchCurrentLocation() async {
    final locationService = sl<LocationService>();
    final hasPermission = await locationService.ensurePermission();

    if (hasPermission) {
      final pos = await locationService.getCurrentLocation();
      if (pos != null && mounted) {
        final currentLatLng = LatLng(pos.latitude, pos.longitude);
        setState(() {
          _currentLocation = currentLatLng;
        });
        await _updateDriverMarker(currentLatLng);

        _safeAnimateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentLocation, zoom: 16.2),
          ),
        );
      }
    } else {
      await _updateDriverMarker(_currentLocation);
    }
  }

  Future<void> _updateDriverMarker(LatLng pos) async {
    final puckIcon = await DriverMapMarkers.getDriverPuckIcon();
    if (!mounted) return;

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('driver_current_pos'),
          position: pos,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          icon: puckIcon,
          infoWindow: InfoWindow(
            title: 'Your Location',
            snippet: _driverProfile?.fullName ?? 'Driver Partner',
          ),
        ),
      };
    });
  }

  Future<void> _updateTripMap(ActiveTripState trip) async {
    final req = trip.request;
    final pLat = req.pickupLat ?? _currentLocation.latitude;
    final pLng = req.pickupLng ?? _currentLocation.longitude;
    final dLat = req.dropoffLat ?? _currentLocation.latitude;
    final dLng = req.dropoffLng ?? _currentLocation.longitude;

    final pLatLng = LatLng(pLat, pLng);
    final dLatLng = LatLng(dLat, dLng);

    final acceptedPickupIcon =
        await RideRequestMapMarkers.getAcceptedPickupMarkerIcon();
    final driverPuck = await DriverMapMarkers.getDriverPuckIcon();

    if (!mounted) return;

    setState(() {
      _markers = {
        // Driver position puck
        Marker(
          markerId: const MarkerId('driver_puck'),
          position: _currentLocation,
          anchor: const Offset(0.5, 0.5),
          icon: driverPuck,
          zIndexInt: 3,
        ),
        // Pickup marker
        Marker(
          markerId: const MarkerId('accepted_pickup_marker'),
          position: pLatLng,
          anchor: const Offset(0.5, 0.85),
          icon: acceptedPickupIcon,
          zIndexInt: 4,
        ),
        // Dropoff marker (when trip in progress)
        if (trip.currentStatus == 'IN_PROGRESS')
          Marker(
            markerId: const MarkerId('destination_marker'),
            position: dLatLng,
            anchor: const Offset(0.5, 1.0),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            zIndexInt: 3,
          ),
      };

      // Concentric geofence rings centered at pickup
      _circles = {
        Circle(
          circleId: const CircleId('pickup_geofence_150m'),
          center: pLatLng,
          radius: 150,
          fillColor: const Color(0xFF38BDF8).withValues(alpha: 0.14),
          strokeColor: const Color(0xFF0284C7).withValues(alpha: 0.5),
          strokeWidth: 2,
        ),
        Circle(
          circleId: const CircleId('pickup_geofence_300m'),
          center: pLatLng,
          radius: 300,
          fillColor: const Color(0xFF60A5FA).withValues(alpha: 0.07),
          strokeColor: const Color(0xFF3B82F6).withValues(alpha: 0.35),
          strokeWidth: 1,
        ),
      };

      _polylines = {
        Polyline(
          polylineId: const PolylineId('nav_polyline'),
          points: trip.currentStatus == 'IN_PROGRESS'
              ? [_currentLocation, dLatLng]
              : [_currentLocation, pLatLng],
          color: const Color(0xFF3B82F6),
          width: 6,
          jointType: JointType.round,
        ),
      };
    });

    final targetBoundsPoints = trip.currentStatus == 'IN_PROGRESS'
        ? [_currentLocation, dLatLng]
        : [_currentLocation, pLatLng];

    _safeAnimateCamera(
      CameraUpdate.newLatLngBounds(
        MapUtils.boundsFromLatLngList(targetBoundsPoints),
        64.0,
      ),
    );
  }

  Future<void> _updateCompletedTripMap(
    TripCompletedSummaryState summary,
  ) async {
    final req = summary.request;
    final pLat = req.pickupLat ?? _currentLocation.latitude;
    final pLng = req.pickupLng ?? _currentLocation.longitude;
    final dLat = req.dropoffLat ?? _currentLocation.latitude;
    final dLng = req.dropoffLng ?? _currentLocation.longitude;

    final pLatLng = LatLng(pLat, pLng);
    final dLatLng = LatLng(dLat, dLng);

    final pickupLabel = req.pickupAddress.trim().isNotEmpty
        ? req.pickupAddress.split(',').first.trim()
        : 'Pickup';
    final dropoffLabel = req.dropoffAddress.trim().isNotEmpty
        ? req.dropoffAddress.split(',').first.trim()
        : 'Destination';

    final completedPickupIcon =
        await RideRequestMapMarkers.getCompletedPickupDotMarkerIcon(
          label: pickupLabel,
        );
    final completedDestIcon =
        await RideRequestMapMarkers.getCompletedDestinationFlagMarkerIcon(
          label: dropoffLabel,
        );

    if (!mounted) return;

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('completed_pickup_marker'),
          position: pLatLng,
          anchor: const Offset(0.12, 0.5),
          icon: completedPickupIcon,
          zIndexInt: 3,
        ),
        Marker(
          markerId: const MarkerId('completed_destination_marker'),
          position: dLatLng,
          anchor: const Offset(0.5, 0.4),
          icon: completedDestIcon,
          zIndexInt: 4,
        ),
      };

      _circles = {};

      _polylines = {
        Polyline(
          polylineId: const PolylineId('completed_route_polyline'),
          points: [pLatLng, dLatLng],
          color: const Color(0xFF059669),
          width: 6,
          jointType: JointType.round,
        ),
      };
    });

    _safeAnimateCamera(
      CameraUpdate.newLatLngBounds(
        MapUtils.boundsFromLatLngList([pLatLng, dLatLng]),
        48.0,
      ),
    );
  }

  Future<void> _updateIncomingRequestMap(RideRequestPayloadDto req) async {
    final pLat = req.pickupLat ?? _currentLocation.latitude;
    final pLng = req.pickupLng ?? _currentLocation.longitude;
    final dLat = req.dropoffLat ?? _currentLocation.latitude;
    final dLng = req.dropoffLng ?? _currentLocation.longitude;

    final pLatLng = LatLng(pLat, pLng);
    final dLatLng = LatLng(dLat, dLng);

    // Calculate real distance and ETA to pickup
    final distMeters = TripLocationUtils.distanceInMeters(
      _currentLocation.latitude,
      _currentLocation.longitude,
      pLat,
      pLng,
    );
    final etaMinutes = TripLocationUtils.estimatedDurationMinutes(distMeters);
    final formattedDist = TripLocationUtils.formatDistance(distMeters);

    final pickupIcon = await RideRequestMapMarkers.getPickupMarkerIcon(
      etaText: 'PICKUP • $etaMinutes min',
    );
    final driverLabelIcon =
        await RideRequestMapMarkers.getDriverDistanceLabelIcon(
          text: 'You ($formattedDist)',
        );

    if (!mounted) return;

    final icon = await DriverMapMarkers.getDriverPuckIcon();
    setState(() {
      _markers = {
        // Driver circular puck
        Marker(
          markerId: const MarkerId('driver_puck'),
          position: _currentLocation,
          anchor: const Offset(0.5, 0.5),
          icon: icon,
          zIndexInt: 3,
        ),
        // Driver dynamic distance label
        Marker(
          markerId: const MarkerId('driver_label'),
          position: LatLng(
            _currentLocation.latitude - 0.0003,
            _currentLocation.longitude,
          ),
          anchor: const Offset(0.5, 0.0),
          icon: driverLabelIcon,
          zIndexInt: 2,
        ),
        // Pickup marker with real ETA
        Marker(
          markerId: const MarkerId('pickup_marker'),
          position: pLatLng,
          anchor: const Offset(0.5, 0.9),
          icon: pickupIcon,
          zIndexInt: 4,
        ),
        // Destination marker
        Marker(
          markerId: const MarkerId('destination_marker'),
          position: dLatLng,
          anchor: const Offset(0.5, 1.0),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          zIndexInt: 3,
        ),
      };

      _polylines = {
        // Polyline connecting Driver to Pickup
        Polyline(
          polylineId: const PolylineId('driver_to_pickup_polyline'),
          points: [_currentLocation, pLatLng],
          color: const Color(0xFF00B4A0),
          width: 5,
          jointType: JointType.round,
        ),
        // Polyline connecting Pickup to Destination
        Polyline(
          polylineId: const PolylineId('pickup_to_dropoff_polyline'),
          points: [pLatLng, dLatLng],
          color: const Color(0xFF0F172A),
          width: 5,
          jointType: JointType.round,
        ),
      };
    });

    _safeAnimateCamera(
      CameraUpdate.newLatLngBounds(
        MapUtils.boundsFromLatLngList([_currentLocation, pLatLng, dLatLng]),
        48.0,
      ),
    );
  }

  String _getDriverInitials() {
    final name = _driverProfile?.fullName?.trim();
    if (name == null || name.isEmpty) return 'DP';
    final parts = name.split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  String _getFirstName() {
    final name = _driverProfile?.fullName?.trim();
    if (name == null || name.isEmpty) return 'Partner';
    return name.split(' ').first;
  }

  double _getDriverBottomSheetHeight(RideDispatchState dispatchState) {
    if (dispatchState is RideRequestReceivedState) {
      return 450.0;
    } else if (dispatchState is ActiveTripState) {
      return _isFullScreenMap ? 95.0 : 360.0;
    } else if (dispatchState is TripCompletedSummaryState) {
      return 450.0;
    }
    return 260.0;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DriverStatusCubit, DriverStatusState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              AppAlerts.error(context, state.errorMessage!);
            }
            if (state.lastPosition != null) {
              final newPos = LatLng(
                state.lastPosition!.latitude,
                state.lastPosition!.longitude,
              );
              _currentLocation = newPos;
              _updateDriverMarker(newPos);
            }
          },
        ),
        BlocListener<RideDispatchCubit, RideDispatchState>(
          listener: (context, state) {
            if (state is RideRequestReceivedState) {
              _updateIncomingRequestMap(state.request);
              RideNotificationAlertService.instance.startAlert(
                isMuted: _isMuted,
              );
            } else if (state is ActiveTripState) {
              RideNotificationAlertService.instance.stopAlert();
              _updateTripMap(state);
            } else if (state is TripCompletedSummaryState) {
              RideNotificationAlertService.instance.stopAlert();
              _updateCompletedTripMap(state);
            } else if (state is RideDispatchIdle) {
              RideNotificationAlertService.instance.stopAlert();
              setState(() {
                _polylines.clear();
                _circles.clear();
                _updateDriverMarker(_currentLocation);
              });
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<RideDispatchCubit, RideDispatchState>(
          builder: (context, dispatchState) {
            final bottomSheetHeight = _getDriverBottomSheetHeight(
              dispatchState,
            );

            return Stack(
              children: [
                // 1. Google Map View with responsive viewport padding
                CustomMapView(
                  initialCameraPosition: _currentLocation,
                  initialZoom: 16.0,
                  markers: _markers,
                  polylines: _polylines,
                  circles: _circles,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 75,
                    bottom: bottomSheetHeight + 16,
                    left: 24,
                    right: 24,
                  ),
                  customMapStyleAsset: _isDarkMap
                      ? 'packages/shared_core/assets/mapTheme/darkMap.json'
                      : null,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),

                // 2. Top Header: DriverStatusTopBar
                SafeArea(
                  child: BlocBuilder<DriverStatusCubit, DriverStatusState>(
                    builder: (context, statusState) {
                      final isIncoming =
                          dispatchState is RideRequestReceivedState;

                      return DriverStatusTopBar(
                        driverStatusState: statusState,
                        driverInitials: _getDriverInitials(),
                        isMapNormal: !_isDarkMap,
                        isIncomingRequest: isIncoming,
                        isMuted: _isMuted,
                        onSoundToggle: () {
                          setState(() {
                            _isMuted = !_isMuted;
                          });
                          RideNotificationAlertService.instance.setMuted(
                            _isMuted,
                          );
                        },
                        onProfileTap: () => context.push(AppRoutes.profile),
                        onStatusTap: () => context
                            .read<DriverStatusCubit>()
                            .toggleOnlineOffline(),
                        onLayersTap: () {
                          setState(() {
                            _isDarkMap = !_isDarkMap;
                          });
                          if (_mapController != null) {
                            MapUtils.setMapStyle(
                              _mapController!,
                              _isDarkMap
                                  ? 'packages/shared_core/assets/mapTheme/darkMap.json'
                                  : 'packages/shared_core/assets/mapTheme/lightMap.json',
                            );
                          }
                        },
                        onRecenterTap: _fetchCurrentLocation,
                      );
                    },
                  ),
                ),

                // 3. Floating Right Recenter GPS Action Button on Active Trip
                if (dispatchState is ActiveTripState)
                  Positioned(
                    right: 16,
                    bottom: _isFullScreenMap ? 110.0 : 360.0,
                    child: GestureDetector(
                      onTap: () => _updateTripMap(dispatchState),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.gps_fixed_rounded,
                            color: Color(0xFF2563EB),
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),

                // 4. Bottom Main Driver Dashboard Sheet (Idle state)
                if (dispatchState is! ActiveTripState &&
                    dispatchState is! RideRequestReceivedState &&
                    dispatchState is! TripCompletedSummaryState)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 28,
                            offset: const Offset(0, -6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row: Welcome & Shift Status Capsule
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'RIDENEST PARTNER',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF64748B),
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Welcome, ${_getFirstName()}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF0F172A),
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ],
                                ),
                                BlocBuilder<
                                  DriverStatusCubit,
                                  DriverStatusState
                                >(
                                  builder: (context, statusState) {
                                    final isOnline =
                                        statusState.status ==
                                        DriverShiftStatus.available;
                                    final isOnRide =
                                        statusState.status ==
                                        DriverShiftStatus.onRide;

                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isOnline
                                            ? const Color(0xFFDCFCE7)
                                            : (isOnRide
                                                  ? const Color(0xFFEFF6FF)
                                                  : const Color(0xFFF1F5F9)),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isOnline
                                              ? const Color(0xFF86EFAC)
                                              : (isOnRide
                                                    ? const Color(0xFFBFDBFE)
                                                    : const Color(0xFFCBD5E1)),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isOnline
                                                  ? const Color(0xFF15803D)
                                                  : (isOnRide
                                                        ? const Color(
                                                            0xFF2563EB,
                                                          )
                                                        : const Color(
                                                            0xFF64748B,
                                                          )),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            isOnline
                                                ? 'ONLINE'
                                                : (isOnRide
                                                      ? 'ON TRIP'
                                                      : 'OFFLINE'),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: isOnline
                                                  ? const Color(0xFF15803D)
                                                  : (isOnRide
                                                        ? const Color(
                                                            0xFF1D4ED8,
                                                          )
                                                        : const Color(
                                                            0xFF475569,
                                                          )),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),

                            // Real Driver Stats Row (only if present)
                            if (_driverProfile?.totalRides != null ||
                                (_driverProfile?.rating != null &&
                                    _driverProfile!.rating! > 0)) ...[
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  if (_driverProfile?.totalRides != null) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.route_rounded,
                                            size: 13,
                                            color: Color(0xFF64748B),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${_driverProfile!.totalRides} trips',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF334155),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (_driverProfile?.totalRides != null &&
                                      _driverProfile?.rating != null &&
                                      _driverProfile!.rating! > 0)
                                    const SizedBox(width: 8),
                                  if (_driverProfile?.rating != null &&
                                      _driverProfile!.rating! > 0) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFFBEB),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFFFDE68A),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            size: 13,
                                            color: Color(0xFFD97706),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _driverProfile!.rating!
                                                .toStringAsFixed(1),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF92400E),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],

                            const SizedBox(height: 14),

                            // Vehicle Info Card with Switch modal
                            BlocBuilder<VehicleCubit, VehicleState>(
                              builder: (context, vehicleState) {
                                final vehicles = vehicleState is VehicleLoaded
                                    ? vehicleState.vehicles
                                    : <VehicleDto>[];
                                final defaultVehicle =
                                    vehicleState is VehicleLoaded
                                    ? vehicleState.activeVehicle
                                    : null;
                                final currentVehicle =
                                    _selectedVehicleOverride ?? defaultVehicle;

                                return DriverVehicleCard(
                                  activeVehicle: currentVehicle,
                                  vehicles: vehicles,
                                  onVehicleSelected: (selected) {
                                    setState(() {
                                      _selectedVehicleOverride = selected;
                                    });
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Slide to Go Online / Offline Slider
                            BlocBuilder<DriverStatusCubit, DriverStatusState>(
                              builder: (context, statusState) {
                                final isOnline =
                                    statusState.status ==
                                    DriverShiftStatus.available;

                                return SlideToActButton(
                                  text: isOnline
                                      ? 'SLIDE TO GO OFFLINE <<<'
                                      : 'SLIDE TO GO ONLINE >>>',
                                  height: 56,
                                  borderRadius: 18,
                                  backgroundColor: const Color(0xFF1B3439),
                                  thumbColor: isOnline
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF00B4A0),
                                  thumbIcon: Icons.power_settings_new_rounded,
                                  isLoading: statusState.isUpdating,
                                  onSlideComplete: () async {
                                    if (isOnline) {
                                      await context
                                          .read<DriverStatusCubit>()
                                          .goOffline();
                                    } else {
                                      await context
                                          .read<DriverStatusCubit>()
                                          .goOnline();
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 5. Overlays: Incoming Request, Active Trip, Trip Summary
                if (dispatchState is RideRequestReceivedState)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: RideRequestSheet(
                      request: dispatchState.request,
                      remainingSeconds: dispatchState.remainingSeconds,
                      isMuted: _isMuted,
                      onSoundToggle: () {
                        setState(() {
                          _isMuted = !_isMuted;
                        });
                        RideNotificationAlertService.instance.setMuted(
                          _isMuted,
                        );
                      },
                    ),
                  ),

                if (dispatchState is ActiveTripState) ...[
                  Builder(
                    builder: (context) {
                      final req = dispatchState.request;
                      final pLat = req.pickupLat ?? _currentLocation.latitude;
                      final pLng = req.pickupLng ?? _currentLocation.longitude;
                      final dLat = req.dropoffLat ?? _currentLocation.latitude;
                      final dLng = req.dropoffLng ?? _currentLocation.longitude;

                      // Distance is to dropoff if IN_PROGRESS, or to pickup if en route
                      final targetLat =
                          dispatchState.currentStatus == 'IN_PROGRESS'
                          ? dLat
                          : pLat;
                      final targetLng =
                          dispatchState.currentStatus == 'IN_PROGRESS'
                          ? dLng
                          : pLng;

                      final distanceMeters = TripLocationUtils.distanceInMeters(
                        _currentLocation.latitude,
                        _currentLocation.longitude,
                        targetLat,
                        targetLng,
                      );

                      if (_isFullScreenMap) {
                        return Positioned(
                          bottom: 24,
                          left: 20,
                          right: 20,
                          child: SafeArea(
                            top: false,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.navigation_rounded,
                                    color: Color(0xFF38BDF8),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'LIVE IN-APP NAVIGATION',
                                          style: TextStyle(
                                            color: Color(0xFF38BDF8),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        Text(
                                          dispatchState.currentStatus ==
                                                  'IN_PROGRESS'
                                              ? 'To: ${req.dropoffAddress}'
                                              : 'To: ${req.pickupAddress}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _isFullScreenMap = false;
                                      });
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            _updateTripMap(dispatchState);
                                          });
                                    },
                                    icon: const Icon(
                                      Icons.fullscreen_exit_rounded,
                                      size: 16,
                                    ),
                                    label: const Text(
                                      'Controls',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2563EB),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: ActiveTripPanel(
                          tripState: dispatchState,
                          distanceToPickupMeters: distanceMeters,
                          isFullScreenMap: _isFullScreenMap,
                          onToggleFullScreen: () {
                            setState(() {
                              _isFullScreenMap = !_isFullScreenMap;
                            });
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _updateTripMap(dispatchState);
                            });
                          },
                          onOpenGoogleMaps: () async {
                            final success =
                                await MapUtils.launchGoogleMapsNavigation(
                                  destLat: targetLat,
                                  destLng: targetLng,
                                  originLat: _currentLocation.latitude,
                                  originLng: _currentLocation.longitude,
                                );

                            if (!success && context.mounted) {
                              AppAlerts.error(
                                context,
                                'Could not launch Google Maps.',
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],

                if (dispatchState is TripCompletedSummaryState)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: TripSummarySheet(summary: dispatchState),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
