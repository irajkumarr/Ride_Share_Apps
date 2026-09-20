// import '../../utils/general_imports.dart';

// class LanguagePickerBottomSheet extends StatelessWidget {
//   const LanguagePickerBottomSheet({super.key});

//   static Future<void> show(BuildContext context) async {
//     return showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       showDragHandle: false,
//       sheetAnimationStyle: const AnimationStyle(
//         duration: Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       ),
//       builder: (_) => const LanguagePickerBottomSheet(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentLocale = LocaleSettings.currentLocale;

//     return BottomSheetLayout(
//       title: t.language,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _LanguageTile(
//             title: 'English',
//             subtitle: 'English',
//             flag: '🇺🇸',
//             locale: AppLocale.en,
//             isSelected: currentLocale == AppLocale.en,
//           ),

//           _LanguageTile(
//             title: 'नेपाली',
//             subtitle: 'Nepali',
//             flag: '🇳🇵',
//             locale: AppLocale.ne,
//             isSelected: currentLocale == AppLocale.ne,
//           ),

//           const SizedBox(height: 10),
//         ],
//       ),
//     );
//   }
// }

// class _LanguageTile extends StatelessWidget {
//   const _LanguageTile({
//     required this.title,
//     required this.subtitle,
//     required this.flag,
//     required this.locale,
//     required this.isSelected,
//   });

//   final String title;
//   final String subtitle;
//   final String flag;
//   final AppLocale locale;
//   final bool isSelected;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
//       child: Material(
//         color: isSelected ? AppColor.secondary.withValues(alpha: 0.04) : Colors.transparent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//           side: BorderSide(
//             color: isSelected ? AppColor.secondary : const Color(0xFFE5E7EB),
//             width: isSelected ? 1.5 : 1.0,
//           ),
//         ),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(12),
//           onTap: () async {
//             LocaleSettings.setLocale(locale);

//             await sl<LocalStorageService>().setString(
//               LocalStorageKeys.locale,
//               value: locale.languageTag,
//             );

//             if (context.mounted) Navigator.pop(context);
//           },
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withValues(alpha: 0.04),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Text(
//                     flag,
//                     style: const TextStyle(fontSize: 22),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                           color: isSelected ? AppColor.secondary : AppColor.black,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         subtitle,
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: AppColor.black.withValues(alpha: 0.5),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (isSelected)
//                   Container(
//                     padding: const EdgeInsets.all(4),
//                     decoration: const BoxDecoration(
//                       color: AppColor.secondary,
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.check,
//                       color: Colors.white,
//                       size: 16,
//                     ),
//                   )
//                 else
//                   Container(
//                     width: 24,
//                     height: 24,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: const Color(0xFFD1D5DB),
//                         width: 1.5,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
