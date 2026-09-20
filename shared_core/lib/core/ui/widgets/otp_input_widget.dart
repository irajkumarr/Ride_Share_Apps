import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_core/core/utils/colors.dart';
import 'package:shared_core/core/utils/ui_utils.dart';

/// A reusable, highly customizable OTP/PIN input widget using the pinput package.
class OtpInputWidget extends StatelessWidget {
  const OtpInputWidget({
    super.key,
    required this.onCompleted,
    this.length = 4,
    this.validator,
    this.errorText,
    this.onChanged,
    this.focusNode,
    this.controller,
  });

  final int length;
  final String? Function(String?)? validator;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String> onCompleted;
  final FocusNode? focusNode;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: theme.textTheme.headlineMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: AppColor.secondary, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: colorScheme.primaryContainer.withValues(alpha: 0.2),
        border: Border.all(color: colorScheme.primaryContainer),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: colorScheme.error, width: 2),
      ),
    );

    return Pinput(
      length: length,
      controller: controller,
      focusNode: focusNode,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      errorPinTheme: errorPinTheme,
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      showCursor: true,
      onCompleted: onCompleted,
      onChanged: onChanged,
      validator: validator,
      forceErrorState: errorText != null,
      errorText: errorText,
      errorTextStyle: theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.error,
      ),
    );
  }
}
