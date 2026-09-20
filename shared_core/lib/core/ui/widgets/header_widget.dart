

import 'package:flutter/material.dart';
import 'package:shared_core/core/ui/widgets/custom_text.dart';
import 'package:shared_core/core/utils/colors.dart';
import 'package:shared_core/core/utils/font.dart';

class HeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  const HeaderWidget({
    required this.title,
    super.key,
    this.padding,
    this.widget,
    this.color,
    this.isBackButton = true,
  });
  final String title;
  final Widget? widget;
  final Color? color;
  final bool isBackButton;

  final double? padding;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(
        left: screenWidth * 0.05,
        right: screenWidth * 0.05,
        top: statusBarHeight + 15,
        bottom: 15,
      ),
      decoration: BoxDecoration(
        color: AppColor.background,
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: AppColor.gray.withValues(alpha: 0.2),
          ),
        ),
      ),
      width: double.infinity,
      child: Row(
        children: [
          if (isBackButton)
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_rounded,
                color: color ?? AppColor.black,
              ),
            ),
          if (isBackButton)
            const SizedBox(
              width: 15,
            ),

          CustomText(
            title,
            fontSize: AppFontSize.size18,
            fontWeight: AppFontWeight.bold,
            color: color ?? null,
          ),
          const Spacer(),
          ?widget,
        ],
      ),
    );
  }
}
