import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A generic shimmer loading widget that matches the shape and size of a child.
/// Useful for creating skeleton layouts.
class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.isCircle = false,
  });

  final double width;
  final double height;
  final double borderRadius;
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        ),
      ),
    );
  }
}

/// A ready-to-use ListView of shimmers for common list loading states.
class ShimmerListLoader extends StatelessWidget {
  const ShimmerListLoader({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.hasLeadingCircle = true,
  });

  final int itemCount;
  final double itemHeight;
  final bool hasLeadingCircle;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasLeadingCircle) ...[
                const ShimmerLoader(
                  width: 50,
                  height: 50,
                  isCircle: true,
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoader(
                      width: double.infinity,
                      height: itemHeight * 0.25,
                      borderRadius: 4,
                    ),
                    const SizedBox(height: 8),
                    ShimmerLoader(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: itemHeight * 0.2,
                      borderRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
