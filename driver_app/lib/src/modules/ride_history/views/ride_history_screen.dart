import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:driver_app/src/data/remote/dto/driver_ride_history_dto.dart';
import 'package:driver_app/src/modules/ride_history/blocs/driver_ride_history_cubit.dart';
import 'package:shared_core/core/ui/widgets/common/skeleton_loader.dart';
import 'package:shared_core/shared_core.dart';

/// Minimal, modern Ride History & Earnings screen for the authenticated driver.
/// Accurately renders authoritative ride records without mock or fake data.
/// Handles loading (shimmer skeleton), error (retryable), empty, and success states.
class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  String _selectedFilter = 'ALL'; // 'ALL', 'COMPLETED', 'ACTIVE', 'CANCELLED'

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverRideHistoryCubit>().fetchRides();
    });
  }

  Future<void> _refresh() async {
    await context.read<DriverRideHistoryCubit>().fetchRides();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: Color(0xFF0F172A),
                ),
                tooltip: 'Back',
              )
            : null,
        centerTitle: true,
        title: Column(
          children: const [
            Text(
              'RIDENEST DRIVER',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Ride History & Trips',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(
              Icons.refresh_rounded,
              size: 22,
              color: Color(0xFF334155),
            ),
            tooltip: 'Refresh Trips',
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: BlocConsumer<DriverRideHistoryCubit, DriverRideHistoryState>(
        listener: (context, state) {
          if (state is DriverRideHistoryFailure) {
            AppAlerts.error(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is DriverRideHistoryLoading ||
              state is DriverRideHistoryInitial) {
            return _buildShimmerView();
          }

          if (state is DriverRideHistoryFailure) {
            return _buildErrorView(state.message);
          }

          if (state is DriverRideHistoryLoaded) {
            final allRides = state.rides;
            final filteredRides = _filterRides(allRides);

            return RefreshIndicator(
              onRefresh: _refresh,
              color: const Color(0xFF0F172A),
              backgroundColor: Colors.white,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // Filter Pills and Summary Banner
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterTabs(allRides),
                          const SizedBox(height: 14),
                          _buildSummaryBanner(allRides, filteredRides),
                        ],
                      ),
                    ),
                  ),

                  // Rides List or Empty State
                  if (filteredRides.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(hasRides: allRides.isNotEmpty),
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

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            );
          }

          return _buildShimmerView();
        },
      ),
    );
  }

  // ── Summary Banner & Filter Tabs ──────────────────────────────────────────

  Widget _buildSummaryBanner(
    List<DriverRideHistoryDto> allRides,
    List<DriverRideHistoryDto> filteredRides,
  ) {
    final totalEarnings = _calculateTotalEarnings(filteredRides);
    final completedCount = filteredRides
        .where((r) => r.status?.toUpperCase() == 'COMPLETED')
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Total Earned
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL EARNED',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rs. ${totalEarnings.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF059669),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(width: 1, height: 32, color: const Color(0xFFE2E8F0)),

          // Trips Count
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'COMPLETED TRIPS',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$completedCount',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
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

  Widget _buildFilterTabs(List<DriverRideHistoryDto> allRides) {
    const filters = ['ALL', 'COMPLETED', 'ACTIVE', 'CANCELLED'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          final count = _getFilterCount(allRides, filter);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedFilter = filter);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFE2E8F0),
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
                              : const Color(0xFF475569),
                          letterSpacing: 0.3,
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
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Ride Card ─────────────────────────────────────────────────────────────

  Widget _buildRideCard(DriverRideHistoryDto ride) {
    final status = ride.status?.toUpperCase() ?? 'COMPLETED';
    final fare = ride.finalFare ?? ride.estimatedFare ?? 0.0;
    final formattedDate = _formatCreatedAt(ride.createdAt);
    final tripId = _formatTripId(ride.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showRideDetailsSheet(ride),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Trip ID & Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tripId,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF475569),
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _buildStatusBadge(status),
                  ],
                ),

                const SizedBox(height: 14),

                // Route Vertical Layout
                _buildRouteLayout(
                  pickup: ride.pickupAddress ?? 'Pickup spot',
                  dropoff: ride.dropoffAddress ?? 'Dropoff destination',
                ),

                const SizedBox(height: 14),

                // Bottom Divider & Meta Row
                Container(height: 1, color: const Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Passenger Name & Vehicle Plate
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ride.riderName?.isNotEmpty == true
                                  ? ride.riderName!
                                  : 'Passenger',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            if (ride.licensePlate != null &&
                                ride.licensePlate!.isNotEmpty)
                              Text(
                                ride.licensePlate!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    // Fare Amount
                    Row(
                      children: [
                        Text(
                          'Rs. ${fare.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Route Layout Widget ───────────────────────────────────────────────────

  Widget _buildRouteLayout({required String pickup, required String dropoff}) {
    return Column(
      children: [
        // Pickup Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const SizedBox(height: 3),
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 1.5,
                  height: 22,
                  color: const Color(0xFFCBD5E1),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                pickup,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),

        // Destination Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dropoff,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Status Badge ──────────────────────────────────────────────────────────

  Widget _buildStatusBadge(String status) {
    final Color textColor;
    final Color bgColor;

    if (status == 'COMPLETED') {
      textColor = const Color(0xFF059669);
      bgColor = const Color(0xFFECFDF5);
    } else if (status.contains('CANCEL')) {
      textColor = const Color(0xFFE11D48);
      bgColor = const Color(0xFFFFF1F2);
    } else {
      // Active states: IN_PROGRESS, DRIVER_ARRIVING, ACCEPTED
      textColor = const Color(0xFF2563EB);
      bgColor = const Color(0xFFEFF6FF);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ── Details Modal Sheet ───────────────────────────────────────────────────

  void _showRideDetailsSheet(DriverRideHistoryDto ride) {
    HapticFeedback.lightImpact();
    final status = ride.status?.toUpperCase() ?? 'COMPLETED';
    final fare = ride.finalFare ?? ride.estimatedFare ?? 0.0;
    final tripId = _formatTripId(ride.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tripId,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Trip Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(status),
              ],
            ),

            const SizedBox(height: 20),

            // Route Breakdown
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: _buildRouteLayout(
                pickup: ride.pickupAddress ?? 'Pickup spot',
                dropoff: ride.dropoffAddress ?? 'Dropoff destination',
              ),
            ),

            const SizedBox(height: 16),

            // Info rows
            _buildInfoRow('Date & Time', _formatCreatedAt(ride.createdAt)),
            _buildInfoRow(
              'Passenger',
              ride.riderName?.isNotEmpty == true
                  ? ride.riderName!
                  : 'Passenger',
            ),
            if (ride.riderPhone != null && ride.riderPhone!.isNotEmpty)
              _buildInfoRow('Passenger Phone', ride.riderPhone!),
            if (ride.vehicleMakeModel != null &&
                ride.vehicleMakeModel!.isNotEmpty)
              _buildInfoRow('Vehicle', ride.vehicleMakeModel!),
            if (ride.licensePlate != null && ride.licensePlate!.isNotEmpty)
              _buildInfoRow('License Plate', ride.licensePlate!),
            _buildInfoRow(
              'Total Earnings',
              'Rs. ${fare.toStringAsFixed(2)}',
              isBold: true,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: BorderSide.none,
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
                color: isBold
                    ? const Color(0xFF059669)
                    : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter and Helpers ────────────────────────────────────────────────────

  List<DriverRideHistoryDto> _filterRides(List<DriverRideHistoryDto> rides) {
    if (_selectedFilter == 'ALL') return rides;
    if (_selectedFilter == 'COMPLETED') {
      return rides
          .where((r) => r.status?.toUpperCase() == 'COMPLETED')
          .toList();
    }
    if (_selectedFilter == 'CANCELLED') {
      return rides
          .where((r) => r.status?.toUpperCase().contains('CANCEL') == true)
          .toList();
    }
    if (_selectedFilter == 'ACTIVE') {
      return rides.where((r) {
        final s = r.status?.toUpperCase() ?? '';
        return s == 'IN_PROGRESS' ||
            s == 'DRIVER_ARRIVING' ||
            s == 'ACCEPTED' ||
            s == 'REQUESTED';
      }).toList();
    }
    return rides;
  }

  int _getFilterCount(List<DriverRideHistoryDto> rides, String filter) {
    if (filter == 'ALL') return rides.length;
    if (filter == 'COMPLETED') {
      return rides.where((r) => r.status?.toUpperCase() == 'COMPLETED').length;
    }
    if (filter == 'CANCELLED') {
      return rides
          .where((r) => r.status?.toUpperCase().contains('CANCEL') == true)
          .length;
    }
    if (filter == 'ACTIVE') {
      return rides.where((r) {
        final s = r.status?.toUpperCase() ?? '';
        return s == 'IN_PROGRESS' ||
            s == 'DRIVER_ARRIVING' ||
            s == 'ACCEPTED' ||
            s == 'REQUESTED';
      }).length;
    }
    return 0;
  }

  double _calculateTotalEarnings(List<DriverRideHistoryDto> rides) {
    return rides.fold<double>(0.0, (sum, ride) {
      final fare = ride.finalFare ?? ride.estimatedFare ?? 0.0;
      return sum + fare;
    });
  }

  String _formatTripId(String? id) {
    if (id == null || id.isEmpty) return 'TRIP #---';
    final trimmed = id.length > 10 ? id.substring(0, 8) : id;
    return 'TRIP #${trimmed.toUpperCase()}';
  }

  String _formatCreatedAt(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return 'Recent trip';
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      final month = _months[dt.month - 1];
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute.toString().padLeft(2, '0');
      return '$month ${dt.day}, ${dt.year} • $hour:$min $period';
    } catch (_) {
      return createdAt;
    }
  }

  // ── Shimmer, Error & Empty Views ──────────────────────────────────────────

  Widget _buildShimmerView() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Filter Tabs Skeleton
          Row(
            children: const [
              SkeletonLoader(width: 70, height: 34, borderRadius: 12),
              SizedBox(width: 8),
              SkeletonLoader(width: 90, height: 34, borderRadius: 12),
              SizedBox(width: 8),
              SkeletonLoader(width: 75, height: 34, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 14),

          // Summary Banner Skeleton
          Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                Expanded(child: SkeletonLoader(height: 36, borderRadius: 8)),
                SizedBox(width: 20),
                Expanded(child: SkeletonLoader(height: 36, borderRadius: 8)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Ride Cards Skeleton
          _buildCardSkeleton(),
          const SizedBox(height: 12),
          _buildCardSkeleton(),
          const SizedBox(height: 12),
          _buildCardSkeleton(),
        ],
      ),
    );
  }

  Widget _buildCardSkeleton() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonLoader(width: 120, height: 16, borderRadius: 4),
              SkeletonLoader(width: 70, height: 20, borderRadius: 8),
            ],
          ),
          const SkeletonLoader(height: 14, borderRadius: 4),
          const SkeletonLoader(height: 14, borderRadius: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonLoader(width: 90, height: 16, borderRadius: 4),
              SkeletonLoader(width: 60, height: 18, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFE11D48),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to Load Trips',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message.isNotEmpty
                    ? message
                    : 'Network connection failed. Please try again.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _refresh,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({bool hasRides = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_car_filled_rounded,
                size: 34,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              hasRides
                  ? 'No ${_selectedFilter.toLowerCase()} trips found'
                  : 'No trip history yet',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasRides
                  ? 'You currently have no rides matching the $_selectedFilter filter.'
                  : 'Trips you complete as a driver will appear here with detailed fare receipts.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            if (hasRides)
              OutlinedButton(
                onPressed: () {
                  setState(() => _selectedFilter = 'ALL');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Show All Trips',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: _refresh,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Refresh'),
              ),
          ],
        ),
      ),
    );
  }
}
