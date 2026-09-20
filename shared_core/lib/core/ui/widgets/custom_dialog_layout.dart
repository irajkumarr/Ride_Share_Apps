import 'package:flutter/material.dart';
import 'package:shared_core/common/extensions/extensions.dart';
import 'package:shared_core/core/ui/widgets/custom_circular_progress_indicator.dart';
import 'package:shared_core/core/ui/widgets/custom_container.dart';
import 'package:shared_core/core/ui/widgets/custom_inkwell_container.dart';
import 'package:shared_core/core/ui/widgets/custom_sized_box.dart';
import 'package:shared_core/core/ui/widgets/custom_text.dart';
import 'package:shared_core/core/utils/colors.dart';
import 'package:shared_core/core/utils/ui_utils.dart';

class CustomDialogLayout extends StatelessWidget {
  final String title;
  final String? description;
  final String confirmButtonName;
  final String cancelButtonName;
  final Color confirmButtonBackgroundColor;
  final Color cancelButtonBackgroundColor;
  final Function cancelButtonPressed;
  final Function confirmButtonPressed;
  final Widget? icon;
  final Widget? confirmButtonChild;
  final bool? showProgressIndicator;

  const CustomDialogLayout({
     super.key,
    required this.title,
    this.description,
    required this.confirmButtonName,
    required this.cancelButtonName,
    this.icon,
    required this.cancelButtonPressed,
    required this.confirmButtonPressed,
    required this.confirmButtonBackgroundColor,
    required this.cancelButtonBackgroundColor,
    this.confirmButtonChild,
    this.showProgressIndicator = false,
  });

  @override
  Widget build( BuildContext context) => CustomContainer(
    avoideResponsive: true,
    height: context.screenHeight * 0.294,
    color: AppColor.white,
    borderRadius: UiUtils.borderRadiusOf10,
    alignment: Alignment.center,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: CustomSizedBox(
            height: context.screenHeight * 0.3 - 50,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    const CustomSizedBox(height: 20),
                    icon!,
                    const CustomSizedBox(height: 20),
                  ] else ...[
                    const CustomSizedBox(height: 10),
                  ],
                  CustomText(
                    title,
                    color: AppColor.black,
                    fontSize: 16,
                  ),
                  const CustomSizedBox(height: 5),
                  if (description != null) ...[
                    const CustomSizedBox(height: 10),
                    CustomText(
                      description!,
                      color: AppColor.warmGray,
                      fontSize: 12,
                      maxLines: 10,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: CloseAndConfirmButton(
            avoideResponsive: true,
            confirmButtonBackgroundColor: confirmButtonBackgroundColor,
            confirmButtonName: confirmButtonName,
            confirmButtonChild: confirmButtonChild,
            showProgressIndicator: showProgressIndicator,
            closeButtonBackgroundColor: cancelButtonBackgroundColor,
            closeButtonName: cancelButtonName,
            closeButtonPressed: () {
              cancelButtonPressed.call();
            },
            confirmButtonPressed: () {
              confirmButtonPressed.call();
            },
          ),
        ),
      ],
    ),
  );
}

class CloseAndConfirmButton extends StatelessWidget {
  final String? confirmButtonName;
  final String? closeButtonName;
  final Color? confirmButtonBackgroundColor;
  final Color? closeButtonBackgroundColor;

  ///default it will be false
  final bool? showProgressIndicator;
  final Function closeButtonPressed;
  final Function confirmButtonPressed;
  final Widget? confirmButtonChild;
  final bool? avoideResponsive;

  const CloseAndConfirmButton({
    super.key,
    this.confirmButtonName,
    this.closeButtonName,
    this.confirmButtonBackgroundColor,
    this.closeButtonBackgroundColor,
    this.showProgressIndicator,
    required this.closeButtonPressed,
    required this.confirmButtonPressed,
    this.confirmButtonChild,
    this.avoideResponsive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        children: [
          Expanded(
            child: CustomInkWellContainer(
              borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
              onTap: () {
                closeButtonPressed.call();
              },
              child: CustomContainer(
                avoideResponsive: avoideResponsive ?? false,
                height: 44,
                borderRadiusStyle: const BorderRadiusDirectional.only(
                  bottomStart: Radius.circular(UiUtils.borderRadiusOf10),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1c343f53),
                    offset: Offset(0, -3),
                    blurRadius: 10,
                  ),
                ],
                color: closeButtonBackgroundColor ?? AppColor.secondary,
                child: Center(
                  child: CustomText(
                    (closeButtonName ?? 'close'),
                    fontSize: 14,
                    color: AppColor.black,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: CustomInkWellContainer(
              borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
              onTap: () {
                confirmButtonPressed.call();
              },
              child: CustomContainer(
                avoideResponsive: avoideResponsive ?? false,
                height: 44,
                borderRadiusStyle: const BorderRadiusDirectional.only(
                  bottomEnd: Radius.circular(UiUtils.borderRadiusOf10),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1c343f53),
                    offset: Offset(0, -3),
                    blurRadius: 10,
                  ),
                ],
                color: confirmButtonBackgroundColor ?? AppColor.secondary,
                child: Center(
                  child: showProgressIndicator ?? false
                      ? showCircularProgressIndicator(context: context)
                      : confirmButtonChild ??
                            CustomText(
                              (confirmButtonName ?? 'confirm'),
                              color: AppColor.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                            ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget showCircularProgressIndicator({required BuildContext context}) {
    return const Padding(
      padding: const EdgeInsets.all(5),
      child: CustomSizedBox(
        height: 30,
        width: 25,
        child: CustomCircularProgressIndicator(
          color: AppColor.secondary,
        ),
      ),
    );
  }
}
