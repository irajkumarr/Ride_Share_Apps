import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:driver_app/src/modules/auth/blocs/login_cubit.dart';
import 'package:driver_app/src/data/repo/vehicle_repo.dart';
import 'package:shared_core/shared_core.dart';

/// Clean, state-of-the-art Driver Partner Portal login screen matching the reference design.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with FormMixin {
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;

  final String _countryCode = '+977';
  final String _countryFlag = 'assets/images/flags/npl.png';
  bool _obscurePassword = true;
  bool _rememberVehicle = true;

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _phoneController = registerController();
    _passwordController = registerController();
  }

  void _onLogin(BuildContext context) async {
    hideKeyboard();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (!validateForm()) {
      return;
    }

    final String fcmToken =
        await sl<PushNotificationService>().getToken() ?? '';

    if (!context.mounted) return;
    context.read<LoginCubit>().login(
      phone: phone,
      password: password,
      fcmToken: fcmToken,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DismissFocusOverlay(
      child: DarkThemeAnnotatedRegion(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.8, -0.9),
                radius: 1.2,
                colors: [
                  const Color(0xFFFF5252).withValues(alpha: 0.08),
                  Colors.white,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 12),
                            // Top bar: Language toggle and Partner Help
                            _buildTopBar(context),

                            const SizedBox(height: 28),

                            // Brand Logo Card with soft shadow & border
                            _buildBrandLogoCard(),

                            const SizedBox(height: 20),

                            // RideNest + DRIVER PRO Pill
                            _buildBrandTitle(),

                            const SizedBox(height: 14),

                            // Driver Partner Portal heading
                            const Text(
                              'Driver Partner Portal',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Subtitle description
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Sign in to accept rides, track your daily earnings, and hit the road.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.45,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Registered Mobile Number Section
                            _buildSectionLabel('REGISTERED MOBILE NUMBER'),
                            const SizedBox(height: 8),
                            _buildPhoneInput(),

                            const SizedBox(height: 20),

                            // Portal Password Section
                            _buildSectionLabel('PORTAL PASSWORD'),
                            const SizedBox(height: 8),
                            _buildPasswordInput(),

                            const SizedBox(height: 16),

                            // Remember vehicle checkbox & Forgot Password
                            _buildOptionsRow(context),

                            const SizedBox(height: 24),

                            // Continue to Portal Button
                            _buildSubmitButton(context),

                            const SizedBox(height: 28),

                            // Want to drive with us? Sign Up as Partner
                            _buildSignUpPrompt(context),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Partner Help button
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            AppAlerts.info(
              context,
              'Connecting you to RideNest 24/7 Driver Support Desk...',
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.headset_mic_outlined,
                  size: 18,
                  color: Color(0xFFFF4D4F),
                ),
                SizedBox(width: 6),
                Text(
                  'Partner Help',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandLogoCard() {
    return Container(
      width: 106,
      height: 106,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFFFF4D4F).withValues(alpha: 0.04),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          'assets/icons/ridenest_logo_pro.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/icons/ridenest_logo.png',
            package: 'shared_core',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.local_taxi_rounded,
              color: Color(0xFFFF4D4F),
              size: 48,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'RideNest',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111827),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF5252), Color(0xFFFF3333)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF3333).withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Text(
            'DRIVER PRO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xFF374151),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD1D5DB), width: 1.2),
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
          // Country Calling Code Picker Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Image.asset(
                    _countryFlag,
                    package: 'shared_core',
                    width: 22,
                    height: 16,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Text('🇳🇵'),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _countryCode,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),

          // Phone Number Field
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
              decoration: const InputDecoration(
                hintText: '9800000000',
                hintStyle: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                suffixIcon: Icon(
                  Icons.smartphone_rounded,
                  size: 20,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter phone number';
                }
                if (val.trim().length < 7) {
                  return 'Enter a valid phone number';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD1D5DB), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.done,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
        ),
        decoration: InputDecoration(
          hintText: 'Enter your secret password',
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            size: 20,
            color: Color(0xFF9CA3AF),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: const Color(0xFF9CA3AF),
            ),
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          ),
        ),
        validator: (val) {
          if (val == null || val.isEmpty) {
            return 'Please enter your password';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildOptionsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember vehicle checkbox
        InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () {
            setState(() => _rememberVehicle = !_rememberVehicle);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _rememberVehicle
                      ? const Color(0xFFFF3333)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _rememberVehicle
                        ? const Color(0xFFFF3333)
                        : const Color(0xFFD1D5DB),
                    width: 1.5,
                  ),
                ),
                child: _rememberVehicle
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              const Text(
                'Remember vehicle',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),

        // Forgot password
        TextButton(
          onPressed: () {
            AppAlerts.info(
              context,
              'Please contact RideNest partner support or administrator to reset your portal password.',
            );
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
          child: const Text(
            'Forgot Password?',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFF3333),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) async {
        if (state is LoginLoading) {
          LoadingOverlay.show();
        } else {
          LoadingOverlay.hide();
        }
        if (state is LoginSuccess) {
          if (!context.mounted) return;
          AppAlerts.success(context, state.message);

          try {
            final vehicles = await sl<VehicleRepo>().getMyVehicles();
            if (vehicles.isEmpty && context.mounted) {
              context.go('/vehicle-setup');
              return;
            }
          } catch (_) {}

          if (context.mounted) {
            context.go(AppRoutes.home);
          }
        } else if (state is LoginFailure) {
          AppAlerts.error(context, state.message);
        }
      },
      builder: (context, state) {
        return Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF111827).withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _onLogin(context),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Continue to Portal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 19,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignUpPrompt(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Want to drive with us? ',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w400,
          ),
        ),
        GestureDetector(
          onTap: () => context.push(AppRoutes.signup),
          child: const Text(
            'Sign Up as Partner',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFFFF3333),
            ),
          ),
        ),
      ],
    );
  }
}
