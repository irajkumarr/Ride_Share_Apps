import 'package:driver_app/src/data/remote/dto/ride_dispatch_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver_app/src/data/local/auth_local_data_source.dart';
import 'package:driver_app/src/data/remote/dto/user_dto.dart';
import 'package:driver_app/src/data/remote/dto/vehicle_dto.dart';
import 'package:driver_app/src/modules/home/blocs/driver_status_cubit.dart';
import 'package:driver_app/src/modules/home/widgets/driver_map_markers.dart';
import 'package:driver_app/src/modules/home/widgets/driver_status_top_bar.dart';
import 'package:driver_app/src/modules/home/widgets/driver_surge_banner.dart';
import 'package:driver_app/src/modules/home/widgets/driver_vehicle_card.dart';
import 'package:driver_app/src/modules/ride/blocs/ride_dispatch_cubit.dart';
import 'package:driver_app/src/modules/ride/utils/ride_notification_alert_service.dart';
import 'package:driver_app/src/modules/ride/views/ride_request_map_markers.dart';
import 'package:driver_app/src/modules/ride/views/ride_request_sheet.dart';

import 'package:driver_app/src/modules/trip/utils/trip_location_utils.dart';
import 'package:driver_app/src/modules/trip/views/active_trip_panel.dart';
import 'package:driver_app/src/modules/trip/views/trip_summary_sheet.dart';
import 'package:driver_app/src/modules/trip/widgets/active_trip_nav_hud.dart';
import 'package:driver_app/src/modules/vehicle/blocs/vehicle_cubit.dart';
import 'package:shared_core/shared_core.dart';
import 'package:go_router/go_router.dart';

/// Redesigned Driver Partner Home Dashboard featuring:
/// - Real-time Google Map with custom high-tech driver puck marker
/// - Top bar with profile avatar initials, OFFLINE/ONLINE capsule pill, layers toggle, & recenter GPS
/// - Floating Surge Zone alert banner (+Rs. 80 / 1.5x)
/// - Bottom RideNest Partner card with driver greeting, Today's Net earnings card,
///   vehicle specifications card with switch modal, and Slide to Go Online interactive slider
/// - Incoming Ride Request countdown sheet, step-by-step active trip panel, & completion summary sheet
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
  ); // Lokanthali / Balkumari area
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

        _mapController?.animateCamera(
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
          zIndex: 3,
        ),
        // Pickup marker with [📍 PICKUP] black pill and red pulsing user icon
        Marker(
          markerId: const MarkerId('accepted_pickup_marker'),
          position: pLatLng,
          anchor: const Offset(0.5, 0.85),
          icon: acceptedPickupIcon,
          zIndex: 4,
        ),
        // Dropoff marker (for later in-progress trip)
        if (trip.currentStatus == 'IN_PROGRESS')
          Marker(
            markerId: const MarkerId('destination_marker'),
            position: dLatLng,
            anchor: const Offset(0.5, 1.0),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            zIndex: 3,
          ),
      };

      // Concentric geofence rings centered at pickup
      _circles = {
        // 100m proximity threshold circle (light blue highlight)
        Circle(
          circleId: const CircleId('pickup_geofence_100m'),
          center: pLatLng,
          radius: 100, // 100 meters exact threshold
          fillColor: const Color(0xFF38BDF8).withValues(alpha: 0.14),
          strokeColor: const Color(0xFF0284C7).withValues(alpha: 0.5),
          strokeWidth: 2,
        ),
        // Outer awareness circle (250m)
        Circle(
          circleId: const CircleId('pickup_geofence_250m'),
          center: pLatLng,
          radius: 250,
          fillColor: const Color(0xFF60A5FA).withValues(alpha: 0.07),
          strokeColor: const Color(0xFF3B82F6).withValues(alpha: 0.35),
          strokeWidth: 1,
        ),
      };

      _polylines = {
        // Blue navigation polyline from driver to pickup or dropoff
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
        ? [_currentLocation, pLatLng, dLatLng]
        : [_currentLocation, pLatLng];

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        MapUtils.boundsFromLatLngList(targetBoundsPoints),
        100,
      ),
    );
  }

  // Future<void> _updateTripMap(ActiveTripState trip) async {
  //   final req = trip.request;
  //   final pLat = req.pickupLat ?? _currentLocation.latitude;
  //   final pLng = req.pickupLng ?? _currentLocation.longitude;
  //   final dLat = req.dropoffLat ?? _currentLocation.latitude;
  //   final dLng = req.dropoffLng ?? _currentLocation.longitude;

  //   final pLatLng = LatLng(pLat, pLng);
  //   final dLatLng = LatLng(dLat, dLng);

  //   final acceptedPickupIcon =
  //       await RideRequestMapMarkers.getAcceptedPickupMarkerIcon();
  //   final driverPuck = await DriverMapMarkers.getDriverPuckIcon();

  //   if (!mounted) return;

  //   setState(() {
  //     _markers = {
  //       // Driver position puck
  //       Marker(
  //         markerId: const MarkerId('driver_puck'),
  //         position: _currentLocation,
  //         anchor: const Offset(
  //           0.5,
  //           0.5,
  //         ), // Center anchor is correct for a circular puck
  //         icon: driverPuck,
  //         zIndex: 3,
  //       ),
  //       // Pickup marker
  //       Marker(
  //         markerId: const MarkerId('accepted_pickup_marker'),
  //         position: pLatLng,
  //         // ✅ FIX 1: Changed to 1.0 (bottom-center).
  //         // This ensures the bottom tip of the pin/pill points exactly to the coordinate.
  //         anchor: const Offset(0.5, 1.0),
  //         icon: acceptedPickupIcon,
  //         zIndex: 4,
  //       ),
  //       // Dropoff marker (for later in-progress trip)
  //       if (trip.currentStatus == 'IN_PROGRESS')
  //         Marker(
  //           markerId: const MarkerId('destination_marker'),
  //           position: dLatLng,
  //           // ✅ FIX 1: Bottom-center for dropoff pin as well
  //           anchor: const Offset(0.5, 1.0),
  //           icon: BitmapDescriptor.defaultMarkerWithHue(
  //             BitmapDescriptor.hueRed,
  //           ),
  //           zIndex: 3,
  //         ),
  //     };

  //     // Concentric geofence rings centered at pickup
  //     _circles = {
  //       Circle(
  //         circleId: const CircleId('pickup_geofence_100m'),
  //         center: pLatLng,
  //         radius: 100,
  //         fillColor: const Color(0xFF38BDF8).withValues(alpha: 0.14),
  //         strokeColor: const Color(0xFF0284C7).withValues(alpha: 0.5),
  //         strokeWidth: 2,
  //       ),
  //       Circle(
  //         circleId: const CircleId('pickup_geofence_250m'),
  //         center: pLatLng,
  //         radius: 250,
  //         fillColor: const Color(0xFF60A5FA).withValues(alpha: 0.07),
  //         strokeColor: const Color(0xFF3B82F6).withValues(alpha: 0.35),
  //         strokeWidth: 1,
  //       ),
  //     };

  //     _polylines = {
  //       Polyline(
  //         polylineId: const PolylineId('nav_polyline'),
  //         points: trip.currentStatus == 'IN_PROGRESS'
  //             ? [_currentLocation, dLatLng]
  //             : [_currentLocation, pLatLng],
  //         color: const Color(0xFF3B82F6),
  //         width: 6,
  //         jointType: JointType.round,
  //       ),
  //     };
  //   });

  //   final targetBoundsPoints = trip.currentStatus == 'IN_PROGRESS'
  //       ? [_currentLocation, pLatLng, dLatLng]
  //       : [_currentLocation, pLatLng];

  //   final bounds = MapUtils.boundsFromLatLngList(targetBoundsPoints);

  //   // ✅ FIX 2: Increased padding from 100 to 150 (or 200).
  //   // This forces the camera to zoom out slightly and push the route
  //   // higher up into the "top center" of the visible screen,
  //   // leaving room for any bottom sheets or UI overlays.
  //   _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 150));
  // }

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

    final pickupLabel = req.pickupAddress.isNotEmpty
        ? req.pickupAddress.split(',').first.trim()
        : 'Gatthaghar';
    final dropoffLabel = req.dropoffAddress.isNotEmpty
        ? req.dropoffAddress.split(',').first.trim()
        : 'Sundhara';

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
          zIndex: 3,
        ),
        Marker(
          markerId: const MarkerId('completed_destination_marker'),
          position: dLatLng,
          anchor: const Offset(0.5, 0.4),
          icon: completedDestIcon,
          zIndex: 4,
        ),
      };

      _circles = {};

      _polylines = {
        // Emerald green completed route path matching design screenshot
        Polyline(
          polylineId: const PolylineId('completed_route_polyline'),
          points: [pLatLng, dLatLng],
          color: const Color(0xFF059669),
          width: 6,
          jointType: JointType.round,
        ),
      };
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        MapUtils.boundsFromLatLngList([pLatLng, dLatLng]),
        110,
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

    final pickupIcon = await RideRequestMapMarkers.getPickupMarkerIcon(
      etaText: 'PICKUP • 2 min',
    );
    final driverLabelIcon =
        await RideRequestMapMarkers.getDriverDistanceLabelIcon(
          text: 'You (400m away)',
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
          // icon: DriverMapMarkers.getDriverMarkerIcon(),
          icon: icon,
          zIndex: 3,
        ),
        // Driver label: "You (400m away)" positioned slightly below driver puck
        Marker(
          markerId: const MarkerId('driver_label'),
          position: LatLng(
            _currentLocation.latitude - 0.0003,
            _currentLocation.longitude,
          ),
          anchor: const Offset(0.5, 0.0),
          icon: driverLabelIcon,
          zIndex: 2,
        ),
        // Pickup marker with walking icon & black "PICKUP • 2 min" pill badge
        Marker(
          markerId: const MarkerId('pickup_marker'),
          position: pLatLng,
          anchor: const Offset(0.5, 0.9),
          icon: pickupIcon,
          zIndex: 4,
        ),
        // Destination marker
        Marker(
          markerId: const MarkerId('destination_marker'),
          position: dLatLng,
          anchor: const Offset(0.5, 1.0),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          zIndex: 3,
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

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        MapUtils.boundsFromLatLngList([_currentLocation, pLatLng, dLatLng]),
        0,
      ),
    );
  }

  String _getDriverInitials() {
    final name = _driverProfile?.fullName?.trim();
    if (name == null || name.isEmpty) return 'AK';
    final parts = name.split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  String _getFirstName() {
    final name = _driverProfile?.fullName?.trim();
    if (name == null || name.isEmpty) return 'Aarav';
    return name.split(' ').first;
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
              // Start repetitive sound & vibration alert according to mute status
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
        body: Stack(
          children: [
            // 1. Google Map View with dynamic styling
            CustomMapView(
              initialCameraPosition: _currentLocation,
              initialZoom: 16.0,
              markers: _markers,
              polylines: _polylines,
              circles: _circles,
              myLocationEnabled:
                  false, // Custom puck marker used for high design fidelity
              myLocationButtonEnabled: false,
              customMapStyleAsset: _isDarkMap
                  ? 'packages/shared_core/assets/mapTheme/darkMap.json'
                  : null,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),

            // 2. Top Header: Navigation HUD if ActiveTripState, or DriverStatusTopBar otherwise
            BlocBuilder<RideDispatchCubit, RideDispatchState>(
              builder: (context, dispatchState) {
                // Default Online/Offline top bar
                return SafeArea(
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
                );
              },
            ),

            // 2.5 Floating Right Action Buttons when on Active Trip: SOS (shield), Sound, Recenter
            BlocBuilder<RideDispatchCubit, RideDispatchState>(
              builder: (context, dispatchState) {
                if (dispatchState is! ActiveTripState) {
                  return const SizedBox.shrink();
                }

                return Positioned(
                  right: 16,
                  bottom:
                      345, // positioned right above the bottom active trip card
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Target Recenter button
                      GestureDetector(
                        onTap: _fetchCurrentLocation,
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
                    ],
                  ),
                );
              },
            ),

            // Floating Route Summary Chip on Map (Visible when TripCompletedSummaryState is active)
            BlocBuilder<RideDispatchCubit, RideDispatchState>(
              builder: (context, dispatchState) {
                if (dispatchState is! TripCompletedSummaryState) {
                  return const SizedBox.shrink();
                }

                final req = dispatchState.request;
                final distKm = '4.8';
                final durMin = req.estimatedDurationMin ?? 14;

                return Positioned(
                  left: 20,
                  top: MediaQuery.of(context).size.height * 0.35,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 16,
                          color: Color(0xFF059669),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$distKm km Route',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          '•',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$durMin mins',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // 4. Bottom Main Driver Dashboard Sheet (When no active ride)
            BlocBuilder<RideDispatchCubit, RideDispatchState>(
              builder: (context, dispatchState) {
                if (dispatchState is ActiveTripState ||
                    dispatchState is RideRequestReceivedState ||
                    dispatchState is TripCompletedSummaryState) {
                  return const SizedBox.shrink();
                }

                return Positioned(
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
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: RIDENEST PARTNER + Greeting & Today's Net card
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'RIDENEST PARTNER',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF64748B)
                                          .withValues(alpha: 0.9),
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ready to drive, ${_getFirstName()}?',
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0F172A),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),

                              // Today's Net badge card
                              // Container(
                              //   padding: const EdgeInsets.symmetric(
                              //     horizontal: 14,
                              //     vertical: 8,
                              //   ),
                              //   decoration: BoxDecoration(
                              //     color: const Color(0xFFF8FAFC),
                              //     borderRadius: BorderRadius.circular(16),
                              //     border: Border.all(
                              //       color: const Color(0xFFE2E8F0),
                              //     ),
                              //   ),
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.end,
                              //     mainAxisSize: MainAxisSize.min,
                              //     children: [
                              //       const Text(
                              //         "TODAY'S NET",
                              //         style: TextStyle(
                              //           fontSize: 9.5,
                              //           fontWeight: FontWeight.w800,
                              //           color: Color(0xFF94A3B8),
                              //           letterSpacing: 0.5,
                              //         ),
                              //       ),
                              //       const SizedBox(height: 3),
                              //       Row(
                              //         mainAxisSize: MainAxisSize.min,
                              //         children: [
                              //           Text(
                              //             'Rs. ${_driverProfile?.totalRides != null ? ((_driverProfile!.totalRides! * 160)).toStringAsFixed(0) : "0"}',
                              //             style: const TextStyle(
                              //               fontSize: 13,
                              //               fontWeight: FontWeight.w900,
                              //               color: Color(0xFF0F172A),
                              //             ),
                              //           ),
                              //           const SizedBox(width: 4),
                              //           Text(
                              //             '• ${_driverProfile?.totalRides ?? 0} trips',
                              //             style: const TextStyle(
                              //               fontSize: 12,
                              //               fontWeight: FontWeight.w700,
                              //               color: Color(0xFF64748B),
                              //             ),
                              //           ),
                              //           const SizedBox(width: 4),
                              //           const Icon(
                              //             Icons.show_chart_rounded,
                              //             size: 16,
                              //             color: Color(0xFF64748B),
                              //           ),
                              //         ],
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                          const SizedBox(height: 18),

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
                                fuelPercentage: 82,
                                onVehicleSelected: (selected) {
                                  setState(() {
                                    _selectedVehicleOverride = selected;
                                  });
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 18),

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
                                height: 60,
                                borderRadius: 20,
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
                );
              },
            ),

            // 5. Overlays: Incoming Request, Active Trip, Trip Summary
            BlocBuilder<RideDispatchCubit, RideDispatchState>(
              builder: (context, state) {
                if (state is RideRequestReceivedState) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: RideRequestSheet(
                      request: state.request,
                      remainingSeconds: state.remainingSeconds,
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
                  );
                } else if (state is ActiveTripState) {
                  final req = state.request;
                  final pLat = req.pickupLat ?? _currentLocation.latitude;
                  final pLng = req.pickupLng ?? _currentLocation.longitude;
                  final dLat = req.dropoffLat ?? _currentLocation.latitude;
                  final dLng = req.dropoffLng ?? _currentLocation.longitude;

                  final distanceMeters = TripLocationUtils.distanceInMeters(
                    _currentLocation.latitude,
                    _currentLocation.longitude,
                    pLat,
                    pLng,
                  );

                  // If in full screen in-app view, show a floating card/pill to restore panel
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      state.currentStatus == 'IN_PROGRESS'
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
                      tripState: state,
                      distanceToPickupMeters: distanceMeters,
                      isFullScreenMap: _isFullScreenMap,
                      onToggleFullScreen: () {
                        setState(() {
                          _isFullScreenMap = !_isFullScreenMap;
                        });
                      },
                      onOpenGoogleMaps: () async {
                        // When in progress, navigate to destination; otherwise to pickup
                        final targetLat = state.currentStatus == 'IN_PROGRESS'
                            ? dLat
                            : pLat;
                        final targetLng = state.currentStatus == 'IN_PROGRESS'
                            ? dLng
                            : pLng;

                        final success =
                            await MapUtils.launchGoogleMapsNavigation(
                              destLat: targetLat,
                              destLng: targetLng,
                              originLat: _currentLocation.latitude,
                              originLng: _currentLocation.longitude,
                            );

                        if (!success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not launch Google Maps.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  );
                } else if (state is TripCompletedSummaryState) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: TripSummarySheet(summary: state),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
