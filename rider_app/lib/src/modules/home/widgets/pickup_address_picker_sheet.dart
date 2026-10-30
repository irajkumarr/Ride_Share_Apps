import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_core/models/location/address_model.dart';
import 'package:shared_core/models/location/lat_lng_model.dart';
import 'package:shared_core/services/location/location_service.dart';
import 'package:shared_core/shared_core.dart';

import '../../../data/repo/places_repo.dart';
import 'map_location_picker_sheet.dart';

/// Modal bottom sheet for choosing or updating the pickup address.
/// Provides:
/// 1. Address search with live suggestions.
/// 2. Direct "Choose on Map" button opening [MapLocationPickerSheet].
/// 3. "Use Current Location" (GPS) quick action.
/// 4. Recent and favorite places list.
class PickupAddressPickerSheet extends StatefulWidget {
  final LatLng currentCoordinates;
  final AddressModel? currentAddress;

  const PickupAddressPickerSheet({
    super.key,
    required this.currentCoordinates,
    this.currentAddress,
  });

  /// Displays the pickup address picker modal and returns the chosen [AddressModel] (or null if cancelled).
  static Future<AddressModel?> show(
    BuildContext context, {
    required LatLng currentCoordinates,
    AddressModel? currentAddress,
  }) {
    return showModalBottomSheet<AddressModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: PickupAddressPickerSheet(
          currentCoordinates: currentCoordinates,
          currentAddress: currentAddress,
        ),
      ),
    );
  }

  @override
  State<PickupAddressPickerSheet> createState() =>
      _PickupAddressPickerSheetState();
}

class _PickupAddressPickerSheetState extends State<PickupAddressPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  List<AddressModel> _recentPlaces = [];
  List<AddressModel> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingGps = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadRecents();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _loadRecents() async {
    final placesRepo = sl<PlacesRepo>();
    final recents = await placesRepo.getRecentPlaces();
    if (mounted) {
      setState(() {
        _recentPlaces = recents;
      });
    }
  }

  void _onSearchQueryChanged(String query) {
    _debounceTimer?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      final placesRepo = sl<PlacesRepo>();
      final proximity = LatLngModel(
        latitude: widget.currentCoordinates.latitude,
        longitude: widget.currentCoordinates.longitude,
      );

      try {
        final results = await placesRepo.searchPlaces(
          trimmed,
          proximity: proximity,
        );
        if (mounted) {
          setState(() {
            _isSearching = false;
            _searchResults = results;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _isSearching = false;
            _searchResults = [];
          });
        }
      }
    });
  }

  Future<void> _pickOnMap() async {
    HapticFeedback.lightImpact();
    final address = await MapLocationPickerSheet.show(
      context,
      initialLocation: widget.currentCoordinates,
      title: 'Choose Pickup on Map',
    );

    if (address != null && mounted) {
      Navigator.of(context).pop(address);
    }
  }

  Future<void> _useCurrentGpsLocation() async {
    setState(() => _isLoadingGps = true);
    HapticFeedback.lightImpact();

    final locationService = sl<LocationService>();
    final hasPermission = await locationService.ensurePermission();

    if (hasPermission) {
      final pos = await locationService.getCurrentLocation();
      if (pos != null && mounted) {
        final placesRepo = sl<PlacesRepo>();
        try {
          final resolved = await placesRepo.reverseGeocode(pos);
          final finalAddress =
              resolved ??
              AddressModel(
                id: 'current_gps',
                title: 'Current Location',
                formattedAddress:
                    '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}',
                coordinates: pos,
                country: 'Nepal',
              );

          if (mounted) {
            setState(() => _isLoadingGps = false);
            Navigator.of(context).pop(finalAddress);
            return;
          }
        } catch (_) {}
      }
    }

    if (mounted) {
      setState(() => _isLoadingGps = false);
      AppAlerts.info(context, 'Could not retrieve GPS location.');
    }
  }

  void _selectAddress(AddressModel address) {
    HapticFeedback.selectionClick();
    Navigator.of(context).pop(address);
  }

  @override
  Widget build(BuildContext context) {
    final queryText = _searchController.text.trim();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // Header Row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Choose Pickup Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 22,
                      color: Color(0xFF64748B),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  onChanged: _onSearchQueryChanged,
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search address, landmark or area...',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF64748B),
                      size: 22,
                    ),
                    suffixIcon: queryText.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.cancel_rounded,
                              size: 18,
                              color: Color(0xFF94A3B8),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchQueryChanged('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Quick Actions: "Choose on Map" and "Use Current Location"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickActionButton(
                      icon: Icons.map_rounded,
                      iconColor: const Color(0xFF10B981),
                      title: 'Choose on Map',
                      subtitle: 'Pinpoint on map',
                      onTap: _pickOnMap,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionButton(
                      icon: Icons.my_location_rounded,
                      iconColor: const Color(0xFF2563EB),
                      title: 'Current Location',
                      subtitle: _isLoadingGps
                          ? 'Locating...'
                          : 'Use device GPS',
                      isLoading: _isLoadingGps,
                      onTap: _useCurrentGpsLocation,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),

            // Content Area: Search Results or Recent Places
            Flexible(
              child: queryText.isNotEmpty
                  ? _buildSearchResultsView()
                  : _buildRecentPlacesView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(icon, size: 18, color: iconColor),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultsView() {
    if (_isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(Color(0xFF0F172A)),
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_off_rounded,
                size: 36,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(height: 12),
              const Text(
                'No locations found',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Try searching with a different street name or use the map picker.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickOnMap,
                icon: const Icon(Icons.map_rounded, size: 16),
                label: const Text('Pick on Map'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F172A),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
      itemBuilder: (context, index) {
        final place = _searchResults[index];
        return _buildPlaceTile(place);
      },
    );
  }

  Widget _buildRecentPlacesView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SAVED & RECENT PLACES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          if (_recentPlaces.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No recent addresses. Search or select a spot on the map.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            )
          else
            ..._recentPlaces.take(8).map((place) => _buildPlaceTile(place)),
        ],
      ),
    );
  }

  Widget _buildPlaceTile(AddressModel place) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectAddress(place),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    Icons.place_outlined,
                    size: 18,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.title.isNotEmpty ? place.title : 'Selected Place',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      place.formattedAddress.isNotEmpty
                          ? place.formattedAddress
                          : '${place.coordinates.latitude.toStringAsFixed(4)}, ${place.coordinates.longitude.toStringAsFixed(4)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
