

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// A widget that requires the user to press the back button twice within a specified
/// duration (default 2 seconds) to exit the application or pop the current route.
///
/// This is typically used at the root level of the application to prevent
/// accidental exits.
///
/// Example Usage:
/// ```dart
/// DoubleBackToCloseWrapper(
///   child: Scaffold(
///     body: Center(child: Text('Home Screen')),
///   ),
/// )
/// ```
class DoubleBackToCloseWrapper extends StatefulWidget {
  const DoubleBackToCloseWrapper({
    super.key,
    required this.child,
    this.message = 'Please tap again to exit',
    this.duration = const Duration(seconds: 2),
    this.enabled = true,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// The message to show in the toast on the first back press.
  final String message;

  /// The maximum duration between two back presses to trigger the exit.
  final Duration duration;

  /// Whether the double back to close functionality is enabled.
  final bool enabled;

  @override
  State<DoubleBackToCloseWrapper> createState() => _DoubleBackToCloseWrapperState();
}

class _DoubleBackToCloseWrapperState extends State<DoubleBackToCloseWrapper> {
  DateTime? _lastPressed;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.enabled,
      onPopInvokedWithResult: widget.enabled
          ? (didPop, result) async {
              if (didPop) return;

              final now = DateTime.now();
              final isDoubleTap =
                  _lastPressed != null && now.difference(_lastPressed!) <= widget.duration;

              if (isDoubleTap) {
                // If it's a double tap, allow popping (exit app)
                if (context.mounted) {
                  // Using SystemNavigator.pop() to exit the app gracefully on Android
                  await SystemNavigator.pop();
                }
              } else {
                // First tap: update time and show toast
                _lastPressed = now;

                Fluttertoast.showToast(
                  msg: widget.message,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black87,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              }
            }
          : null,
      child: widget.child,
    );
  }
}

/*
  DEMONSTRATION OF USE:
  
  In your App widget (lib/app.dart) or any root screen (e.g., HomeScreen):

  @override
  Widget build(BuildContext context) {
    return DoubleBackToCloseWrapper(
      child: Scaffold(
        appBar: AppBar(title: Text("My App")),
        body: Center(child: Text("Press back twice to exit")),
      ),
    );
  }

  Alternatively, you can apply it globally in the 'builder' of MaterialApp:
  
  MaterialApp(
    ...
    builder: (context, child) {
      return DoubleBackToCloseWrapper(child: child!);
    },
  )
*/
