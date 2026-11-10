import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/core/routing/app_routes.dart';

/// Top brand header: RIDENEST logo text and hamburger menu icon.
class HomeHeader extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  const HomeHeader({super.key, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: -0.8,
            ),
            children: [
              TextSpan(
                text: 'RIDE',
                style: TextStyle(color: Color(0xFF111827)),
              ),
              TextSpan(
                text: 'NEST',
                style: TextStyle(color: Color(0xFFFF3B30)),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onMenuPressed ?? () => context.push(AppRoutes.profile),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(
            Icons.menu_rounded,
            size: 32,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
