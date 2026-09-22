import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rider_app/src/modules/auth/blocs/register_cubit.dart';
import 'package:shared_core/shared_core.dart';

/// Clean, state-of-the-art rider registration screen.
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
        'Please agree to terms & conditions to continue',
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
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create your account',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Join millions of riders around the city',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColor.gray,
                  ),
                ),
                const SizedBox(height: 32),

                // Full Name
                CustomTextField(
                  label: 'Full Name',
                  hintText: 'e.g. Jane Doe',
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                  validator: Validators.required(
                    message: 'Enter your full name',
                  ),
                ),
                const SizedBox(height: 18),

                // Email
                CustomTextField(
                  label: 'Email Address',
                  hintText: 'e.g. jane@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: Validators.compose([
                    Validators.required(message: 'Enter your email'),
                    Validators.email(message: 'Enter a valid email address'),
                  ]),
                ),
                const SizedBox(height: 18),

                // Phone Number
                CustomTextField(
                  label: 'Phone Number',
                  hintText: 'e.g. 555 123 4567',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  validator: Validators.compose([
                    Validators.required(message: 'Enter your phone number'),
                    Validators.phone(message: 'Enter a valid phone number'),
                  ]),
                ),
                const SizedBox(height: 18),

                // Password
                CustomTextField(
                  label: 'Password',
                  hintText: 'At least 6 characters',
                  controller: _passwordController,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  validator: Validators.minLength(
                    6,
                    message: 'Password must be at least 6 characters',
                  ),
                ),
                const SizedBox(height: 20),

                // Terms & conditions checkbox
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _agreeToTerms,
                        activeColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (val) =>
                            setState(() => _agreeToTerms = val ?? false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'I agree to the Terms of Service and Privacy Policy',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColor.gray,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Submit Button
                _registerButton(context),
                const SizedBox(height: 24),

                // Already have account
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColor.gray,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          'Log in',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
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
    );
  }

  Widget _registerButton(BuildContext context) =>
      BlocConsumer<RegisterCubit, RegisterState>(
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
        builder: (context, state) => CustomButton(
          text: 'Continue',
          width: double.infinity,
          height: 52,
          borderRadius: 14,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          onPressed: () => _onRegister(context),
        ),
      );
}
