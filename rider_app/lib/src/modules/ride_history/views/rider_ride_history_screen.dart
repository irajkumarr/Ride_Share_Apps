import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rider_app/src/data/remote/dto/rider_ride_history_dto.dart';
import 'package:rider_app/src/modules/ride_history/blocs/rider_ride_history_cubit.dart';
import 'package:shared_core/shared_core.dart';

/// Minimal, modern Ride History screen for the authenticated rider.
/// Accurately renders authoritative ride records without mock or fake data.
/// Handles loading (shimmer skeleton), error (retryable), empty, and success states.
class RiderRideHistoryScreen extends StatefulWidget {
  const RiderRideHistoryScreen({super.key});

  @override
  State<RiderRideHistoryScreen> createState() => _RiderRideHistoryScreenState();
}

class _RiderRideHistoryScreenState extends State<RiderRideHistoryScreen> {
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
      context.read<RiderRideHistoryCubit>().fetchRides();
    });
  }

  Future<void> _refresh() async {
    await context.read<RiderRideHistoryCubit>().fetchRides();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF0F172A),
          ),
          tooltip: 'Back',
        ),
        centerTitle: true,
        title: Column(
          children: const [
            Text(
              'RIDENEST RIDER',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'My Rides & Trips',
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
      body: BlocConsumer<RiderRideHistoryCubit, RiderRideHistoryState>(
        listener: (context, state) {
          if (state is RiderRideHistoryFailure) {
            AppAlerts.error(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is RiderRideHistoryLoading ||
              state is RiderRideHistoryInitial) {
            return _buildShimmerView();
          }

          if (state is RiderRideHistoryFailure) {
            return _buildErrorView(state.message);
          }

          if (state is RiderRideHistoryLoaded) {
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
                  // Filter Pills and Summary Row
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterTabs(allRides),
                          const SizedBox(height: 14),
                          _buildSummaryRow(allRides, filteredRides),
                        ],
                      ),
                    ),
                  ),

                  // Ride List or Empty View
                  if (filteredRides.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(hasAnyRides: allRides.isNotEmpty),
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

  // ── Filter Bar ────────────────────────────────────────────────────────────

  Widget _buildFilterTabs(List<RiderRideHistoryDto> allRides) {
    final filters = ['ALL', 'COMPLETED', 'ACTIVE', 'CANCELLED'];

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
              borderRadius: BorderRadius.circular(20),
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
                  color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
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
                        borderRadius: BorderRadius.circular(10),
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
          .where(
            (r) =>
                r.status != null && r.status!.toUpperCase().contains('CANCEL'),
          )
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
          .where(
            (r) =>
                r.status != null && r.status!.toUpperCase().contains('CANCEL'),
          )
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

  // ── Summary Row ───────────────────────────────────────────────────────────

  Widget _buildSummaryRow(
    List<RiderRideHistoryDto> allRides,
    List<RiderRideHistoryDto> filteredRides,
  ) {
    final totalSpent = _calculateTotalSpent(filteredRides);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${_selectedFilter.toUpperCase()} (${filteredRides.length})',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.6,
          ),
        ),
        if (totalSpent > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Total Spent: Rs. ${totalSpent.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF059669),
              ),
            ),
          ),
      ],
    );
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

  // ── Ride Card ─────────────────────────────────────────────────────────────

  String _formatTripId(String? id) {
    if (id == null || id.trim().isEmpty) return '---';
    final trimmed = id.trim();
    if (trimmed.length <= 10) return trimmed.toUpperCase();
    return trimmed.substring(0, 8).toUpperCase();
  }

  Widget _buildRideCard(RiderRideHistoryDto ride) {
    final statusConfig = _getStatusConfig(ride.status);
    final formattedDate = _formatDateTime(ride.createdAt);
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
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showTripDetailSheet(ride),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Trip ID, Date/Time, and Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.two_wheeler_rounded,
                            size: 16,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trip #$tripId',

                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusConfig.bgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusConfig.icon,
                            size: 12,
                            color: statusConfig.textColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusConfig.label,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: statusConfig.textColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                // Route: Pickup and Destination
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 3.0),
                      child: Column(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 1.5,
                            height: 28,
                            color: const Color(0xFFCBD5E1),
                          ),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.all(
                                Radius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride.pickupAddress?.trim().isNotEmpty == true
                                ? ride.pickupAddress!.trim()
                                : 'Pickup Location',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            ride.dropoffAddress?.trim().isNotEmpty == true
                                ? ride.dropoffAddress!.trim()
                                : 'Dropoff Location',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                // Bottom Row: Driver Info & Fare
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildDriverInfo(ride)),
                    const SizedBox(width: 8),
                    _buildFareDisplay(ride),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDriverInfo(RiderRideHistoryDto ride) {
    final driverName = ride.driverName?.trim();
    final hasDriver = driverName != null && driverName.isNotEmpty;
    final isRequested = ride.status?.toUpperCase() == 'REQUESTED';

    final text = hasDriver
        ? driverName
        : (isRequested ? 'Searching for Driver' : 'Driver Unassigned');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: hasDriver
                ? const Color(0xFF0F172A)
                : const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: hasDriver
                ? Text(
                    driverName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.person_outline_rounded,
                    size: 13,
                    color: Color(0xFF94A3B8),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ),
        if (ride.licensePlate != null &&
            ride.licensePlate!.trim().isNotEmpty) ...[
          const SizedBox(width: 6),
          Text(
            '• ${ride.licensePlate!.trim()}',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFareDisplay(RiderRideHistoryDto ride) {
    final isCancelled = ride.status?.toUpperCase().contains('CANCEL') ?? false;
    final isCompleted = ride.status?.toUpperCase() == 'COMPLETED';

    if (ride.finalFare != null && ride.finalFare! > 0) {
      return Text(
        'Rs. ${ride.finalFare!.toStringAsFixed(0)}',
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A),
          letterSpacing: -0.3,
        ),
      );
    } else if (ride.estimatedFare != null && ride.estimatedFare! > 0) {
      return Text(
        isCompleted
            ? 'Rs. ${ride.estimatedFare!.toStringAsFixed(0)}'
            : 'Est. Rs. ${ride.estimatedFare!.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: isCancelled
              ? const Color(0xFF94A3B8)
              : const Color(0xFF0F172A),
          letterSpacing: -0.3,
        ),
      );
    } else if (isCancelled) {
      return const Text(
        'No Charge',
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8),
        ),
      );
    }
    return const Text(
      '—',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF94A3B8),
      ),
    );
  }

  // ── Trip Details Modal Bottom Sheet ───────────────────────────────────────

  void _showTripDetailSheet(RiderRideHistoryDto ride) {
    final statusConfig = _getStatusConfig(ride.status);
    final formattedDate = _formatDateTime(ride.createdAt);
    final tripId = ride.id ?? '---';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),

              // Title and Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Trip Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusConfig.bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusConfig.icon,
                          size: 13,
                          color: statusConfig.textColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusConfig.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: statusConfig.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 18),

              // Trip ID Row with Copy
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Trip ID: ${tripId.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: tripId));
                        AppAlerts.success(context, 'Trip ID copied');
                      },
                      child: const Row(
                        children: [
                          Icon(
                            Icons.copy_rounded,
                            size: 14,
                            color: Color(0xFF2563EB),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Copy',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Route Details
              const Text(
                'ROUTE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              _buildDetailLocationRow(
                iconColor: const Color(0xFF10B981),
                title: 'Pickup Location',
                address: ride.pickupAddress?.trim().isNotEmpty == true
                    ? ride.pickupAddress!.trim()
                    : 'Not specified',
              ),
              const SizedBox(height: 12),
              _buildDetailLocationRow(
                iconColor: const Color(0xFFEF4444),
                title: 'Destination',
                address: ride.dropoffAddress?.trim().isNotEmpty == true
                    ? ride.dropoffAddress!.trim()
                    : 'Not specified',
              ),

              const SizedBox(height: 18),

              // Driver & Vehicle Section
              const Text(
                'DRIVER & VEHICLE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              _buildDriverDetailCard(ride),

              const SizedBox(height: 18),

              // Fare Summary
              const Text(
                'FARE SUMMARY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              _buildFareSummaryCard(ride),

              const SizedBox(height: 22),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailLocationRow({
    required Color iconColor,
    required String title,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDriverDetailCard(RiderRideHistoryDto ride) {
    final driverName = ride.driverName?.trim();
    final hasDriver = driverName != null && driverName.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: hasDriver
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFE2E8F0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: hasDriver
                  ? Text(
                      driverName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.person_outline_rounded,
                      size: 22,
                      color: Color(0xFF64748B),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasDriver ? driverName : 'Driver Unassigned',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                        if (ride.vehicleMakeModel?.trim().isNotEmpty == true)
                          ride.vehicleMakeModel!.trim(),
                        if (ride.licensePlate?.trim().isNotEmpty == true)
                          ride.licensePlate!.trim(),
                      ].isNotEmpty
                      ? [
                          if (ride.vehicleMakeModel?.trim().isNotEmpty == true)
                            ride.vehicleMakeModel!.trim(),
                          if (ride.licensePlate?.trim().isNotEmpty == true)
                            ride.licensePlate!.trim(),
                        ].join(' • ')
                      : 'Vehicle information not recorded',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFareSummaryCard(RiderRideHistoryDto ride) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        children: [
          if (ride.estimatedFare != null && ride.estimatedFare! > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Estimated Fare',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                Text(
                  'Rs. ${ride.estimatedFare!.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          if (ride.finalFare != null && ride.finalFare! > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Final Total Fare',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Rs. ${ride.finalFare!.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ] else if (ride.estimatedFare == null && ride.finalFare == null)
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Fare',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                Text(
                  'No charge recorded',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'Date unknown';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final month = _months[dt.month - 1];
      final day = dt.day.toString();
      final year = dt.year.toString();
      final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '$day $month $year • $hour12:$minute $period';
    } catch (_) {
      return isoString;
    }
  }

  _StatusConfig _getStatusConfig(String? rawStatus) {
    final status = rawStatus?.toUpperCase() ?? 'REQUESTED';
    if (status == 'COMPLETED') {
      return const _StatusConfig(
        label: 'COMPLETED',
        textColor: Color(0xFF059669),
        bgColor: Color(0xFFECFDF5),
        icon: Icons.check_circle_rounded,
      );
    }
    if (status.contains('CANCEL')) {
      return const _StatusConfig(
        label: 'CANCELLED',
        textColor: Color(0xFFDC2626),
        bgColor: Color(0xFFFEF2F2),
        icon: Icons.cancel_rounded,
      );
    }
    if (status == 'IN_PROGRESS' ||
        status == 'ARRIVED' ||
        status == 'ACCEPTED') {
      return _StatusConfig(
        label: status.replaceAll('_', ' '),
        textColor: const Color(0xFF2563EB),
        bgColor: const Color(0xFFEFF6FF),
        icon: Icons.near_me_rounded,
      );
    }
    return _StatusConfig(
      label: status.replaceAll('_', ' '),
      textColor: const Color(0xFFD97706),
      bgColor: const Color(0xFFFFFBEB),
      icon: Icons.schedule_rounded,
    );
  }

  // ── Error State ───────────────────────────────────────────────────────────

  Widget _buildErrorView(String message) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: const Color(0xFF0F172A),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Container(
          padding: const EdgeInsets.all(28),
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 36,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Unable to Load Rides',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message.isNotEmpty ? message : 'We could not load your trip history. Please check your network connection and try again.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(
                  'Try Again',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
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

  // ── Empty State ───────────────────────────────────────────────────────────

  Widget _buildEmptyState({required bool hasAnyRides}) {
    final isFiltered = _selectedFilter != 'ALL';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.directions_car_filled_outlined,
                size: 36,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isFiltered
                  ? 'No ${_selectedFilter.toLowerCase()} rides'
                  : 'No Rides Yet',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'You don\'t have any rides under the "$_selectedFilter" category.'
                  : 'You haven\'t taken any rides yet. Book your first journey to get started!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            if (isFiltered)
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedFilter = 'ALL';
                  });
                },
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: const Text(
                  'Show All Rides',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F172A),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.home),
                icon: const Icon(Icons.near_me_rounded, size: 18),
                label: const Text(
                  'Book a Ride',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
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

  // ── Shimmer Loading View ──────────────────────────────────────────────────

  Widget _buildShimmerView() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter tabs shimmer
          Row(
            children: List.generate(4, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SkeletonLoader(width: 76, height: 34, borderRadius: 20),
              );
            }),
          ),

          const SizedBox(height: 16),

          // Summary row shimmer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoader(width: 90, height: 14, borderRadius: 4),
              SkeletonLoader(width: 110, height: 18, borderRadius: 6),
            ],
          ),

          const SizedBox(height: 16),

          // Ride cards shimmer
          ...List.generate(3, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SkeletonLoader(
                            width: 28,
                            height: 28,
                            borderRadius: 8,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonLoader(
                                width: 90,
                                height: 14,
                                borderRadius: 4,
                              ),
                              const SizedBox(height: 4),
                              SkeletonLoader(
                                width: 120,
                                height: 10,
                                borderRadius: 4,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SkeletonLoader(width: 70, height: 22, borderRadius: 8),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Column(
                        children: [
                          SkeletonLoader(width: 8, height: 8, borderRadius: 4),
                          Container(
                            width: 2,
                            height: 24,
                            color: const Color(0xFFE2E8F0),
                          ),
                          SkeletonLoader(width: 8, height: 8, borderRadius: 2),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonLoader(
                              width: 180,
                              height: 14,
                              borderRadius: 4,
                            ),
                            const SizedBox(height: 16),
                            SkeletonLoader(
                              width: 150,
                              height: 14,
                              borderRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SkeletonLoader.circle(size: 24),
                          const SizedBox(width: 8),
                          SkeletonLoader(
                            width: 100,
                            height: 14,
                            borderRadius: 4,
                          ),
                        ],
                      ),
                      SkeletonLoader(width: 60, height: 16, borderRadius: 4),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StatusConfig {
  final String label;
  final Color textColor;
  final Color bgColor;
  final IconData icon;

  const _StatusConfig({
    required this.label,
    required this.textColor,
    required this.bgColor,
    required this.icon,
  });
}
