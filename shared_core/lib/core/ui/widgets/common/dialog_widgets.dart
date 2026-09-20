import 'package:flutter/material.dart';

/// Confirmation dialog helper
///
/// Usage:
/// ```dart
/// ConfirmationDialog.show(
///   context,
///   title: 'Delete Item',
///   message: 'Are you sure you want to delete this item?',
///   confirmText: 'Delete',
///   confirmColor: Colors.red,
///   onConfirm: () => print('Confirmed'),
/// );
/// ```
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final Color? confirmColor;
  final IconData? icon;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.confirmColor,
    this.icon,
    this.onConfirm,
    this.onCancel,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    Color? confirmColor,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (confirmColor ?? theme.colorScheme.primary).withOpacity(
                  0.1,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: confirmColor ?? theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            onCancel?.call();
            Navigator.of(context).pop(false);
          },
          child: Text(cancelText ?? 'Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm?.call();
            Navigator.of(context).pop(true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? theme.colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(confirmText ?? 'Confirm'),
        ),
      ],
    );
  }
}

/// Success dialog
///
/// Usage:
/// ```dart
/// SuccessDialog.show(
///   context,
///   title: 'Success!',
///   message: 'Your action was completed successfully.',
/// );
/// ```
class SuccessDialog extends StatelessWidget {
  final String title;
  final String? message;
  final String? buttonText;

  const SuccessDialog({
    super.key,
    required this.title,
    this.message,
    this.buttonText,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? message,
    String? buttonText,
  }) {
    return showDialog(
      context: context,
      builder: (context) => SuccessDialog(
        title: title,
        message: message,
        buttonText: buttonText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(buttonText ?? 'OK'),
          ),
        ),
      ],
    );
  }
}

/// Error dialog
///
/// Usage:
/// ```dart
/// ErrorDialog.show(
///   context,
///   title: 'Error',
///   message: 'Something went wrong. Please try again.',
/// );
/// ```
class ErrorDialog extends StatelessWidget {
  final String title;
  final String? message;
  final String? buttonText;

  const ErrorDialog({
    super.key,
    this.title = 'Error',
    this.message,
    this.buttonText,
  });

  static Future<void> show(
    BuildContext context, {
    String title = 'Error',
    String? message,
    String? buttonText,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        buttonText: buttonText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(buttonText ?? 'OK'),
          ),
        ),
      ],
    );
  }
}
