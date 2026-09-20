import 'package:flutter/material.dart';

enum BadgeType { primary, success, warning, error, info }

/// A badge widget for displaying counts or status indicators
///
/// Usage:
/// ```dart
/// // Notification count badge
/// BadgeWidget(
///   count: 5,
///   child: Icon(Icons.notifications),
/// )
///
/// // Status badge
/// BadgeWidget.badge(
///   label: 'New',
///   type: BadgeType.success,
/// )
/// ```
class BadgeWidget extends StatelessWidget {
  final Widget? child;
  final int? count;
  final String? label;
  final BadgeType type;
  final double fontSize;
  final double size;
  final bool showIfZero;

  const BadgeWidget({
    super.key,
    this.child,
    this.count,
    this.label,
    this.type = BadgeType.primary,
    this.fontSize = 10,
    this.size = 18,
    this.showIfZero = false,
  }) : assert(child != null || label != null || count != null);

  const BadgeWidget.badge({
    super.key,
    required this.label,
    this.type = BadgeType.primary,
    this.fontSize = 12,
  }) : child = null,
       count = null,
       size = 0,
       showIfZero = false;

  const BadgeWidget.count({
    super.key,
    required this.count,
    this.type = BadgeType.error,
    this.fontSize = 10,
    this.size = 18,
    this.showIfZero = false,
  }) : child = null,
       label = null;

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return _buildLabelBadge();
    }

    if (count != null) {
      return _buildCountBadge();
    }

    return _buildIconBadge();
  }

  Widget _buildLabelBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label!,
        style: TextStyle(
          color: _getTextColor(),
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCountBadge() {
    final showBadge = showIfZero || (count ?? 0) > 0;
    if (!showBadge) return child ?? const SizedBox();

    final displayCount = count! > 99 ? '99+' : count.toString();
    final needsMinSize = count! > 9;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child ?? const SizedBox(),
        Positioned(
          right: -4,
          top: -4,
          child: Container(
            constraints: BoxConstraints(
              minWidth: needsMinSize ? size + 4 : size,
              minHeight: size,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.circular(size / 2),
            ),
            child: Center(
              child: Text(
                displayCount,
                style: TextStyle(
                  color: _getTextColor(),
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconBadge() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child ?? const SizedBox(),
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case BadgeType.primary:
        return Colors.blue;
      case BadgeType.success:
        return Colors.green;
      case BadgeType.warning:
        return Colors.orange;
      case BadgeType.error:
        return Colors.red;
      case BadgeType.info:
        return Colors.grey;
    }
  }

  Color _getTextColor() {
    return Colors.white;
  }
}

/// Status badge with dot indicator
///
/// Usage:
/// ```dart
/// StatusBadge(status: 'Online', color: Colors.green)
/// ```
class StatusBadge extends StatelessWidget {
  final String status;
  final Color? color;
  final double dotSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.color,
    this.dotSize = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: color ?? Colors.green,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          status,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
