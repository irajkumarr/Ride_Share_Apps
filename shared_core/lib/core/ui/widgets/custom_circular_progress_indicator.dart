import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'custom_sized_box.dart';
import '../../utils/colors.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  const CustomCircularProgressIndicator({
     super.key,
    this.color,
    this.strokeWidth,
    this.widthAndHeight,
  });
  final Color? color;
  final double? strokeWidth;
  final double? widthAndHeight;

  @override
  Widget build( BuildContext context) => Center(
    child: CustomSizedBox(
      height: widthAndHeight ?? 30,
      width: widthAndHeight ?? 30,
      child: Platform.isAndroid
          ? CircularProgressIndicator(
              color: color ?? AppColor.secondary,
              backgroundColor: Colors.transparent,
              strokeWidth: 1.5,
            )
          : CupertinoActivityIndicator(color: color ?? Colors.transparent),
    ),
  );
}
