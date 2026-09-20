import 'package:flutter/material.dart';
import 'custom_cached_network_image.dart';
import 'custom_svg_picture.dart';

/// A universal image widget that handles Asset, Network, and SVG images.
///
/// It automatically detects the image type based on the provided path or URL.
class AppImage extends StatelessWidget {
  /// The path to the asset or the URL of the image.
  final String path;

  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final bool isUrlComplete;

  const AppImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.isUrlComplete = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (path.startsWith('http') || path.startsWith('https')) {
      image = CustomCachedNetworkImage(
        path,
        fit: fit,
        isUrlComplete: isUrlComplete,
      );
    } else if (path.endsWith('.svg')) {
      image = CustomSvgPicture(
        svgImage: path,
        width: width,
        height: height,
        color: color,
        boxFit: fit,
      );
    } else {
      image = Image.asset(
        path,
        width: width,
        height: height,
        color: color,
        fit: fit,
      );
    }

    if (shape == BoxShape.circle) {
      return Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        clipBehavior: Clip.antiAlias,
        child: image,
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: SizedBox(
          width: width,
          height: height,
          child: image,
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: image,
    );
  }
}

/*
// Usage Demonstration:
// --------------------
// 1. Network Image:
// AppImage(path: 'https://example.com/image.jpg', width: 100, height: 100)
//
// 2. SVG Asset:
// AppImage(path: 'assets/icons/logo.svg', color: Colors.blue)
//
// 3. Circular Profile Image:
// AppImage(
//   path: userImageUrl,
//   shape: BoxShape.circle,
//   width: 50,
//   height: 50,
// )
*/
