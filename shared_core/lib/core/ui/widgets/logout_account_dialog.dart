import 'package:flutter/material.dart';
import 'package:shared_core/core/ui/widgets/custom_container.dart';
import 'package:shared_core/core/ui/widgets/custom_dialog_layout.dart';
import 'package:shared_core/core/utils/colors.dart';
import 'package:shared_core/core/utils/ui_utils.dart';
import 'package:shared_core/gen/assets.gen.dart';


class LogoutAccountDialog extends StatelessWidget {
  const LogoutAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomDialogLayout(
      showProgressIndicator: false, // show if logout is loading
      icon: CustomContainer(
        height: 70,
        width: 70,
        padding: const EdgeInsets.all(10),
        borderRadius: UiUtils.borderRadiusOf50,
        child: Assets.images.drLogout.svg(color: AppColor.secondary),
      ),
      title: 'Confirm Logout',
      description: 'Are you sure you want to logout?',
      cancelButtonName: 'Cancel',
      cancelButtonBackgroundColor: AppColor.white,
      cancelButtonPressed: () {
        Navigator.of(context).pop();
      },
      confirmButtonName: 'Logout',
      confirmButtonBackgroundColor: AppColor.red,
      confirmButtonPressed: () {
        // sl<AuthRepo>().logout();
        // context.go(AppRoutes.login);
      },
    );
  }
}
