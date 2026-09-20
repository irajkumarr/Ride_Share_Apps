import 'package:flutter/material.dart';

// ScrollConfiguration(
//   behavior: MyBehavior(), // applying custom scroll behavior
//   child: ListView.builder(
//     itemCount: 20,
//     itemBuilder: (context, index) {
//       return ListTile(title: Text('Item $index'));
//     },
//   ),
// );

// Custom ScrollBehavior to remove default scroll effects
class MyBehavior extends ScrollBehavior {
  // This method overrides the default scroll "chrome"
  // (like glow effect on Android, overscroll effect, etc.)
  Widget buildViewportChrome(
    BuildContext context,
    Widget child,
    AxisDirection axisDirection,
  ) {
    // Returning child directly means:
    // ❌ No glow effect
    // ❌ No overscroll indicator
    // ✅ Clean scrolling UI
    return child;
  }
}
