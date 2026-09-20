import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_core/core/utils/api_urls.dart';


class CustomCachedNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final String? localImagePath;
  final BoxFit? fit;
  final double? aspectRatio;
  final bool? isUrlComplete;

  const CustomCachedNetworkImage(
    this.imageUrl, {
    this.localImagePath,
    Key? key,
    this.fit,
    this.isUrlComplete,
    this.aspectRatio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: getImageUrl(imageUrl, isUrlComplete: isUrlComplete ?? true),
      imageBuilder: (context, imageProvider) => AspectRatio(
        aspectRatio: aspectRatio ?? 1,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: fit ?? BoxFit.cover,
            ),
          ),
        ),
      ),
      placeholder: (context, url) => AspectRatio(
        aspectRatio: 1,
        child: SvgPicture.asset(
          '',

          ///TODO:Change place holder image
          fit: BoxFit.cover,
        ),
      ),
      errorWidget: (context, url, error) => AspectRatio(
        aspectRatio: 1,
        child: SvgPicture.asset(
          localImagePath ?? '',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  static String getImageUrl(String? url, {required bool isUrlComplete}) {
    if (url != null && url != '') {
      if (isUrlComplete) {
        return url;
      } else {
        return '${ApiUrls.baseURL}/$url';
      }
    } else {
      return 'https://placehold.co/600x400';
    }
  }
}
