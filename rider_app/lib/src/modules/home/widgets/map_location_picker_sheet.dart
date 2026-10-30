import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_core/models/location/address_model.dart';
import 'package:shared_core/models/location/lat_lng_model.dart';
import 'package:shared_core/services/location/location_service.dart';
import 'package:shared_core/shared_core.dart';

import '../../../data/repo/places_repo.dart';

/// Full-screen interactive map location picker.
/// Designed specifically for realistic, fluid ride-sharing workflows (Uber / Lyft style).
/// Eagerly claims touch gestures to ensure completely smooth, unhindered 360° panning and zooming.
class MapLocationPickerSheet extends StatefulWidget {
  final LatLng initialLocation;
  final String title;

  const MapLocationPickerSheet({
    super.key,
    required this.initialLocation,
    this.title = 'Set pickup location',
  });

  /// Opens the interactive map picker as a full-screen view and returns the selected [AddressModel].
  static Future<AddressModel?> show(
    BuildContext context, {
    required LatLng initialLocation,
    String title = 'Set pickup location',
  }) {
    return Navigator.of(context).push<AddressModel>(
      PageRouteBuilder<AddressModel>(
        fullscreenDialog: true,
        pageBuilder: (context, animation, secondaryAnimation) =>
            MapLocationPickerSheet(
              initialLocation: initialLocation,
              title: title,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.08);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(tween),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  State<MapLocationPickerSheet> createState() => _MapLocationPickerSheetState();
}

class _MapLocationPickerSheetState extends State<MapLocationPickerSheet>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  late LatLng _cameraTarget;
  bool _isMoving = false;
  bool _isGeocoding = false;
  bool _isLocatingGps = false;

  AddressModel? _resolvedAddress;
  Timer? _debounceTimer;

  late final AnimationController _pinAnimController;
  late final Animation<double> _pinLiftAnimation;
  late final Animation<double> _shadowScaleAnimation;
  late final Animation<double> _shadowOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _cameraTarget = widget.initialLocation;

    _pinAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _pinLiftAnimation = Tween<double>(begin: 0, end: -14).animate(
      CurvedAnimation(parent: _pinAnimController, curve: Curves.easeOutCubic),
    );

    _shadowScaleAnimation = Tween<double>(begin: 1.0, end: 0.60).animate(
      CurvedAnimation(parent: _pinAnimController, curve: Curves.easeOutCubic),
    );

    _shadowOpacityAnimation = Tween<double>(begin: 0.28, end: 0.10).animate(
      CurvedAnimation(parent: _pinAnimController, curve: Curves.easeOutCubic),
    );

    // Initial reverse geocode of starting location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reverseGeocodeTarget(_cameraTarget);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _pinAnimController.dispose();
    _mapController = null;
    super.dispose();
  }

  void _onCameraMoveStarted() {
    _debounceTimer?.cancel();
    if (!_isMoving) {
      setState(() => _isMoving = true);
      _pinAnimController.forward();
    }
  }

  void _onCameraMove(CameraPosition position) {
    _cameraTarget = position.target;
  }

  void _onCameraIdle() {
    if (_isMoving) {
      setState(() => _isMoving = false);
      _pinAnimController.reverse();
      HapticFeedback.selectionClick();
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 320), () {
      _reverseGeocodeTarget(_cameraTarget);
    });
  }

  Future<void> _reverseGeocodeTarget(LatLng target) async {
    if (!mounted) return;
    setState(() => _isGeocoding = true);

    final placesRepo = sl<PlacesRepo>();
    final coords = LatLngModel(
      latitude: target.latitude,
      longitude: target.longitude,
    );

    try {
      final address = await placesRepo.reverseGeocode(coords);
      if (mounted) {
        setState(() {
          _isGeocoding = false;
          _resolvedAddress =
              address ??
              AddressModel(
                id: 'pin_${target.latitude.toStringAsFixed(4)}_${target.longitude.toStringAsFixed(4)}',
                title: 'Pinned Location',
                formattedAddress:
                    '${target.latitude.toStringAsFixed(4)}, ${target.longitude.toStringAsFixed(4)}',
                coordinates: coords,
                country: 'Nepal',
              );
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isGeocoding = false;
          _resolvedAddress = AddressModel(
            id: 'pin_${target.latitude.toStringAsFixed(4)}_${target.longitude.toStringAsFixed(4)}',
            title: 'Pinned Location',
            formattedAddress:
                '${target.latitude.toStringAsFixed(4)}, ${target.longitude.toStringAsFixed(4)}',
            coordinates: coords,
            country: 'Nepal',
          );
        });
      }
    }
  }

  Future<void> _moveToCurrentGps() async {
    if (_isLocatingGps) return;
    setState(() => _isLocatingGps = true);
    HapticFeedback.lightImpact();

    final locationService = sl<LocationService>();
    final pos = await locationService.getCurrentLocation();
    if (pos != null && mounted) {
      final target = LatLng(pos.latitude, pos.longitude);
      _cameraTarget = target;
      try {
        await _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: target, zoom: 16.5),
          ),
        );
      } catch (_) {}
      _reverseGeocodeTarget(target);
    }

    if (mounted) {
      setState(() => _isLocatingGps = false);
    }
  }

  void _confirmSelection() {
    final address =
        _resolvedAddress ??
        AddressModel(
          id: 'pin_${_cameraTarget.latitude.toStringAsFixed(4)}_${_cameraTarget.longitude.toStringAsFixed(4)}',
          title: 'Pinned Location',
          formattedAddress:
              '${_cameraTarget.latitude.toStringAsFixed(4)}, ${_cameraTarget.longitude.toStringAsFixed(4)}',
          coordinates: LatLngModel(
            latitude: _cameraTarget.latitude,
            longitude: _cameraTarget.longitude,
          ),
          country: 'Nepal',
        );

    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(address);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mapTheme = isDark
        ? 'packages/shared_core/assets/mapTheme/darkMap.json'
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Fullscreen Google Map with Eager Touch Capture (No drag conflicts)
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.initialLocation,
                zoom: 16.2,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              // EagerGestureRecognizer ensures all pan, slide, pinch gestures are captured smoothly
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
              onMapCreated: (controller) {
                _mapController = controller;
                if (mapTheme != null) {
                  MapUtils.setMapStyle(controller, mapTheme);
                }
              },
              onCameraMoveStarted: _onCameraMoveStarted,
              onCameraMove: _onCameraMove,
              onCameraIdle: _onCameraIdle,
            ),
          ),

          // 2. Realistic Ride-Sharing Center Pin with Ground Shadow & Physics Lift
          Center(
            child: AnimatedBuilder(
              animation: _pinAnimController,
              builder: (context, child) {
                return SizedBox(
                  width: 80,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ground Contact Shadow
                      Positioned(
                        bottom: 24,
                        child: Opacity(
                          opacity: _shadowOpacityAnimation.value,
                          child: Transform.scale(
                            scaleX: _shadowScaleAnimation.value,
                            scaleY: _shadowScaleAnimation.value,
                            child: Container(
                              width: 18,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.all(
                                  Radius.elliptical(18, 6),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Animated Lifting Pin
                      Positioned(
                        bottom: 26 - _pinLiftAnimation.value,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Pin Head
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.28),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF10B981),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Pin Point Needle
                            CustomPaint(
                              size: const Size(10, 8),
                              painter: const _PinStemPainter(
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 3. Floating Top Bar with Elevated Back Button & Title Pill
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 3,
                  shadowColor: Colors.black26,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFF0F172A),
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Floating Recenter-on-GPS Button
          Positioned(
            right: 16,
            bottom: 215,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 4,
              shadowColor: Colors.black26,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _moveToCurrentGps,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: _isLocatingGps
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                Color(0xFF0F172A),
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.my_location_rounded,
                            color: Color(0xFF0F172A),
                            size: 22,
                          ),
                  ),
                ),
              ),
            ),
          ),

          // 5. Elegant Bottom Confirmation Card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location Info Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFA7F3D0),
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.location_on_rounded,
                            color: Color(0xFF059669),
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'PICKUP SPOT',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF10B981),
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                if (_isGeocoding) ...[
                                  const SizedBox(width: 8),
                                  const SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      valueColor: AlwaysStoppedAnimation(
                                        Color(0xFF10B981),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _isMoving
                                  ? 'Pinning location...'
                                  : (_resolvedAddress?.title.isNotEmpty == true
                                        ? _resolvedAddress!.title
                                        : 'Pinned Location'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isMoving
                                  ? 'Release map to update location'
                                  : (_resolvedAddress
                                                ?.formattedAddress
                                                .isNotEmpty ==
                                            true
                                        ? _resolvedAddress!.formattedAddress
                                        : '${_cameraTarget.latitude.toStringAsFixed(4)}, ${_cameraTarget.longitude.toStringAsFixed(4)}'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isMoving ? null : _confirmSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF94A3B8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Confirm Pickup Location',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Precise painter for the downward pin needle stem.
class _PinStemPainter extends CustomPainter {
  final Color color;
  const _PinStemPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PinStemPainter oldDelegate) =>
      color != oldDelegate.color;
}
