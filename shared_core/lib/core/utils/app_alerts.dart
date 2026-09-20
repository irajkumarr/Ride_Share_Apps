import 'package:flutter/material.dart';
import 'package:shared_core/core/ui/widgets/custom_sized_box.dart';
import 'package:shared_core/core/utils/ui_utils.dart';
import 'package:toastification/toastification.dart';

/// A standardized utility for showing project-wide alerts, toasts, and dialogs.
class AppAlerts {
  /// Shows a success toast notification.
  static void success(BuildContext context, String message) {
    UiUtils.showMessage(context, message, ToastificationType.success);
  }

  /// Shows an error toast notification.
  static void error(BuildContext context, String message) {
    UiUtils.showMessage(context, message, ToastificationType.error);
  }

  /// Shows an informational toast notification.
  static void info(BuildContext context, String message) {
    UiUtils.showMessage(context, message, ToastificationType.info);
  }

  /// Shows a warning toast notification.
  static void warning(BuildContext context, String message) {
    UiUtils.showMessage(context, message, ToastificationType.warning);
  }

  /// Shows a confirmation dialog.
  static Future<void> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String? confirmText,
    String? cancelText,
  }) async {
    await UiUtils.showAnimatedDialog(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const CustomSizedBox(height: 10),
            Text(message),
            const CustomSizedBox(height: 20),

            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     TextButton(
            //       onPressed: () => context.pop(),
            //       child: Text(cancelText ?? 'Cancel'),
            //     ),
            //     ElevatedButton(
            //       onPressed: () {
            //         context.pop();
            //         onConfirm();
            //       },
            //       child: Text(confirmText ?? 'Confirm'),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  /// Shows a loading dialog that cannot be dismissed by clicking outside.
  static Future<void> showLoading(BuildContext context, {String? message}) async {
    await showDialog<dynamic>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const CustomSizedBox(width: 20),
              Text(message ?? 'Loading...'),
            ],
          ),
        ),
      ),
    );
  }

  /// Hides any currently showing dialog.
  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}

/*
// Usage Demonstration:
// --------------------
// // Success toast
// AppAlerts.success(context, 'Profile updated successfully!');
//
// // Confirm action
// AppAlerts.showConfirm(
//   context: context,
//   title: 'Delete Order',
//   message: 'Are you sure you want to delete this order?',
//   onConfirm: () => _deleteOrder(),
// );
//
// // Loading indicator
// AppAlerts.showLoading(context, message: 'Processing payment...');
// // To hide: AppAlerts.hide(context);
*/
