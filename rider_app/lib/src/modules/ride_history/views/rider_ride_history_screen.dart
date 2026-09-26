import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rider_app/src/data/remote/dto/rider_ride_history_dto.dart';
import 'package:rider_app/src/modules/ride_history/blocs/rider_ride_history_cubit.dart';
import 'package:shared_core/shared_core.dart';

/// Screen displaying all historical and active rides for the authenticated rider.
class RiderRideHistoryScreen extends StatefulWidget {
  const RiderRideHistoryScreen({super.key});

  @override
  State<RiderRideHistoryScreen> createState() => _RiderRideHistoryScreenState();
}

class _RiderRideHistoryScreenState extends State<RiderRideHistoryScreen> {
  String _selectedFilter = 'ALL'; // 'ALL', 'COMPLETED', 'CANCELLED', 'ACTIVE'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RiderRideHistoryCubit>().fetchRides();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.chevron_left_rounded,
            size: 30,
            color: Color(0xFF111827),
          ),
        ),
        centerTitle: true,
        title: Column(
          children: const [
            Text(
              'RIDENEST RIDER',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'My Rides & Trips',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF3F4F6), height: 1),
        ),
      ),
      body: BlocConsumer<RiderRideHistoryCubit, RiderRideHistoryState>(
        listener: (context, state) {
          if (state is RiderRideHistoryFailure) {
            AppAlerts.error(context, state.message);
          }
          if (state is RiderRideHistoryLoading) {
            LoadingOverlay.show();
          } else {
            LoadingOverlay.hide();
          }
        },
        builder: (context, state) {
          if (state is RiderRideHistoryLoaded) {
            final allRides = state.rides;
            final filteredRides = _filterRides(allRides);

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<RiderRideHistoryCubit>().fetchRides();
              },
              color: Colors.black,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // Filter Chips & Summary Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterTabs(allRides),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_selectedFilter.toUpperCase()} RIDES (${filteredRides.length})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF6B7280),
                                  letterSpacing: 0.8,
                                ),
                              ),
                              if (allRides.isNotEmpty)
                                Text(
                                  'Total Spent: Rs. ${_calculateTotalSpent(filteredRides).toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Ride List or Empty State
                  if (filteredRides.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final ride = filteredRides[index];
                          return _buildRideCard(ride);
                        }, childCount: filteredRides.length),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
                ],
              ),
            );
          }

          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildFilterTabs(List<RiderRideHistoryDto> allRides) {
    final filters = ['ALL', 'COMPLETED', 'CANCELLED', 'ACTIVE'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          final count = _getFilterCount(allRides, filter);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF111827) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF111827)
                        : const Color(0xFFE5E7EB),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      filter,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF4B5563),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.2)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  int _getFilterCount(List<RiderRideHistoryDto> rides, String filter) {
    if (filter == 'ALL') return rides.length;
    if (filter == 'COMPLETED') {
      return rides.where((r) => r.status?.toUpperCase() == 'COMPLETED').length;
    }
    if (filter == 'CANCELLED') {
      return rides
          .where((r) => r.status != null && r.status!.toUpperCase().contains('CANCEL'))
          .length;
    }
    if (filter == 'ACTIVE') {
      return rides.where((r) {
        final st = r.status?.toUpperCase();
        return st != null && st != 'COMPLETED' && !st.contains('CANCEL');
      }).length;
    }
    return 0;
  }

  List<RiderRideHistoryDto> _filterRides(List<RiderRideHistoryDto> rides) {
    if (_selectedFilter == 'ALL') return rides;
    if (_selectedFilter == 'COMPLETED') {
      return rides
          .where((r) => r.status?.toUpperCase() == 'COMPLETED')
          .toList();
    }
    if (_selectedFilter == 'CANCELLED') {
      return rides
          .where((r) => r.status != null && r.status!.toUpperCase().contains('CANCEL'))
          .toList();
    }
    if (_selectedFilter == 'ACTIVE') {
      return rides.where((r) {
        final st = r.status?.toUpperCase();
        return st != null && st != 'COMPLETED' && !st.contains('CANCEL');
      }).toList();
    }
    return rides;
  }

  double _calculateTotalSpent(List<RiderRideHistoryDto> rides) {
    double total = 0.0;
    for (final r in rides) {
      if (r.status?.toUpperCase() == 'COMPLETED') {
        total += (r.finalFare ?? r.estimatedFare ?? 0.0);
      }
    }
    return total;
  }

  Widget _buildRideCard(RiderRideHistoryDto ride) {
    final status = ride.status?.toUpperCase() ?? 'REQUESTED';
    final isCompleted = status == 'COMPLETED';
    final isCancelled = status.contains('CANCEL');

    Color badgeColor;
    Color badgeBg;
    String badgeText = status;

    if (isCompleted) {
      badgeColor = const Color(0xFF10B981);
      badgeBg = const Color(0xFFECFDF5);
      badgeText = 'COMPLETED';
    } else if (isCancelled) {
      badgeColor = const Color(0xFFEF4444);
      badgeBg = const Color(0xFFFEF2F2);
      badgeText = 'CANCELLED';
    } else {
      badgeColor = const Color(0xFF3B82F6);
      badgeBg = const Color(0xFFEFF6FF);
      badgeText = status.replaceAll('_', ' ');
    }

    final fare = ride.finalFare ?? ride.estimatedFare ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Ride ID / Time and Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.two_wheeler_rounded,
                        size: 18,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trip #${ride.id != null && ride.id!.length > 8 ? ride.id!.substring(0, 8) : (ride.id ?? '---')}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (ride.createdAt != null &&
                            ride.createdAt!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            _formatDateTime(ride.createdAt!),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: badgeColor,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 14),

            // Route: Pickup and Destination
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 32,
                      color: const Color(0xFFE5E7EB),
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF3333),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.pickupAddress ?? "-",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        ride.dropoffAddress ?? "-",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 12),

            // Bottom Driver & Fare info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.person_rounded,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      ride.driverName?.isNotEmpty == true
                          ? ride.driverName!
                          : (ride.status == 'REQUESTED' ? 'Searching Driver' : 'Assigned Driver'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    if (ride.licensePlate != null && ride.licensePlate!.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        '• ${ride.licensePlate}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  'Rs. ${fare.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isCompleted
                        ? const Color(0xFF111827)
                        : (isCancelled
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF2563EB)),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final date =
          '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute.toString().padLeft(2, '0');
      return '$date at $hour:$min $amPm';
    } catch (_) {
      return isoString;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 40,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Rides Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'ALL'
                  ? 'You haven\'t taken any rides yet. Book your first trip to get started!'
                  : 'No rides matching the "$_selectedFilter" filter were found.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                context.read<RiderRideHistoryCubit>().fetchRides();
              },
              icon: const Icon(
                Icons.refresh_rounded,
                size: 18,
                color: Color(0xFF111827),
              ),
              label: const Text(
                'Refresh Trips',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD1D5DB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
