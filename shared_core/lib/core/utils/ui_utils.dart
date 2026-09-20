// ignore_for_file: prefer_final_locals

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_core/core/ui/widgets/custom_container.dart';
import 'package:shared_core/core/ui/widgets/custom_inkwell_container.dart';
import 'package:shared_core/core/ui/widgets/custom_sized_box.dart';
import 'package:shared_core/core/ui/widgets/custom_svg_picture.dart';
import 'package:shared_core/core/ui/widgets/custom_text.dart';
import 'package:shared_core/core/utils/app_alerts.dart';
import 'package:shared_core/core/utils/app_constants.dart';
import 'package:shared_core/core/utils/colors.dart';
import 'package:shared_core/core/utils/custom_image.dart';
import 'package:shared_core/core/utils/responsive_size.dart';
import 'package:toastification/toastification.dart';
import 'package:vibration/vibration.dart';

// enum MessageType { success, error, warning }

class UiUtils {
  static bool authenticationError = false;

  static const int minimumMobileNumberDigit = 6;
  static const int maximumMobileNumberDigit = 15;
  static const int chatLimit = 25;

  //constant variables
  static const String limitOfAPIData = '10';

  static const String animationPath = 'assets/animation/';

  //border radius
  static const double borderRadiusOf5 = 5;
  static const double borderRadiusOf6 = 6;
  static const double borderRadiusOf8 = 8;
  static const double borderRadiusOf10 = 10;
  static const double borderRadiusOf12 = 12;
  static const double borderRadiusOf20 = 20;
  static const double borderRadiusOf50 = 50;

  // Toast message display duration
  static const int messageDisplayDuration = 3000;

  //shimmerLoadingContainer value
  static int numberOfShimmerContainer = 7;

  //to give bottom scroll padding in screen where
  //bottom navigation bar is displayed
  static double getScrollViewBottomPadding( BuildContext context) =>
      kBottomNavigationBarHeight.rh(context) + 5.rh(context);

  static Locale getLocaleFromLanguageCode( String languageCode) {
    final result = languageCode.split('-');
    return result.length == 1 ? Locale(result.first) : Locale(result.first, result.last);
  }

  static void showMessage(
    BuildContext context,
    String? message,
    ToastificationType? type, {
    VoidCallback? onMessageClosed,
  }) {
    toastification
      ..dismissAll()
      ..show(
        context: context,
        type: type,
        style: ToastificationStyle.fillColored,
        autoCloseDuration: const Duration(seconds: 3),
        title: Text(
          message!,
          maxLines: 100,
          softWrap: true,
          overflow: TextOverflow.visible,
          style: TextStyle(fontSize: 14.rf(context), color: Colors.white),
        ),
        alignment: Alignment.bottomCenter,
        direction: ui.TextDirection.ltr,
        animationDuration: const Duration(milliseconds: 300),
        // icon: const Icon(Icons.check),
        showIcon: true,
        padding: EdgeInsets.symmetric(
          horizontal: 12.rw(context),
          vertical: 16.rh(context),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: 12.rw(context),
          vertical: 8.rh(context),
        ),
        borderRadius: BorderRadius.circular(12.rw(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 16,
            offset: Offset(0, 16),
          ),
        ],
        showProgressBar: false,
        closeButton: const ToastCloseButton(
          showType: CloseButtonShowType.always,
        ),
        // closeButtonShowType: CloseButtonShowType.always,
        closeOnClick: false,
        pauseOnHover: false,
        dragToClose: true,
        applyBlurEffect: true,
      );

    // Trigger the callback after the duration (if provided)
    if (onMessageClosed != null) {
      Future.delayed(const Duration(seconds: 3), onMessageClosed);
    }
  }

  // Only numbers can be entered
  static List<TextInputFormatter> allowOnlyDigits() => <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
  ];

  static Future<dynamic> showBottomSheet({
    required  BuildContext context,
    required  Widget child,
     Color? backgroundColor,
     bool? enableDrag,
     bool? isScrollControlled,
     bool? useSafeArea,
  }) async {
    final result = await showModalBottomSheet<dynamic>(
      backgroundColor: backgroundColor ?? AppColor.secondary,
      enableDrag: enableDrag ?? false,
      isScrollControlled: isScrollControlled ?? true,
      useSafeArea: useSafeArea ?? false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadiusOf20),
          topRight: Radius.circular(borderRadiusOf20),
        ),
      ),
      context: context,
      builder: (_) {
        //using backdropFilter to blur the background screen
        //while bottomSheet is open
        return BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: child,
        );
      },
    );

    return result;
  }

  static Widget getBackArrow(
    BuildContext context, {
    VoidCallback? onTap,
    Color? backgroundColor,
  }) {
    return CustomInkWellContainer(
      onTap: () {
        if (onTap != null) {
          onTap.call();
        } else {
          Navigator.pop(context);
        }
      },
      child: CustomContainer(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(5),
        color: backgroundColor ?? AppColor.secondary,
        borderRadius: UiUtils.borderRadiusOf10,
        child: Center(
          child: CustomSvgPicture(
            width: 56,
            svgImage:
                // context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                Directionality.of(
                  context,
                ).toString().contains(TextDirection.RTL.value.toLowerCase())
                ? CustomImageGetter
                      .bedIcon // need to change later
                : CustomImageGetter.bedIcon,
            color: AppColor.secondary,
          ),
        ),
      ),
    );
  }

  static AppBar getSimpleAppBar({
    required  BuildContext context,
     String? title,
     Widget? titleWidget,
     Color? backgroundColor,
     bool? centerTitle,
     bool? isLeadingIconEnable,
     double? elevation,
     List<Widget>? actions,
     FontWeight? fontWeight,
     double? fontSize,
     PreferredSize? bottom,
  }) => AppBar(
    leadingWidth: isLeadingIconEnable ?? true ? null : 0,
    surfaceTintColor: AppColor.secondary,
    systemOverlayStyle: UiUtils.getSystemUiOverlayStyle(context: context),
    leading: isLeadingIconEnable ?? true ? getBackArrow(context) : const CustomSizedBox(),
    title: title != null
        ? CustomText(
            title,
            color: AppColor.black,
            fontWeight: fontWeight,
            fontSize: fontSize ?? 18,
          )
        : titleWidget,
    centerTitle: centerTitle ?? false,
    elevation: elevation ?? 0.0,
    backgroundColor: backgroundColor ?? AppColor.secondary,
    actions: actions ?? [],
    bottom: bottom,
  );

  static SystemUiOverlayStyle getSystemUiOverlayStyle({
    required BuildContext context,
  }) {
    return const SystemUiOverlayStyle(
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColor.secondary,
      statusBarColor: AppColor.secondary,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    );
  }

  static void removeFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static Future<void> getVibrationEffect() async {
    if (await Vibration.hasVibrator()) {
      await Vibration.vibrate(duration: 100);
    }
  }

  static Future<void> showAnimatedDialog({
    required BuildContext context,
    required Widget child,
  }) async {
    await showGeneralDialog(
      context: context,
      pageBuilder: ( context,  animation,  secondaryAnimation) =>
          const CustomSizedBox(),
      transitionBuilder:
          (
             context,
             animation,
             secondaryAnimation,
            Widget _,
          ) => Transform.scale(
            scale: Curves.easeInOut.transform(animation.value),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1),
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadiusOf10),
                ),
                child: child,
              ),
            ),
          ),
    );
  }

  static Future<void> copyToClipboard(
    BuildContext context,
    String text, {
    String message = 'Copied to clipboard',
  }) async {
    await Clipboard.setData(ClipboardData(text: text));

    // Show feedback to the user
    if (context.mounted) {
      AppAlerts.success(context, message);
    }
  }

  static Future<void> share(
    String text, {
    required BuildContext context,
    List<XFile>? files,
    String? subject,
  }) async {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final sharePositionOrigin = box.localToGlobal(Offset.zero) & box.size;

    await SharePlus.instance.share(
      ShareParams(
        files: files,
        text: text,
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  static String formatTimeWithDateTime(DateTime dateTime) {
    if (AppConstants.dateAndTimeSetting['use24HourFormat'] == true) {
      return DateFormat('kk:mm').format(dateTime);
    } else {
      return DateFormat('hh:mm a').format(dateTime);
    }
  }

  static Future<void> downloadOrShareFile({
    required String url,
    String? customFileName,
    required bool isDownload,
  }) async {
    try {
      String downloadFilePath = isDownload
          ? (await getApplicationDocumentsDirectory()).path
          : (await getTemporaryDirectory()).path;

      downloadFilePath =
          '$downloadFilePath/${customFileName != null ? customFileName : DateTime.now().toIso8601String()}';

      if (await File(downloadFilePath).exists()) {
        if (isDownload) {
          OpenFile.open(downloadFilePath);
        } else {
          SharePlus.instance.share(
            ShareParams(text: 'Share', files: [XFile(downloadFilePath)]),
          );
        }
        return;
      }

      var httpClient = HttpClient();
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);

      await File(downloadFilePath).writeAsBytes(bytes, flush: !isDownload);
      if (isDownload) {
        OpenFile.open(downloadFilePath);
      } else {
        SharePlus.instance.share(
          ShareParams(text: 'Share', files: [XFile(downloadFilePath)]),
        );
        // Share.shareXFiles([XFile(downloadFilePath)]);
      }
    } catch (_) {}
  }
}

class AnnotatedSafeArea extends StatefulWidget {
  final Widget child;
  final bool isAnnotated;

  const AnnotatedSafeArea({
    super.key,
    required this.child,
    this.isAnnotated = false,
  });

  @override
  State<AnnotatedSafeArea> createState() => _AnnotatedSafeAreaState();
}

class _AnnotatedSafeAreaState extends State<AnnotatedSafeArea> {
  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      color: AppColor.secondary,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: widget.child,
    );

    if (widget.isAnnotated) {
      content = AnnotatedRegion<SystemUiOverlayStyle>(
        value: UiUtils.getSystemUiOverlayStyle(context: context),
        child: content,
      );
    }

    return content;
  }
}
