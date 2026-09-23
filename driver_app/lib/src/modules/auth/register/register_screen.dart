import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:driver_app/src/modules/auth/blocs/register_cubit.dart';
import 'package:shared_core/shared_core.dart';

/// Clean driver registration screen matching the RideNest Driver Pro design.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with FormMixin {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  bool _agreeToTerms = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }

  @override
  void initState() {
    _nameController = registerController();
    _emailController = registerController();
    _phoneController = registerController();
    _passwordController = registerController();
    super.initState();
  }

  void _onRegister(BuildContext context) {
    hideKeyboard();
    if (!_agreeToTerms) {
      AppAlerts.warning(
        context,
        'Please accept the Driver Terms & Conditions to continue',
      );
      return;
    }
    if (!validateForm()) {
      return;
    }

    if (!context.mounted) return;
    context.read<RegisterCubit>().register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DismissFocusOverlay(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar with Back icon and RideNest PRO Badge
              _buildTopBar(context),

              // Scrollable form body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),

                        // Title
                        const Text(
                          'Become a Driver Partner',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Subtitle
                        const Text(
                          'Sign up and take the first step towards driving',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Full Name
                        _buildFieldLabel('Full Name'),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _nameController,
                          hintText: 'e.g. Aarav Shrestha',
                          prefixIcon: Icons.badge_outlined,
                          textInputAction: TextInputAction.next,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Enter your full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Email Address
                        _buildFieldLabel('Email Address'),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _emailController,
                          hintText: 'e.g. driver@ridenest.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Enter your email address';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(val.trim())) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Phone Number
                        _buildFieldLabel('Phone Number'),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _phoneController,
                          hintText: 'e.g. +977 9800000000',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Enter your phone number';
                            }
                            if (val.trim().length < 8) {
                              return 'Enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password
                        _buildFieldLabel('Password'),
                        const SizedBox(height: 8),
                        _buildPasswordField(),

                        const SizedBox(height: 20),

                        // Terms & Conditions Row
                        _buildTermsRow(),

                        const SizedBox(height: 32),

                        // Continue to Vehicle Setup Button
                        _buildSubmitButton(context),

                        const SizedBox(height: 24),

                        // Already registered? Log in
                        _buildLoginPrompt(context),

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
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Arrow
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.chevron_left_rounded,
              size: 30,
              color: Color(0xFF111827),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

          // RideNest PRO Pill Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF3F4F6), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icons/ridenest_logo.png',
                  package: 'shared_core',
                  width: 18,
                  height: 18,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.local_taxi_rounded,
                    color: Color(0xFFFF3333),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 6),
                RichText(
                  text: const TextSpan(
                    text: 'Ride',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                    children: [
                      TextSpan(
                        text: 'Nest ',
                        style: TextStyle(
                          color: Color(0xFFFF3333),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3333),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111827),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF111827),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          prefixIcon: Icon(
            prefixIcon,
            size: 20,
            color: const Color(0xFF9CA3AF),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.done,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF111827),
        ),
        decoration: InputDecoration(
          hintText: 'At least 6 characters',
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 14,
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
            return 'Enter your password';
          }
          if (val.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTermsRow() {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        setState(() => _agreeToTerms = !_agreeToTerms);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _agreeToTerms ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _agreeToTerms ? Colors.black : const Color(0xFFD1D5DB),
                width: 1.5,
              ),
            ),
            child: _agreeToTerms
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'I accept the Driver Terms & Conditions and Safety Guidelines',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF374151),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: (context, state) async {
        if (state is RegisterLoading) {
          LoadingOverlay.show();
        } else {
          LoadingOverlay.hide();
        }
        if (state is RegisterSuccess) {
          if (!context.mounted) return;
          AppAlerts.success(context, 'Account created! Now add your vehicle.');
          // Navigate to vehicle setup with fromRegistration: true so back button is hidden!
          context.go('/vehicle-setup?fromRegistration=true');
        } else if (state is RegisterFailure) {
          AppAlerts.error(context, state.message);
        }
      },
      builder: (context, state) {
        return Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _onRegister(context),
              child: const Center(
                child: Text(
                  'Continue to Vehicle Setup',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Already registered? ',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w400,
            ),
          ),
          GestureDetector(
            onTap: () => context.pop(),
            child: const Text(
              'Log in',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
