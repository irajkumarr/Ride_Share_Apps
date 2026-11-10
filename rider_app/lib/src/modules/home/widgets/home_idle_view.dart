import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'home_header.dart';
import 'location_pill.dart';
import 'recent_destinations.dart';
import 'ridenest_illustrations.dart';
import 'where_to_search_bar.dart';

/// The idle RideNest home dashboard displayed when no active ride is in progress.
class HomeIdleView extends StatelessWidget {
  final String pickupTitle;
  final VoidCallback onOpenPickupLocationPicker;
  final VoidCallback onOpenSearchSheet;
  final ValueChanged<AddressModel> onSelectDestination;
  final VoidCallback? onMenuPressed;

  const HomeIdleView({
    super.key,
    required this.pickupTitle,
    required this.onOpenPickupLocationPicker,
    required this.onOpenSearchSheet,
    required this.onSelectDestination,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Top Branding Bar & Hamburger Menu
            HomeHeader(onMenuPressed: onMenuPressed),
            const SizedBox(height: 6),

            // Location Picker Pill
            LocationPill(title: pickupTitle, onTap: onOpenPickupLocationPicker),
            const SizedBox(height: 18),

            // 2x2 Service Grid (Cargo, Delivery, Bike, Rides) - preserved
            // _buildServiceGrid(),
            // const SizedBox(height: 22),

            // "Where to?" rounded pill input bar
            WhereToSearchBar(onTap: onOpenSearchSheet),
            const SizedBox(height: 20),

            // Recent Destinations List
            RecentDestinations(
              onSelectDestination: onSelectDestination,
              onSearchPressed: onOpenSearchSheet,
            ),
            const SizedBox(height: 24),

            // Promotional Banner Cards (Safe Rides, Need Help?) - preserved
            // _buildPromoBanners(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 2x2 Services Grid: Cargo (-10%), Delivery (-20%), Bike, Rides (from 4 min)
  // ignore: unused_element
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
                onTap: onOpenSearchSheet,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildServiceCard(
                title: 'Delivery',
                badgeText: '-20%',
                badgeColor: const Color(0xFF111827),
                illustration: const DeliveryIllustration(size: 88),
                onTap: onOpenSearchSheet,
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
                onTap: onOpenSearchSheet,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildServiceCard(
                title: 'Rides',
                subtitle: 'from 4 min',
                illustration: const CarIllustration(size: 102),
                onTap: onOpenSearchSheet,
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

  /// Promotional / Feature Cards: SAFE RIDES and NEED HELP?
  // ignore: unused_element
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
}
