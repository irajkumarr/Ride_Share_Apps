import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_core/core/ui/widgets/custom_container.dart';
import 'package:shared_core/core/ui/widgets/custom_inkwell_container.dart';
import 'package:shared_core/core/ui/widgets/custom_svg_picture.dart';
import 'package:shared_core/core/ui/widgets/custom_text.dart';
import 'package:shared_core/core/utils/colors.dart';
import 'package:shared_core/core/utils/ui_utils.dart';
import 'package:shared_core/gen/assets.gen.dart';

class SearchWidget extends StatefulWidget {
  final List<String> searchHints;
  final VoidCallback? onTap;
  final Duration cycleDuration;
  final Duration changeInterval;
  final ValueNotifier<bool>? showShadow;

  const SearchWidget({
    super.key,
    required this.searchHints,
    this.onTap,
    this.cycleDuration = const Duration(milliseconds: 1200),
    this.changeInterval = const Duration(seconds: 3),
    this.showShadow,
  }) : assert(searchHints.length > 0, 'Provide at least one hint string.');

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> with SingleTickerProviderStateMixin {
  late final ValueNotifier<int> _currentIndex = ValueNotifier(0);
  late final AnimationController _controller;

  /// Phase 1 — controller 0.0 → 0.5: current text slides UP and fades OUT.
  late final Animation<double> _exitAnim;

  /// Phase 2 — controller 0.5 → 1.0: next text slides UP from below, fades IN.
  late final Animation<double> _enterAnim;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.cycleDuration,
    );

    _exitAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _enterAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // At controller.value = 0.0:
    //   _exitAnim = 0, _enterAnim = 0
    //   → opacity = 1.0, dy = 0  ✓ first hint fully visible immediately.
    _startCycling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _currentIndex.dispose();
    super.dispose();
  }

  void _startCycling() {
    if (widget.searchHints.length <= 1) return;

    _timer = Timer.periodic(widget.changeInterval, (_) async {
      _controller.reset(); // always start from t=0

      // ── Phase 1: exit (t: 0.0 → 0.5) ───────────────────────────────────
      // Current hint slides up and fades out.
      await _controller.animateTo(0.5);

      // ★ Swap the index HERE — in the invisible gap between exit and enter.
      //   The old text has fully left the frame; the new text is about to
      //   enter. This is why both use the SAME CustomText child: the index
      //   change is invisible to the user.
      _currentIndex.value = (_currentIndex.value + 1) % widget.searchHints.length;

      // ── Phase 2: enter (t: 0.5 → 1.0) ──────────────────────────────────
      // New hint rises from below and fades in.
      await _controller.animateTo(1.0);

      // Reset to t=0 — text is fully visible, ready for next interval.
      _controller.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: _buildInnerBar(context),
    );
  }

  Widget _buildInnerBar(BuildContext context) {
    return CustomContainer(
      borderRadiusStyle: const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      child: CustomInkWellContainer(
        onTap: widget.onTap,
        child: CustomContainer(
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          color: AppColor.lightPrimaryColor,
          borderRadius: UiUtils.borderRadiusOf10,
          child: Row(
            children: [
              CustomContainer(
                width: 30,
                height: 30,
                margin: const EdgeInsetsDirectional.only(end: 10),
                padding: const EdgeInsets.all(5),
                child: CustomSvgPicture(
                  svgImage: Assets.images.search.path,
                  color: AppColor.secondary,
                ),
              ),
              Expanded(
                flex: 8,
                child: ValueListenableBuilder<int>(
                  valueListenable: _currentIndex,
                  builder: (context, index, _) {
                    return AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        final double dy;
                        final double opacity;

                        if (_controller.value <= 0.5) {
                          // ── Exit phase ─────────────────────────────────
                          // Text moves upward (-y) and fades out.
                          dy = -_exitAnim.value;
                          opacity = (1.0 - _exitAnim.value).clamp(0.0, 1.0);
                        } else {
                          // ── Enter phase ────────────────────────────────
                          // Text starts below (+1) and rises to centre (0).
                          dy = 1.0 - _enterAnim.value;
                          opacity = _enterAnim.value.clamp(0.0, 1.0);
                        }

                        return CustomContainer(
                          height: 50,
                          alignment: Alignment(-1, dy),
                          child: Opacity(
                            opacity: opacity,
                            child: CustomText(
                              widget.searchHints[index],
                              color: AppColor.lightGray,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              maxLines: 1,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HOW TO USE
// ---------------------------------------------------------------------------
//
// 1.  Declare a scroll-shadow notifier in your parent widget's State:
//
//     final ValueNotifier<bool> _showShadow = ValueNotifier(false);
//
//     void _scrollListener() {
//       _showShadow.value = scrollController.position.pixels > 7;
//     }
//
//     @override
//     void dispose() {
//       _showShadow.dispose();
//       super.dispose();
//     }
//
//
// 2.  Drop the widget wherever you need it – no Cubit/Bloc required:
//
//     AnimatedSearchBar(
//       searchHints: const [
//         'searchProviders',
//         'searchServices',
//         'searchElectronics',
//         'searchHairCutting',
//         'searchFanRepair',
//       ],
//       showShadow: _showShadow,           // optional – pass null to skip shadow
//       onTap: () => Navigator.pushNamed(context, searchScreen),
//       cycleDuration: const Duration(milliseconds: 2500), // optional
//       changeInterval: const Duration(seconds: 3),        // optional
//     ),
//
//
// 3.  Minimal usage (shadow & tap callback both optional):
//
//     AnimatedSearchBar(
//       searchHints: ['searchProviders', 'searchServices'],
//     ),
//
// ---------------------------------------------------------------------------

/// Minimal Usage
// SearchWidget(
// Pass null here — shadow is already handled by the outer
// AnimatedContainer above, so we don't double-shadow.
//   showShadow: null,
//   searchHints: const [
//     'Search Providers',
//     'Search Services',
//     'Search Electronics',
//     'Search Hair Cutting',
//     'Search Fan Repair',
//   ],
// ),

// final ScrollController _scrollController = ScrollController();

// /// Drives the drop-shadow under the search bar while scrolling.
// final ValueNotifier<bool> showShadowBelowSearchBar = ValueNotifier(false);

// @override
// void initState() {
//   super.initState();
//   _scrollController.addListener(_onScroll);
// }

// void _onScroll() {
//   if (_scrollController.position.pixels > 7 &&
//       !showShadowBelowSearchBar.value) {
//     showShadowBelowSearchBar.value = true;
//   } else if (_scrollController.position.pixels < 7 &&
//       showShadowBelowSearchBar.value) {
//     showShadowBelowSearchBar.value = false;
//   }
// }

// @override
// void dispose() {
//   _scrollController
//     ..removeListener(_onScroll)
//     ..dispose();
//   showShadowBelowSearchBar.dispose();
//   super.dispose();
// }

// Main Usage

// class _StickyHeader extends StatelessWidget {
//   const _StickyHeader({required this.showShadow});

//   final ValueNotifier<bool> showShadow;

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<bool>(
//       valueListenable: showShadow,
//       builder: (context, hasShadow, _) {
//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           decoration: BoxDecoration(
//             color: AppColor.white,
//             borderRadius: const BorderRadius.only(
//               bottomLeft: Radius.circular(UiUtils.borderRadiusOf10),
//               bottomRight: Radius.circular(UiUtils.borderRadiusOf10),
//             ),
//             // Shadow appears only while the list is scrolled down.
//             boxShadow: hasShadow
//                 ? [
//                     BoxShadow(
//                       offset: const Offset(0, 2.4),
//                       spreadRadius: 1,
//                       blurRadius: 5,
//                       color: AppColor.lightGray.withAlpha(80),
//                     ),
//                   ]
//                 : [],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ── Animated search bar ───────────────────────────────────────
//               SearchWidget(
//                 // Pass null here — shadow is already handled by the outer
//                 // AnimatedContainer above, so we don't double-shadow.
//                 showShadow: null,
//                 searchHints: const [
//                   'Search Providers',
//                   'Search Services',
//                   'Search Electronics',
//                   'Search Hair Cutting',
//                   'Search Fan Repair',
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
