import 'package:flutter/material.dart';

class CustomToolTip extends StatelessWidget {
  const CustomToolTip({
    required this.toolTipMessage,
    required this.child,
    super.key,
  });
  final String toolTipMessage;
  final Widget child;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: toolTipMessage,
    triggerMode: TooltipTriggerMode.longPress,
    child: child,
  );
}
