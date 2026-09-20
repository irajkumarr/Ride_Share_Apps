import 'package:flutter/material.dart';
import 'custom_cached_network_image.dart';

class CustomCircularAvatar extends StatelessWidget {
  final String imageUrl;
  final bool isBorderEnabled;
  final bool? isUrlComplete;
  final double? borderRadius;
  final Color? borderColor;
  final double? size;

  const CustomCircularAvatar({
    this.isBorderEnabled = true,
    required this.imageUrl,
    this.borderColor,
    this.size,
    this.borderRadius,
    this.isUrlComplete,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isBorderEnabled
          ? BoxDecoration(
              border: Border.all(color: borderColor ?? Colors.black12),
              borderRadius: BorderRadius.circular(borderRadius ?? 100),
            )
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? 100),
        child: SizedBox(
          height: size,
          child: CustomCachedNetworkImage(
            imageUrl,
            isUrlComplete: isUrlComplete,
          ),
        ),
      ),
    );
  }
}
