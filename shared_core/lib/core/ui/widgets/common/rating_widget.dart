import 'package:flutter/material.dart';

/// A star rating widget for displaying and selecting ratings
///
/// Usage:
/// ```dart
/// // Display only (read-only)
/// RatingWidget(
///   rating: 4.5,
///   size: 24,
///   onRatingChanged: null,
/// )
///
/// // Interactive (selectable)
/// RatingWidget(
///   rating: 3.0,
///   size: 32,
///   onRatingChanged: (rating) => print('Selected: $rating'),
/// )
/// ```
class RatingWidget extends StatelessWidget {
  final double rating;
  final double size;
  final ValueChanged<double>? onRatingChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final int maxRating;
  final bool allowHalfRating;
  final double spacing;

  const RatingWidget({
    super.key,
    required this.rating,
    this.size = 24,
    this.onRatingChanged,
    this.activeColor,
    this.inactiveColor,
    this.maxRating = 5,
    this.allowHalfRating = true,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? Theme.of(context).colorScheme.primary;
    final inactive = inactiveColor ?? Colors.grey.shade300;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final starValue = index + 1;
        IconData icon;
        Color color;

        if (rating >= starValue) {
          icon = Icons.star;
          color = active;
        } else if (allowHalfRating && rating >= starValue - 0.5) {
          icon = Icons.star_half;
          color = active;
        } else {
          icon = Icons.star_border;
          color = inactive;
        }

        return GestureDetector(
          onTap: onRatingChanged != null ? () => onRatingChanged!(starValue.toDouble()) : null,
          child: Padding(
            padding: EdgeInsets.only(
              right: index < maxRating - 1 ? spacing : 0,
            ),
            child: Icon(icon, size: size, color: color),
          ),
        );
      }),
    );
  }
}

/// Compact rating display with text
///
/// Usage:
/// ```dart
/// RatingWithText(rating: 4.5, reviewCount: 120)
/// ```
class RatingWithText extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final double textSize;
  final Color? textColor;

  const RatingWithText({
    super.key,
    required this.rating,
    this.reviewCount,
    this.textSize = 14,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? Colors.grey.shade600;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, size: textSize, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: textSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(fontSize: textSize - 2, color: color),
          ),
        ],
      ],
    );
  }
}
