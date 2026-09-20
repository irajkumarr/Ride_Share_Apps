import 'package:flutter/material.dart';
import 'custom_inkwell_container.dart';
import '../../utils/responsive_size.dart';
import 'package:flutter_svg/svg.dart';

class CustomSvgPicture extends StatelessWidget {
  final String svgImage;
  final VoidCallback? onTap;
  final Color? color;
  final double? height;
  final double? width;
  final BoxFit? boxFit;
  final bool? avoideResponsive;

  const CustomSvgPicture({
    super.key,
    required this.svgImage,
    this.onTap,
    this.color,
    this.height,
    this.width,
    this.boxFit,
    this.avoideResponsive = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomInkWellContainer(
      onTap: onTap,
      child: SvgPicture.asset(
        svgImage,
        height: avoideResponsive == true ? height : height?.rs(context),
        width: avoideResponsive == true ? width : width?.rs(context),
        colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
        fit: boxFit ?? BoxFit.contain,
      ),
    );
  }
}
