import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/shared_core.dart';

import 'destination_search_sheet.dart';
import 'ridenest_illustrations.dart';

class VehicleTier {
  final String id;
  final String name;
  final String description;
  final double baseFareNpr;
  final double perKmRate;
  final Widget illustration;
  final int etaMins;
  final int capacity;
  final bool hasLightning;
  final String? badgeText;
  final String? highlightText;

  const VehicleTier({
    required this.id,
    required this.name,
    required this.description,
    required this.baseFareNpr,
    required this.perKmRate,
    required this.illustration,
    required this.etaMins,
    required this.capacity,
    this.hasLightning = false,
    this.badgeText,
    this.highlightText,
  });
}

class RideBookingSheet extends StatefulWidget {
  final AddressModel pickup;
  final AddressModel destination;
  final RouteModel route;
  final double distanceKm;
  final int durationMins;
  final VoidCallback onCancel;
  final void Function({bool focusDestination})? onOpenSearch;
  final void Function({
    required VehicleTier selectedTier,
    required double fareNpr,
    required String paymentMethod,
    String? promoCode,
  })
  onConfirmBooking;

  const RideBookingSheet({
    super.key,
    required this.pickup,
    required this.destination,
    required this.route,
    required this.distanceKm,
    required this.durationMins,
    required this.onCancel,
    this.onOpenSearch,
    required this.onConfirmBooking,
  });

  @override
  State<RideBookingSheet> createState() => _RideBookingSheetState();
}

class _RideBookingSheetState extends State<RideBookingSheet> {
  int _selectedTierIndex = 0; // Default to 'Bike'
  bool _isRequesting = false;

  late final List<VehicleTier> _rideTiers = [
    VehicleTier(
      id: 'bike',
      name: 'Bike',
      description: 'Fastest through traffic',
      baseFareNpr: 45.0,
      perKmRate: 16.0,
      illustration: const VehicleTierIllustration(tierId: 'bike', size: 72),
      etaMins: 3,
      capacity: 1,
      hasLightning: true,
      badgeText: '⚡ QUICKEST',
      highlightText:
          '🛵 Fast single-rider trip • Helmet verified • Beat the jam',
    ),
    VehicleTier(
      id: 'fastest',
      name: 'Fastest',
      description: 'Quickest pickup nearby',
      baseFareNpr: 46.0,
      perKmRate: 18.0,
      illustration: const VehicleTierIllustration(tierId: 'fastest', size: 72),
      etaMins: 2,
      capacity: 3,
      hasLightning: true,
      badgeText: '🔥 NEAREST',
      highlightText: '⚡ Auto-matches closest available bike or cab to you',
    ),
    VehicleTier(
      id: 'economy',
      name: 'Economy',
      description: 'Budget-friendly ride',
      baseFareNpr: 120.0,
      perKmRate: 35.0,
      illustration: const VehicleTierIllustration(tierId: 'economy', size: 72),
      etaMins: 5,
      capacity: 4,
      badgeText: '⭐ BEST VALUE',
      highlightText:
          '🚗 Reliable everyday compact car • Air-conditioned • 4 seats',
    ),
    VehicleTier(
      id: 'comfort',
      name: 'Comfort',
      description: 'Spacious & Air-conditioned',
      baseFareNpr: 180.0,
      perKmRate: 48.0,
      illustration: const VehicleTierIllustration(tierId: 'comfort', size: 72),
      etaMins: 6,
      capacity: 4,
      badgeText: '✨ PREMIUM',
      highlightText:
          '💎 Top-rated executive sedans • Extra legroom • Quiet cabin',
    ),
    VehicleTier(
      id: 'xl',
      name: 'XL SUV',
      description: 'Room for 6 & extra bags',
      baseFareNpr: 240.0,
      perKmRate: 60.0,
      illustration: const VehicleTierIllustration(tierId: 'xl', size: 72),
      etaMins: 8,
      capacity: 6,
      badgeText: '👥 6 SEATS',
      highlightText:
          '🚐 Spacious 6-seater SUV • Ideal for groups & airport luggage',
    ),
  ];

  VehicleTier get _selectedTier {
    if (_selectedTierIndex >= _rideTiers.length) {
      return _rideTiers.first;
    }
    return _rideTiers[_selectedTierIndex];
  }

  double _calculateFare(VehicleTier tier) {
    final distance = widget.distanceKm > 0 ? widget.distanceKm : 1.0;
    final rawFare = tier.baseFareNpr + (distance * tier.perKmRate);
    final minFare = tier.id == 'bike' || tier.id == 'fastest'
        ? 45.0
        : tier.baseFareNpr;
    return rawFare.clamp(minFare, 99999.0).roundToDouble();
  }

  void _handleOpenSearch({bool focusDestination = true}) {
    HapticFeedback.lightImpact();
    if (widget.onOpenSearch != null) {
      widget.onOpenSearch!(focusDestination: focusDestination);
    } else {
      DestinationSearchSheet.show(
        context,
        currentPosition: widget.pickup.coordinates,
        initialFocusDestination: focusDestination,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedTier = _selectedTier;
    final fare = _calculateFare(selectedTier);

    final pickupText =
        widget.pickup.title.isNotEmpty &&
            widget.pickup.title != 'Your location' &&
            widget.pickup.title != 'Current Location'
        ? widget.pickup.title
        : 'Pickup Point';

    final destText = widget.destination.title.isNotEmpty
        ? widget.destination.title
        : 'Destination';

    final distanceKm = widget.distanceKm > 0 ? widget.distanceKm : 1.2;
    final durationMin = widget.durationMins > 0 ? widget.durationMins : 6;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 28,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Drag Handle
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 6),
                child: Container(
                  width: 42,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),

            // 2. Interactive Journey & Route Summary Header Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFF1F5F9),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    // Vertical visual route indicator
                    Column(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x3310B981),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1.5,
                          height: 20,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          color: const Color(0xFFCBD5E1),
                        ),
                        const Icon(
                          Icons.location_on_rounded,
                          color: Color(0xFFEF4444),
                          size: 14,
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),

                    // Tap-to-edit Pickup and Destination Addresses
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pickup Row (Tap to edit pickup)
                          InkWell(
                            onTap: () =>
                                _handleOpenSearch(focusDestination: false),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 4,
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    'PICKUP  ',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF64748B),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      pickupText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.edit_outlined,
                                    size: 13,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Dropoff Row (Tap to edit destination)
                          InkWell(
                            onTap: () =>
                                _handleOpenSearch(focusDestination: true),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 4,
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    'DROPOFF  ',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF64748B),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      destText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.edit_outlined,
                                    size: 13,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Trip stats chip (Distance • Time)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x06000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${distanceKm.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            '$durationMin min',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Cancel / dismiss button
                    InkWell(
                      onTap: widget.onCancel,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 3. Horizontal Scrollable Vehicle Category Cards
            SizedBox(
              height: 154,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                itemCount: _rideTiers.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final tier = _rideTiers[index];
                  final isSelected = index == _selectedTierIndex;
                  final tierFare = _calculateFare(tier);

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedTierIndex = index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      width: 124,
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
                              )
                            : null,
                        color: isSelected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.8 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? const [
                                BoxShadow(
                                  color: Color(0x180F172A),
                                  blurRadius: 14,
                                  offset: Offset(0, 4),
                                ),
                              ]
                            : const [
                                BoxShadow(
                                  color: Color(0x06000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Mini-Badge & Selection indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Badge (e.g. Quickest / Best Value)
                              if (tier.badgeText != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tier.badgeText!,
                                    style: TextStyle(
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.w900,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF475569),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(height: 14),

                              // Capacity Indicator or Checkmark
                              if (isSelected)
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0F172A),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    size: 11,
                                    color: Colors.white,
                                  ),
                                )
                              else
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.person_rounded,
                                      size: 11,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    Text(
                                      '${tier.capacity}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),

                          const Spacer(),

                          // Graphic / Illustration
                          Center(
                            child: SizedBox(
                              height: 52,
                              child: Center(child: tier.illustration),
                            ),
                          ),

                          // const Spacer(),

                          // ETA tag (e.g. 3 min away)
                          // Text(
                          //   '${tier.etaMins} min away',
                          //   style: const TextStyle(
                          //     fontSize: 10.5,
                          //     fontWeight: FontWeight.w600,
                          //     color: Color(0xFF64748B),
                          //   ),
                          // ),
                          // const SizedBox(height: 1),

                          // Tier Name (e.g. Bike / Economy)
                          Text(
                            tier.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),

                          // Price display
                          Row(
                            children: [
                              if (tier.hasLightning) ...[
                                const Icon(
                                  Icons.bolt_rounded,
                                  color: Color(0xFFF59E0B),
                                  size: 13,
                                ),
                                const SizedBox(width: 1),
                              ],
                              Text(
                                tier.id == 'fastest'
                                    ? 'from Rs. ${tierFare.toStringAsFixed(0)}'
                                    : 'Rs. ${tierFare.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // 4. Selected Tier Feature Highlight Banner
            if (selectedTier.highlightText != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        size: 14,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedTier.highlightText!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 14),

            // 5. Request Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // backgroundColor: const Color(
                    //   0xFFFF4824,
                    // ), // Vibrant RideNest Orange
                    backgroundColor: AppColor.secondary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide.none,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),

                  onPressed: _isRequesting
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          setState(() => _isRequesting = true);
                          widget.onConfirmBooking(
                            selectedTier: selectedTier,
                            fareNpr: fare,
                            paymentMethod: 'Cash',
                          );
                        },
                  child: _isRequesting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          children: [
                            Text(
                              'Request ${selectedTier.name}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const Spacer(),

                            // Fare Pill inside Button
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4.5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Rs. ${fare.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 6. Trust & Safety Guarantee Line
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.verified_user_rounded,
                      size: 12,
                      color: Color(0xFF64748B),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'RideNest Safety Shield: Insured trips • Verified partners • 24/7 SOS',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
