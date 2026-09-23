import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rider_app/src/modules/auth/blocs/register_cubit.dart';
import 'package:shared_core/shared_core.dart';

/// Clean, state-of-the-art rider registration screen matching the reference design:
/// - Top bar: Back chevron on the left, pill capsule "[Logo] RideNest" on the right
/// - "Create your account" bold headline + "Join millions of riders around the city"
/// - Four input fields: Full Name, Email Address, Phone Number, Password (with eye toggle)
/// - Checkbox with underlined "Terms of Service" and "Privacy Policy"
/// - Solid dark navy/black rounded "Continue" button
/// - Bottom prompt: "Already have an account? Log in"
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
        'Please agree to the Terms of Service and Privacy Policy to continue',
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
      child: DarkThemeAnnotatedRegion(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar: Back Button + RideNest Pill Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRoutes.login);
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            child: Icon(
                              Icons.chevron_left_rounded,
                              size: 32,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),

                        // Pill Badge: [Logo] RideNest
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7F5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFFECEB),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/icons/ridenest_logo.png',
                                width: 18,
                                height: 18,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  'assets/icons/ridenest_logo.png',
                                  package: 'shared_core',
                                  width: 18,
                                  height: 18,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.location_on_rounded,
                                    size: 16,
                                    color: Color(0xFFFF3B30),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'RideNest',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Title & Subtitle
                    const Text(
                      'Create your account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Join millions of riders around the city',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF64748B),
                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Full Name
                    _buildField(
                      label: 'Full Name',
                      hintText: 'e.g. Jane Doe',
                      controller: _nameController,
                      prefixIcon: Icons.badge_outlined,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      validator: Validators.required(message: 'Enter your full name'),
                    ),

                    const SizedBox(height: 18),

                    // Email Address
                    _buildField(
                      label: 'Email Address',
                      hintText: 'e.g. jane@example.com',
                      controller: _emailController,
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.compose([
                        Validators.required(message: 'Enter your email'),
                        Validators.email(message: 'Enter a valid email address'),
                      ]),
                    ),

                    const SizedBox(height: 18),

                    // Phone Number
                    _buildField(
                      label: 'Phone Number',
                      hintText: 'e.g. 555 123 4567',
                      controller: _phoneController,
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: Validators.compose([
                        Validators.required(message: 'Enter your phone number'),
                        Validators.phone(message: 'Enter a valid phone number'),
                      ]),
                    ),

                    const SizedBox(height: 18),

                    // Password
                    _buildField(
                      label: 'Password',
                      hintText: 'At least 6 characters',
                      controller: _passwordController,
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: const Color(0xFF94A3B8),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: Validators.minLength(
                        6,
                        message: 'Password must be at least 6 characters',
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Terms & conditions checkbox with custom style
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _agreeToTerms = !_agreeToTerms;
                              });
                            },
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: _agreeToTerms ? const Color(0xFF0F172A) : Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _agreeToTerms ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
                                  width: 1.5,
                                ),
                              ),
                              child: _agreeToTerms
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 13.5,
                                color: Color(0xFF1E293B),
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Submit Button
                    _buildContinueButton(context),

                    const SizedBox(height: 36),

                    // Already have account prompt
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(AppRoutes.login);
                              }
                            },
                            child: const Text(
                              'Log in',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFCBD5E1),
              width: 1.2,
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            obscureText: obscureText,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFF94A3B8),
              ),
              prefixIcon: Icon(
                prefixIcon,
                size: 20,
                color: const Color(0xFF94A3B8),
              ),
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              isDense: true,
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: (context, state) async {
        if (state is RegisterLoading) {
          LoadingOverlay.show();
        } else {
          LoadingOverlay.hide();
        }
        if (state is RegisterSuccess) {
          if (!context.mounted) return;
          AppAlerts.success(context, state.message);
          context.go(AppRoutes.home);
        } else if (state is RegisterFailure) {
          AppAlerts.error(context, state.message);
        }
      },
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => _onRegister(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.1,
              ),
            ),
          ),
        );
      },
    );
  }
}

