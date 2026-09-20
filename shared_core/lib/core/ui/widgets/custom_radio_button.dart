import 'package:flutter/material.dart';
import 'package:shared_core/core/utils/colors.dart';
import 'package:shared_core/core/utils/ui_utils.dart';

class CustomRadioButton extends StatelessWidget {
  const CustomRadioButton({super.key, required this.onChanged, this.value});

  final dynamic Function(bool?) onChanged;
  final bool? value;

  @override
  Widget build(BuildContext context) {
    return Checkbox.adaptive(
      activeColor: AppColor.secondary,
      fillColor: WidgetStateProperty.all(
        AppColor.secondary,
      ),
      side: WidgetStateBorderSide.resolveWith(
        (states) => const BorderSide(width: 1.0, color: AppColor.secondary),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf50),
      ),
      visualDensity: VisualDensity.standard,
      checkColor: AppColor.secondary,
      value: value,
      onChanged: (bool? val) {
        onChanged.call(val);
      },
    );
  }
}
