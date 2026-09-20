// import 'package:flutter/material.dart';
// import 'package:flutter_abcd_architecture/src/core/utils/colors.dart';
// import 'package:flutter_abcd_architecture/src/core/utils/font.dart';

// class CustomTextField extends StatefulWidget {
//   final String? label;
//   final String? hintText;
//   final TextEditingController? controller;
//   final TextInputAction? textInputAction;
//   final bool isPassword;
//   final Widget? prefixIcon;
//   final Widget? suffixIcon;
//   final String? Function(String?)? validator;
//   final TextInputType keyboardType;
//   final bool readOnly;
//   final void Function(String)? onChanged;

//   const CustomTextField({
//     super.key,
//     this.label,
//     this.hintText,
//     this.controller,
//     this.textInputAction,
//     this.isPassword = false,
//     this.prefixIcon,
//     this.suffixIcon,
//     this.validator,
//     this.keyboardType = TextInputType.text,
//     this.readOnly = false,
//     this.onChanged,
//   });

//   @override
//   State<CustomTextField> createState() => _CustomTextFieldState();
// }

// class _CustomTextFieldState extends State<CustomTextField> {
//   bool _obscure = true;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (widget.label != null) ...[
//           Text(
//             widget.label!,
//             style: const TextStyle(
//               color: AppColor.gray,
//             ),
//           ),
//           const SizedBox(height: 8),
//         ],

//         TextFormField(
//           controller: widget.controller,
//           obscureText: widget.isPassword ? _obscure : false,
//           keyboardType: widget.keyboardType,
//           readOnly: widget.readOnly,
//           validator: widget.validator,
//           onChanged: widget.onChanged,
//           textInputAction: widget.textInputAction,
//           decoration: InputDecoration(
//             hintText: widget.hintText,
//             filled: true,
//             fillColor: Colors.transparent,

//             prefixIcon: widget.prefixIcon,

//             suffixIcon: widget.isPassword
//                 ? IconButton(
//                     icon: Icon(
//                       _obscure ? Icons.visibility_off : Icons.visibility,
//                       size: AppFontSize.size18,
//                     ),
//                     onPressed: () {
//                       setState(() => _obscure = !_obscure);
//                     },
//                   )
//                 : widget.suffixIcon,

//             contentPadding: const EdgeInsets.symmetric(
//               vertical: 14,
//               horizontal: 12,
//             ),

//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(5),
//               borderSide: BorderSide.none,
//             ),

//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(5),
//               borderSide: const BorderSide(
//                 color: AppColor.secondary,
//                 width: 1.5,
//               ),
//             ),

//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(5),
//               borderSide: const BorderSide(color: AppColor.red),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_core/core/utils/colors.dart';
import 'package:shared_core/core/utils/font.dart';
import 'package:shared_core/core/utils/ui_utils.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final bool isPassword;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool readOnly;
  final void Function(String)? onChanged;
  final bool enableHaptics;

  const CustomTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.textInputAction,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onChanged,
    this.enableHaptics = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> with SingleTickerProviderStateMixin {
  bool _obscure = true;

  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: const Offset(0.02, 0)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0.02, 0), end: const Offset(-0.02, 0)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(-0.02, 0), end: const Offset(0.02, 0)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0.02, 0), end: Offset.zero),
        weight: 1,
      ),
    ]).animate(_controller);
  }

  void _triggerErrorFeedback() {
    if (!widget.enableHaptics) return;
    _controller.forward(from: 0);
    UiUtils.getVibrationEffect();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: const TextStyle(color: AppColor.gray),
            ),
            const SizedBox(height: 8),
          ],
          TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword ? _obscure : false,
            keyboardType: widget.keyboardType,
            readOnly: widget.readOnly,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,

            ///  VALIDATOR WITH SHAKE + VIBRATION
            validator: (value) {
              final error = widget.validator?.call(value);

              if (error != null) {
                _triggerErrorFeedback();
              }

              return error;
            },

            decoration: InputDecoration(
              hintText: widget.hintText,
              filled: true,
              fillColor: Colors.transparent,

              prefixIcon: widget.prefixIcon,

              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        size: AppFontSize.size18,
                      ),
                      onPressed: () {
                        setState(() => _obscure = !_obscure);
                      },
                    )
                  : widget.suffixIcon,

              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 12,
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  color: AppColor.secondary,
                  width: 1.5,
                ),
              ),

              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: AppColor.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
