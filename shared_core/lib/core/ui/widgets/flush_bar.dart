// // ignore_for_file: inference_failure_on_instance_creation


// import 'package:flutter/material.dart';

// class AppFlushBar {
//   static void success(
//     BuildContext context,
//     String message, {
//     String? title,
//     Color? color,
//     Widget? icon,
//   }) {
//     Flushbar(
//       title: title ?? 'Successful!!',
//       message: message,
//       flushbarPosition: FlushbarPosition.TOP,
//       margin: const EdgeInsets.symmetric(horizontal: 10),
//       borderRadius: BorderRadius.circular(8),
//       icon:
//           icon ??
//           const Icon(
//             Icons.check_circle,
//             color: Colors.white,
//           ),
//       duration: const Duration(seconds: 3),
//       backgroundColor: color ?? AppColor.primaryColor(1),
//     ).show(context);
//   }

//   static void error(
//     BuildContext context,
//     String message, {
//     String? title,
//     Color? color,
//   }) {
//     Flushbar(
//       title: title ?? 'Oops!',
//       message: message,
//       flushbarPosition: FlushbarPosition.TOP,
//       borderRadius: BorderRadius.circular(8),
//       margin: const EdgeInsets.symmetric(horizontal: 10),
//       icon: const Icon(
//         Icons.warning,
//         color: Colors.white,
//       ),
//       duration: const Duration(seconds: 3),
//       backgroundColor: color ?? Colors.red,
//     ).show(context);
//   }
// }
