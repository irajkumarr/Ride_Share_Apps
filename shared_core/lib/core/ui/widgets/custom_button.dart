import 'package:flutter/material.dart';

import 'custom_circular_progress_indicator.dart';
import '../../utils/colors.dart';
import '../../utils/font.dart';
import '../../utils/ui_utils.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.backgroundColor,
    this.textColor,
    this.height = 50,
    this.width,
    this.isBold = true,
    this.borderRadius = 5.0,
    this.isOutlined = false,
    this.isLoading = false,
    this.enableHaptics = false,
    this.child,
  });
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final bool isBold;
  final double borderRadius;
  final bool isOutlined;
  final bool isLoading;
  final bool enableHaptics;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = width ?? screenWidth * 0.9;
    final buttonTextStyle = TextStyle(
      color: textColor ?? (isOutlined ? AppColor.white : AppColor.white),
      fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
      fontSize: AppFontSize.size12,
    );

    final handlePress = () {
      if (enableHaptics) {
        UiUtils.getVibrationEffect();
      }
      onPressed?.call();
    };

    final innerChild = isLoading
        ? const CustomCircularProgressIndicator()
        : (child ??
              Text(
                text,
                style: buttonTextStyle,
                maxLines: 2,
                overflow: TextOverflow.visible,
                softWrap: true,
                textAlign: TextAlign.center,
              ));

    return Center(
      child: SizedBox(
        width: buttonWidth,
        // height: height,
        child: isOutlined
            ? OutlinedButton(
                onPressed: isLoading ? null : handlePress,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(),
                  alignment: Alignment.center,
                  minimumSize: Size(buttonWidth, height),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: innerChild,
              )
            : ElevatedButton(
                onPressed: isLoading ? null : handlePress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor ?? AppColor.secondary,
                  alignment: Alignment.center,
                  minimumSize: Size(buttonWidth, height),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    side: BorderSide.none,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: innerChild,
              ),
      ),
    );
  }
}

/*
// Usage Demonstration:
// --------------------
// CustomButton(
//   text: 'Submit',
//   isLoading: _isSubmitting,
//   enableHaptics: true,
//   onPressed: () => _submitData(),
// )
*/
