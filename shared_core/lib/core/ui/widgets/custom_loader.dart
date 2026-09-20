import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/custom_image.dart';

class CustomLoader extends StatefulWidget {
  const CustomLoader({super.key});

  @override
  State<CustomLoader> createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
    // RotationTransition(
    //   turns: _animationController,
    //   child:
    Container(
      alignment: Alignment.center,
      child: const Stack(
        alignment: Alignment.center,
        children: [
          const CircleAvatar(
            backgroundColor: AppColor.black,
            radius: 20,
            backgroundImage: const AssetImage(
              CustomImageGetter.logo,
            ),
          ),
          SizedBox(
            height: 50,
            width: 50,
            child: CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(AppColor.black),
              strokeWidth: 1,
            ),
          ),
        ],
      ),
      // ),
    );
  }
}
