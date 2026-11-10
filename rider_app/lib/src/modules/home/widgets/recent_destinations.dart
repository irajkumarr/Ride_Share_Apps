import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_core/shared_core.dart';

import '../blocs/ride_search_cubit.dart';

class RecentPlaceItem {
  final String title;
  final String subtitle;
  final String etaText;
  final LatLngModel latLng;

  const RecentPlaceItem({
    required this.title,
    required this.subtitle,
    required this.etaText,
    required this.latLng,
  });
}

/// Recent Destinations list with Pin Icon, Address, and Travel Time ETA.
class RecentDestinations extends StatelessWidget {
  final ValueChanged<AddressModel> onSelectDestination;
  final VoidCallback onSearchPressed;

  const RecentDestinations({
    super.key,
    required this.onSelectDestination,
    required this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RideSearchCubit, RideSearchState>(
      builder: (context, state) {
        final recents = (state is RideSearchInitial)
            ? state.recents
            : context.read<RideSearchCubit>().cachedRecents;

        if (recents.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: InkWell(
              onTap: onSearchPressed,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      color: Color(0xFF94A3B8),
                      size: 22,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Recent destinations will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.search_rounded,
                      color: Color(0xFF94A3B8),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final times = ['8 min', '12 min', '15 min', '20 min', '25 min'];
        final items = recents.take(3).toList().asMap().entries.map((e) {
          final place = e.value;
          return RecentPlaceItem(
            title: place.title,
            subtitle: place.formattedAddress,
            etaText: times[e.key % times.length],
            latLng: place.coordinates,
          );
        }).toList();

        return Column(
          children: items.map((item) {
            return InkWell(
              onTap: () {
                onSelectDestination(
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
}
