import 'package:flutter/material.dart';

/// Location Pill: displays the current pickup address title with an edit chevron.
class LocationPill extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const LocationPill({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final displayTitle = title.length > 25
        ? '${title.substring(0, 25)}...'
        : title;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.place_rounded,
                size: 14,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                displayTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
