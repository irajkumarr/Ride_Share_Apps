import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/core/utils/colors.dart';


/// /// update color for status bar icon to Light [Brightness.light]
class LightThemeAnnotatedRegion extends StatelessWidget {
  final Widget child;
  const LightThemeAnnotatedRegion({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: child,
    );
  }
}

/// update color for status bar icon to Dark [Brightness.dark]
class DarkThemeAnnotatedRegion extends StatelessWidget {
  final Widget child;
  const DarkThemeAnnotatedRegion({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    // return AnnotatedRegion<SystemUiOverlayStyle>(
    //   value: SystemUiOverlayStyle.dark,
    //   child: child,
    // );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        // Status bar (top)
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,

        // Bottom navigation bar (system)
        systemNavigationBarColor: AppColor.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: child,
    );
  }
}
