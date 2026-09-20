import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rider_app/src/modules/auth/blocs/login_cubit.dart';
import 'package:shared_core/shared_core.dart';

/// Clean, state-of-the-art ride-sharing login screen inspired by Uber & Lyft.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with FormMixin {
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;

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

  void _onLogin(BuildContext context) {
    hideKeyboard();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (!validateForm()) {
      return;
    }

    if (!context.mounted) return;
    context.read<LoginCubit>().login(phone: phone, password: password);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DismissFocusOverlay(
      child: DarkThemeAnnotatedRegion(
        child: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    // Ride share header icon badge
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_taxi_rounded,
                        color: AppColor.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Welcome to Rider',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Enter your phone number to continue',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColor.gray,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Phone / Email field
                    CustomTextField(
                      label: 'Phone',
                      hintText: '+977 9800000000',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.person_outline_rounded,
                        size: 20,
                      ),
                      validator: Validators.compose([
                        Validators.required(
                          message: 'Please enter your phone number',
                        ),
                        Validators.phone(
                          message: 'Please enter a valid phone number',
                        ),
                      ]),
                    ),
                    const SizedBox(height: 20),

                    // Password field
                    CustomTextField(
                      label: 'Password',
                      hintText: 'Enter your password',
                      controller: _passwordController,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        size: 20,
                      ),
                      validator: Validators.required(
                        message: 'Please enter your password',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          AppAlerts.info(
                            context,
                            'Password reset link sent to your contact info.',
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Submit Button
                    // BlocBuilder<AuthCubit, AuthState>(
                    //   builder: (context, state) {
                    //     final isLoading = state is AuthLoading;
                    //     return CustomButton(
                    //       text: 'Continue',
                    //       width: double.infinity,
                    //       height: 52,
                    //       borderRadius: 14,
                    //       backgroundColor: Colors.black,
                    //       textColor: Colors.white,
                    //       isLoading: isLoading,
                    //       onPressed: isLoading ? null : _onLoginPressed,
                    //     );
                    //   },
                    // ),
                    _loginButton(context),

                    const SizedBox(height: 24),

                    // Or divider
                    // Row(
                    //   children: [
                    //     const Expanded(
                    //       child: Divider(color: AppColor.borderGrey),
                    //     ),
                    //     Padding(
                    //       padding: const EdgeInsets.symmetric(horizontal: 14),
                    //       child: Text(
                    //         'or',
                    //         style: theme.textTheme.bodySmall?.copyWith(
                    //           color: AppColor.gray,
                    //           fontWeight: FontWeight.w500,
                    //         ),
                    //       ),
                    //     ),
                    //     const Expanded(
                    //       child: Divider(color: AppColor.borderGrey),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 24),

                    // Don't have an account
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColor.gray,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push(AppRoutes.signup),
                            child: Text(
                              'Sign up',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginButton(BuildContext context) =>
      BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) async {
          if (state is LoginLoading) {
            LoadingOverlay.show();
          } else {
            LoadingOverlay.hide();
          }
          if (state is LoginSuccess) {
            if (!context.mounted) return;
            AppAlerts.success(context, state.message);

            context.go(AppRoutes.home);
          } else if (state is LoginFailure) {
            AppAlerts.error(context, state.message);
          }
        },
        builder: (context, state) => CustomButton(
          text: 'Continue',
          width: double.infinity,
          height: 52,
          borderRadius: 14,
          backgroundColor: AppColor.black,
          textColor: AppColor.white,
          onPressed: () => _onLogin(context),
        ),
      );
}
