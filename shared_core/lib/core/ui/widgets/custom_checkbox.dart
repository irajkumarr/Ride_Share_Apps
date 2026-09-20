import 'package:flutter/material.dart';
import 'package:shared_core/common/extensions/extensions.dart';
import 'package:shared_core/core/utils/colors.dart';
import 'package:shared_core/core/utils/ui_utils.dart';


class CustomCheckBox extends StatelessWidget {
  const CustomCheckBox({super.key, required this.onChanged, this.value});

  final dynamic Function(bool?) onChanged;
  final bool? value;

  @override
  Widget build(BuildContext context) {
    return Checkbox.adaptive(
      activeColor: AppColor.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(
        horizontal: -2,
        vertical: -4,
      ),
      checkColor: context.appColors.cardBackground,
      value: value,
      onChanged: (bool? val) {
        onChanged.call(val);
      },
    );
  }
}
