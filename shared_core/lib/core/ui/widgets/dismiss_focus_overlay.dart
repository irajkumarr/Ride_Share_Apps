import 'package:flutter/material.dart';

class DismissFocusOverlay extends StatelessWidget {
  final Widget child;
  const DismissFocusOverlay({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: child,
    );
  }
}
