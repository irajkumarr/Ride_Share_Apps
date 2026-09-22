import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_core/shared_core.dart';

import '../blocs/ride_search_cubit.dart';

/// Modern ride-hailing address search sheet.
/// Pickup + destination in one route card, saved places as quick chips,
/// recents as a clean list, skeleton loading and a helpful empty state.
class DestinationSearchSheet extends StatefulWidget {
  final LatLngModel? currentPosition;
  final bool initialFocusDestination;

  const DestinationSearchSheet({
    super.key,
    this.currentPosition,
    this.initialFocusDestination = true,
  });

  static Future<void> show(
    BuildContext context, {
    LatLngModel? currentPosition,
    bool initialFocusDestination = true,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      elevation: 0,
      enableDrag: true,
      isDismissible: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: DestinationSearchSheet(
          currentPosition: currentPosition,
          initialFocusDestination: initialFocusDestination,
        ),
      ),
    );
  }

  @override
  State<DestinationSearchSheet> createState() => _DestinationSearchSheetState();
}

class _DestinationSearchSheetState extends State<DestinationSearchSheet> {
  late final TextEditingController _pickupController;
  late final TextEditingController _destinationController;
  final FocusNode _pickupFocus = FocusNode();
  final FocusNode _destinationFocus = FocusNode();
  Timer? _debounce;
  bool _isSearchingPickup = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<RideSearchCubit>();
    final currentTitle = cubit.currentPickup?.title;
    final defaultPickup =
        (currentTitle == null ||
            currentTitle == 'Your location' ||
            currentTitle == 'Current Location')
        ? 'Udaypur fresh butcher shop'
        : currentTitle;
    _pickupController = TextEditingController(text: defaultPickup);
    _destinationController = TextEditingController(
      text: cubit.currentDestination?.title ?? '',
    );

    _isSearchingPickup = !widget.initialFocusDestination;

    _pickupFocus.addListener(_onFocusChanged);
    _destinationFocus.addListener(_onFocusChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      (widget.initialFocusDestination ? _destinationFocus : _pickupFocus)
          .requestFocus();
    });
  }

  void _onFocusChanged() {
    if (!mounted) return;
    if (_pickupFocus.hasFocus) {
      setState(() => _isSearchingPickup = true);
    } else if (_destinationFocus.hasFocus) {
      setState(() => _isSearchingPickup = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _pickupFocus.removeListener(_onFocusChanged);
    _destinationFocus.removeListener(_onFocusChanged);
    _pickupController.dispose();
    _destinationController.dispose();
    _pickupFocus.dispose();
    _destinationFocus.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query, {required bool isPickup}) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        context.read<RideSearchCubit>().searchPlaces(
          query,
          isPickup: isPickup,
          proximity: widget.currentPosition,
        );
      }
    });
  }

  void _selectPlace(AddressModel place, {required bool isPickup}) {
    HapticFeedback.selectionClick();
    final cubit = context.read<RideSearchCubit>();
    if (isPickup) {
      _pickupController.text = place.title;
      cubit.setPickup(place);
      if (_destinationController.text.trim().isEmpty) {
        setState(() => _isSearchingPickup = false);
        _destinationFocus.requestFocus();
      } else {
        Navigator.of(context).pop();
      }
    } else {
      _destinationController.text = place.title;
      cubit.setDestination(place);
      Navigator.of(context).pop();
    }
  }

  void _swapRoute() {
    final cubit = context.read<RideSearchCubit>();
    final pickup = cubit.currentPickup;
    final destination = cubit.currentDestination;
    if (pickup == null || destination == null) return;

    HapticFeedback.lightImpact();
    cubit.setPickup(destination);
    cubit.setDestination(pickup);
    final pickupText = _pickupController.text;
    _pickupController.text = _destinationController.text;
    _destinationController.text = pickupText;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 1,
      minChildSize: 0.70,
      // maxChildSize: 0.96,
      maxChildSize: 1,
      expand: false,
      snap: true,
      snapSizes: const [0.70, 0.92, 0.96],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 24,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Drag Handle
                // Center(
                //   child: Padding(
                //     padding: const EdgeInsets.only(top: 12, bottom: 12),
                //     child: Container(
                //       width: 48,
                //       height: 5,
                //       decoration: BoxDecoration(
                //         color: const Color(0xFFD1D5DB),
                //         borderRadius: BorderRadius.circular(3),
                //       ),
                //     ),
                //   ),
                // ),

                // 2. Pickup & Destination Floating Card (Matching Screenshot)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildRouteCard(),
                ),

                const SizedBox(height: 14),

                // 3. "Rides and addresses" bookmark section row
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16),
                //   child: InkWell(
                //     onTap: () {},
                //     borderRadius: BorderRadius.circular(12),
                //     child: Padding(
                //       padding: const EdgeInsets.symmetric(
                //         vertical: 10,
                //         horizontal: 4,
                //       ),
                //       child: Row(
                //         children: [
                //           // Bookmark with small orange tag
                //           Stack(
                //             clipBehavior: Clip.none,
                //             children: [
                //               const Icon(
                //                 Icons.bookmark_rounded,
                //                 size: 26,
                //                 color: Color(0xFF94A3B8),
                //               ),
                //               Positioned(
                //                 top: -2,
                //                 right: -2,
                //                 child: Container(
                //                   width: 8,
                //                   height: 8,
                //                   decoration: const BoxDecoration(
                //                     color: Color(0xFFFF5722),
                //                     shape: BoxShape.circle,
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //           const SizedBox(width: 14),
                //           const Expanded(
                //             child: Text(
                //               'Rides and addresses',
                //               style: TextStyle(
                //                 fontSize: 16,
                //                 fontWeight: FontWeight.w800,
                //                 color: Color(0xFF0F172A),
                //                 letterSpacing: -0.2,
                //               ),
                //             ),
                //           ),
                //           const Icon(
                //             Icons.chevron_right_rounded,
                //             size: 22,
                //             color: Color(0xFF94A3B8),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                const Divider(height: 16, color: Color(0xFFF1F5F9)),

                // 4. Smooth Scrollable Results / Recents Container
                Expanded(
                  child: BlocBuilder<RideSearchCubit, RideSearchState>(
                    builder: (context, state) {
                      return _buildBody(state, scrollController);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────── Route Card ─────────────────────────

  Widget _buildRouteCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1: PICKUP
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                // Light Green Walk / Pedestrian Icon Circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F7ED),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_walk_rounded,
                    color: Color(0xFF0F766E),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'PICKUP',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      TextField(
                        controller: _pickupController,
                        focusNode: _pickupFocus,
                        onChanged: (v) => _onQueryChanged(v, isPickup: true),
                        cursorColor: Colors.black,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Enter pickup address',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isSearchingPickup && _pickupController.text.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      _pickupController.clear();
                      _onQueryChanged('', isPickup: true);
                    },
                    icon: const Icon(
                      Icons.cancel_rounded,
                      size: 18,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
              ],
            ),
          ),

          // Divider inside card
          const Padding(
            padding: EdgeInsets.only(left: 74, right: 16),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // Row 2: DESTINATION
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                // Vibrant Orange Flag Icon Circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5722),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.flag_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'DESTINATION',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: Color(0xFFFF5722),
                        ),
                      ),
                      const SizedBox(height: 2),
                      TextField(
                        controller: _destinationController,
                        focusNode: _destinationFocus,
                        onChanged: (v) => _onQueryChanged(v, isPickup: false),
                        cursorColor: Colors.black,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Where to?',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_isSearchingPickup &&
                    _destinationController.text.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      _destinationController.clear();
                      _onQueryChanged('', isPickup: false);
                    },
                    icon: const Icon(
                      Icons.cancel_rounded,
                      size: 18,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Body States ─────────────────────────

  Widget _buildBody(RideSearchState state, ScrollController scrollController) {
    if (state is RideSearchLoading) {
      return const _SkeletonList();
    }

    if (state is RideSearchResultsLoaded) {
      if (state.results.isEmpty) {
        return _EmptyState(query: state.query);
      }
      return ListView.separated(
        controller: scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: state.results.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
        itemBuilder: (context, index) {
          final place = state.results[index];
          return _PlaceTile(
            title: place.title,
            subtitle: place.formattedAddress,
            query: state.query,
            onTap: () => _selectPlace(place, isPickup: state.isPickup),
          );
        },
      );
    }

    // Default mock places matching screenshot if none returned yet
    final defaultPlaces = const [
      AddressModel(
        id: 'ward_2',
        title: 'Ward 2',
        formattedAddress:
            'Madhyapur Thimi Municipality, Bhaktapur District, ...',
        coordinates: LatLngModel(latitude: 27.6802, longitude: 85.3855),
        country: 'Nepal',
      ),
      AddressModel(
        id: 'kaushaltar',
        title: 'Kaushaltar - Biruwa Rd 3',
        formattedAddress:
            'Ward 1, Suryabinayak Municipality, Bhaktapur Distr...',
        coordinates: LatLngModel(latitude: 27.6745, longitude: 85.3720),
        country: 'Nepal',
      ),
      AddressModel(
        id: 'balkot',
        title: 'Balkot Chowk',
        formattedAddress:
            'Bagmati, Bhaktapur District, Suryabinayak Municip...',
        coordinates: LatLngModel(latitude: 27.6690, longitude: 85.3650),
        country: 'Nepal',
      ),
      AddressModel(
        id: 'breeze',
        title: 'The Breeze Collection',
        formattedAddress:
            'Bagmati, Bhaktapur District, Suryabinayak Municip...',
        coordinates: LatLngModel(latitude: 27.6710, longitude: 85.3680),
        country: 'Nepal',
      ),
      AddressModel(
        id: 'nh03',
        title: 'NH03',
        formattedAddress: 'Ward 32, Kathmandu',
        coordinates: LatLngModel(latitude: 27.6880, longitude: 85.3470),
        country: 'Nepal',
      ),
      AddressModel(
        id: 'high_vision',
        title: 'High Vision Records',
        formattedAddress:
            'Bagmati, Bhaktapur District, Suryabinayak Municip...',
        coordinates: LatLngModel(latitude: 27.6730, longitude: 85.3690),
        country: 'Nepal',
      ),
      AddressModel(
        id: 'civil_hospital',
        title: 'Civil Service Hospital of Nepal',
        formattedAddress: 'Ward 31, Kathmandu',
        coordinates: LatLngModel(latitude: 27.6850, longitude: 85.3400),
        country: 'Nepal',
      ),
      AddressModel(
        id: 'city_centre',
        title: 'City Centre',
        formattedAddress: 'Ward 1, Kathmandu',
        coordinates: LatLngModel(latitude: 27.7085, longitude: 85.3255),
        country: 'Nepal',
      ),
      AddressModel(
        id: 'sanchaya_kosh',
        title: 'Sanchaya Kosh Thamel',
        formattedAddress: 'Thamel, Kathmandu',
        coordinates: LatLngModel(latitude: 27.7150, longitude: 85.3120),
        country: 'Nepal',
      ),
    ];

    final recents = (state is RideSearchInitial && state.recents.isNotEmpty)
        ? state.recents
        : defaultPlaces;

    return ListView.separated(
      controller: scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: recents.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
      itemBuilder: (context, index) {
        final rec = recents[index];
        return _PlaceTile(
          title: rec.title,
          subtitle: rec.formattedAddress,
          onTap: () => _selectPlace(rec, isPickup: _isSearchingPickup),
        );
      },
    );
  }
}

// ───────────────────────── Components ─────────────────────────

class _PlaceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? query;
  final VoidCallback onTap;

  const _PlaceTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.query,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              // Circular grey pin icon
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF94A3B8),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HighlightedText(text: title, query: query),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
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
}

/// Bolds the matching part of the query inside the place title.
class _HighlightedText extends StatelessWidget {
  final String text;
  final String? query;

  const _HighlightedText({required this.text, this.query});

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );
    const strong = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w800,
      color: Colors.black,
    );

    final q = query?.trim().toLowerCase() ?? '';
    final start = q.isEmpty ? -1 : text.toLowerCase().indexOf(q);
    if (start < 0) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: strong,
      );
    }

    final end = start + q.length;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.substring(0, start), style: base),
          TextSpan(text: text.substring(start, end), style: strong),
          TextSpan(text: text.substring(end), style: base),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String? query;
  final String? title;
  final String? message;

  const _EmptyState({this.query, this.title, this.message});

  @override
  Widget build(BuildContext context) {
    final heading = title ?? 'No places found';
    final body =
        message ??
        'We couldn\'t find "$query". Try a landmark or a nearby area.';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F6F8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_rounded,
                size: 28,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              heading,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColor.gray,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pulsing placeholder rows shown while results load.
class _SkeletonList extends StatefulWidget {
  const _SkeletonList();

  @override
  State<_SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<_SkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.45, end: 1).animate(_controller),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (_) => const _SkeletonRow()),
          ),
        ),
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    const block = Color(0xFFEDEEF1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: block,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12,
                  width: 150,
                  decoration: BoxDecoration(
                    color: block,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: 230,
                  decoration: BoxDecoration(
                    color: block,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
