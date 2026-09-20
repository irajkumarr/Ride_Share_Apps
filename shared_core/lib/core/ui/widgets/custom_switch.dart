import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class CustomSwitch extends StatelessWidget {
  final bool value;
  final Color? trackColor;
  final Color? activeColor;
  final Color? thumbColor;
  final void Function(bool) onChanged;

  const CustomSwitch({
    super.key,
    required this.onChanged,
    required this.value,
    this.trackColor,
    this.activeColor,
    this.thumbColor,
  });

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoSwitch(
            activeTrackColor: activeColor ?? AppColor.secondary,
            thumbColor: thumbColor ?? AppColor.black,
            inactiveTrackColor: trackColor ?? AppColor.secondary,
            value: value,
            onChanged: (bool val) {
              onChanged.call(val);
            },
          )
        : Switch(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            value: value,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            thumbColor: WidgetStateProperty.all(
              thumbColor ?? AppColor.secondary,
            ),
            trackColor: WidgetStateProperty.all(
              trackColor ?? AppColor.secondary,
            ),
            onChanged: (bool val) {
              onChanged.call(val);
            },
          );
  }
}
