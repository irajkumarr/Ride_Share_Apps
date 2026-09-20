import 'package:flutter/material.dart';
import '../../../common/extensions/extensions.dart';
import 'custom_container.dart';
import 'custom_text.dart';
import '../../utils/colors.dart';
import '../../utils/ui_utils.dart';

class BottomSheetLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final bool? topPadding;
  final Widget? bottomWidget;
  const BottomSheetLayout({
    super.key,
    required this.title,
    required this.child,
    this.topPadding,
    this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColor.background,
      borderRadiusStyle: const BorderRadius.only(
        topRight: Radius.circular(UiUtils.borderRadiusOf20),
        topLeft: Radius.circular(UiUtils.borderRadiusOf20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title.isNotEmpty)
            CustomContainer(
              width: context.screenWidth,
              padding: const EdgeInsets.all(15.0),
              color: AppColor.background,
              borderRadiusStyle: const BorderRadius.only(
                topRight: Radius.circular(UiUtils.borderRadiusOf20),
                topLeft: Radius.circular(UiUtils.borderRadiusOf20),
              ),
              child: CustomText(
                title,
                fontSize: 18.0,
                maxLines: 1,
                color: AppColor.black,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                textAlign: TextAlign.center,
              ),
            ),
          Flexible(
            child: CustomContainer(
              padding: topPadding == false
                  ? EdgeInsets.zero
                  : const EdgeInsetsDirectional.only(top: 5),
              color: AppColor.background,
              child: SingleChildScrollView(child: child),
            ),
          ),
          if (bottomWidget != null) bottomWidget!,
        ],
      ),
    );
  }
}
