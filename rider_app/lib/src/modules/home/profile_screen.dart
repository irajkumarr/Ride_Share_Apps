import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rider_app/src/data/local/auth_local_data_source.dart';
import 'package:rider_app/src/data/remote/dto/user_dto.dart';
import 'package:rider_app/src/modules/auth/blocs/current_user_cubit.dart';
import 'package:shared_core/shared_core.dart';

/// Clean, state-of-the-art Rider Profile & Settings screen matching the reference design.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserDataDto? _rider;

  @override
  void initState() {
    super.initState();
    final currentState = context.read<CurrentUserCubit>().state;
    if (currentState is CurrentUserSuccess) {
      _rider = currentState.user;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrentUserCubit>().getCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CurrentUserCubit, CurrentUserState>(
      listener: (context, state) {
        if (state is CurrentUserSuccess) {
          setState(() {
            _rider = state.user;
          });
        } else if (state is CurrentUserFailure) {
          AppAlerts.error(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.chevron_left_rounded,
              size: 32,
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
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Profile & Settings',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                AppAlerts.info(
                  context,
                  'Edit profile details functionality coming soon.',
                );
              },
              icon: const Icon(
                Icons.edit_note_rounded,
                size: 26,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(width: 4),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: const Color(0xFFF3F4F6), height: 1),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with Verified Badge
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0F172A),
                            border: Border.all(
                              color: const Color(0xFFFFEDD5),
                              width: 3.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              size: 54,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.check_rounded,
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Rider Name & Tier Tag
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            _rider?.fullName ?? 'Rider Name',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Phone & ID
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _rider?.phone ?? '+977 9800000000',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '•',
                          style: TextStyle(
                            color: Color(0xFFD1D5DB),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ID: ${_formatUserId(_rider?.id)}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4B5563),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Metrics Card: Rider Rating, Completed Rides, Nest Coins
              _buildMetricsCard(),

              const SizedBox(height: 24),

              // 4 Quick Action Pills (My Rides, 24/7 Support, Addresses, Settings)
              _buildQuickActions(),

              const SizedBox(height: 28),

              // RELIABILITY & INFO SECTION
              _buildSectionHeader('RELIABILITY & INFO'),
              const SizedBox(height: 10),
              _buildCardGroup([
                _buildNavTile(
                  icon: Icons.info,
                  tileIconBgColor: const Color(0xFFF1F5F9),
                  tileIconColor: Colors.transparent,
                  title: 'About RideNest & Terms',
                  subtitle: 'Privacy policy, licenses & terms',
                  onTap: () {
                    AppAlerts.info(
                      context,
                      'RideNest v3.4.2 • Safe & affordable ride-sharing platform.',
                    );
                  },
                  isLast: true,
                ),
              ]),

              const SizedBox(height: 28),

              // Log Out Button
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7F7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFFE0E0),
                    width: 1.2,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      await UiUtils.showAnimatedDialog(
                        context: context,
                        child: LogoutAccountDialog(
                          onConfirm: () async {
                            await sl<AuthLocalDataSource>().clear();
                            if (context.mounted) {
                              context.go(AppRoutes.login);
                            }
                          },
                        ),
                      );
                    },
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            size: 20,
                            color: Color(0xFF111827),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // App Version Footer
              const Center(
                child: Text(
                  'RideNest • v1.0.0 (Build 2026)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _formatUserId(String? id) {
    if (id == null || id.isEmpty) return 'RN-4912';
    if (id.length <= 6) return 'RN-${id.toUpperCase()}';
    return 'RN-${id.substring(0, 4).toUpperCase()}';
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Color(0xFF94A3B8),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildMetricsCard() {
    final rating = (_rider?.rating != null && _rider!.rating! >= 0)
        ? _rider!.rating!.toStringAsFixed(2)
        : '4.98';
    final completedRides = _rider?.totalRides ?? 34;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rider Rating
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFF59E0B),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  'Rider Rating',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // Vertical Divider
          Container(width: 1, height: 48, color: const Color(0xFFF3F4F6)),

          // Completed Rides (Right)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$completedRides',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Rides',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionItem(
          icon: Icons.access_time_rounded,
          label: 'My Rides',
          onTap: () {
            context.push('/ride-history');
          },
        ),
        _buildActionItem(
          icon: Icons.headset_mic_outlined,
          label: '24/7 Support',
          onTap: () {
            AppAlerts.info(context, 'RideNest 24/7 Support help center.');
          },
        ),
        // _buildActionItem(
        //   icon: Icons.location_on_outlined,
        //   label: 'Addresses',
        //   onTap: () {
        //     AppAlerts.info(context, 'Manage home, work & saved places.');
        //   },
        // ),
        // _buildActionItem(
        //   icon: Icons.settings_outlined,
        //   label: 'Settings',
        //   onTap: () {
        //     AppAlerts.info(context, 'Account and app settings.');
        //   },
        // ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Icon(icon, size: 24, color: const Color(0xFF1E293B)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? tileIconColor,
    Color? tileIconBgColor,
    String? badgeText,
    Color? badgeColor,
    Color? badgeBgColor,
    Color? subtitleColor,
    FontWeight? subtitleWeight,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Column(
      children: [
        if (!isFirst)
          const Divider(
            height: 1,
            indent: 68,
            endIndent: 16,
            color: Color(0xFFF3F4F6),
          ),
        InkWell(
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(20) : Radius.zero,
            bottom: isLast ? const Radius.circular(20) : Radius.zero,
          ),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon Box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: tileIconBgColor ?? const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(icon, size: 22, color: const Color(0xFF1E293B)),
                  ),
                ),
                const SizedBox(width: 14),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          if (badgeText != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: badgeBgColor ?? const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                badgeText,
                                style: TextStyle(
                                  color: badgeColor ?? const Color(0xFF10B981),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: subtitleColor ?? const Color(0xFF6B7280),
                          fontWeight: subtitleWeight ?? FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
