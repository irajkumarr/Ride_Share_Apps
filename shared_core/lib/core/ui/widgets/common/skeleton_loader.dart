import 'package:flutter/material.dart';
import 'package:shared_core/core/ui/widgets/custom_sized_box.dart';


/// Skeleton loading placeholder with shimmer animation
///
/// Usage:
/// ```dart
/// // Card skeleton
/// SkeletonLoader(
///   width: double.infinity,
///   height: 100,
///   borderRadius: 8,
/// )
///
/// // Circle skeleton (for avatars)
/// SkeletonLoader.circle(size: 48)
///
/// // Text skeleton (multi-line)
/// SkeletonLoader.text(lines: 3)
/// ```
class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final bool isCircle;
  final int? lines;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 4,
    this.baseColor,
    this.highlightColor,
    this.isCircle = false,
    this.lines,
  });

  const SkeletonLoader.circle({
    super.key,
    required double size,
    this.baseColor,
    this.highlightColor,
  }) : width = size,
       height = size,
       borderRadius = size / 2,
       isCircle = true,
       lines = null;

  const SkeletonLoader.text({
    super.key,
    this.lines = 1,
    this.baseColor,
    this.highlightColor,
  }) : width = null,
       height = 16,
       borderRadius = 4,
       isCircle = false;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? Colors.grey.shade300;
    final highlightColor = widget.highlightColor ?? Colors.grey.shade100;

    if (widget.lines != null && widget.lines! > 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(widget.lines!, (index) {
          final isLast = index == widget.lines! - 1;
          final widthFactor = isLast ? 0.6 : 1.0;
          return Padding(
            padding: EdgeInsets.only(bottom: index < widget.lines! - 1 ? 8 : 0),
            child: _buildShimmerBox(
              baseColor,
              highlightColor,
              widthFactor,
            ),
          );
        }),
      );
    }

    return _buildShimmerBox(baseColor, highlightColor, 1.0);
  }

  Widget _buildShimmerBox(
    Color baseColor,
    Color highlightColor,
    double widthFactor,
  ) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width != null ? widget.width! * widthFactor : double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.isCircle ? null : BorderRadius.circular(widget.borderRadius),
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [baseColor, highlightColor, baseColor],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton list item for loading states
///
/// Usage:
/// ```dart
/// SkeletonListItem(
///   avatar: true,
///   titleLines: 2,
///   subtitleLines: 1,
/// )
/// ```
class SkeletonListItem extends StatelessWidget {
  final bool avatar;
  final int titleLines;
  final int subtitleLines;
  final double avatarSize;
  final double spacing;

  const SkeletonListItem({
    super.key,
    this.avatar = false,
    this.titleLines = 1,
    this.subtitleLines = 1,
    this.avatarSize = 48,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (avatar) ...[
            const SkeletonLoader.circle(size: 48),
            CustomSizedBox(width: spacing),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader.text(lines: titleLines),
                if (subtitleLines > 0) ...[
                  const CustomSizedBox(height: 8),
                  SkeletonLoader.text(lines: subtitleLines),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton card for loading card content
///
/// Usage:
/// ```dart
/// SkeletonCard(
///   imageHeight: 120,
///   hasFooter: true,
/// )
/// ```
class SkeletonCard extends StatelessWidget {
  final double? imageHeight;
  final bool hasFooter;
  final double borderRadius;

  const SkeletonCard({
    super.key,
    this.imageHeight,
    this.hasFooter = false,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageHeight != null)
            SkeletonLoader(
              width: double.infinity,
              height: imageHeight,
              borderRadius: borderRadius,
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader.text(lines: 2),
                const CustomSizedBox(height: 8),
                const SkeletonLoader(
                  width: 100,
                  height: 12,
                  borderRadius: 4,
                ),
                if (hasFooter) ...[
                  const CustomSizedBox(height: 12),
                  const Divider(),
                  const CustomSizedBox(height: 8),
                  const Row(
                    children: [
                      const SkeletonLoader.circle(size: 24),
                      const CustomSizedBox(width: 8),
                      SkeletonLoader(
                        width: 60,
                        height: 12,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
