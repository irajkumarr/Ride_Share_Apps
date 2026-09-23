import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_core/core/ui/widgets/custom_container.dart';
import 'package:shared_core/core/ui/widgets/custom_dialog_layout.dart';
import 'package:shared_core/core/utils/colors.dart';
import 'package:shared_core/core/utils/ui_utils.dart';
import 'package:shared_core/gen/assets.gen.dart';

class LogoutAccountDialog extends StatelessWidget {
  const LogoutAccountDialog({super.key, required this.onConfirm});
  final Function onConfirm;
  @override
  Widget build(BuildContext context) {
    return CustomDialogLayout(
      showProgressIndicator: false, // show if logout is loading
      icon: CustomContainer(
        height: 70,
        width: 70,
        padding: const EdgeInsets.all(10),
        borderRadius: UiUtils.borderRadiusOf50,
        child: Assets.images.drLogout.svg(package: 'shared_core'),
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
        onConfirm();
      },
    );
  }
}
