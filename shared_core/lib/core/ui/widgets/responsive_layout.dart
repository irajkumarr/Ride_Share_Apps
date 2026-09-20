import 'package:flutter/material.dart';
import '../../utils/responsive_size.dart';

/// A widget that switches between different layouts based on screen size.
///
/// If [tablet] is not provided, it falls back to [mobile].
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isLargeTablet(context) && desktop != null) {
      return desktop!;
    }
    if (ResponsiveHelper.isTabletDevice(context) && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}

/*
// Usage Demonstration:
// --------------------
// ResponsiveLayout(
//   mobile: Column(
//     children: [Text('Mobile Version')],
//   ),
//   tablet: Row(
//     children: [Text('Sidebar'), Text('Main Content')],
//   ),
// )
*/
