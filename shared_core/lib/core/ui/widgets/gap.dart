import 'package:flutter/material.dart';
import '../../utils/responsive_size.dart';

/// A widget that provides unified spacing in both [Row] and [Column].
///
/// Instead of using `SizedBox(height: 10)` or `SizedBox(width: 10)`,
/// you can simply use `Gap(10)`.
class Gap extends StatelessWidget {
  /// The amount of space to provide.
  final double size;

  /// Whether to use responsive scaling (rh/rw).
  /// Defaults to true.
  final bool isResponsive;

  const Gap(this.size, {super.key, this.isResponsive = true});

  @override
  Widget build(BuildContext context) {
    final dimension = isResponsive ? size.rh(context) : size;
    return SizedBox(
      width: dimension,
      height: dimension,
    );
  }
}

/*
// Usage Demonstration:
// --------------------
// Column(
//   children: [
//     Text('Upper Item'),
//     Gap(16), // Adds 16px responsive vertical space
//     Text('Lower Item'),
//   ],
// )
//
// Row(
//   children: [
//     Text('Left Item'),
//     Gap(8), // Adds 8px responsive horizontal space
//     Text('Right Item'),
//   ],
// )
*/
