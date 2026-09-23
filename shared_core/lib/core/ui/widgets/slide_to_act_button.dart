import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable, fluid slide-to-act / slide-to-confirm widget.
/// Designed for high visual polish with customizable track, thumb, and text styling.
class SlideToActButton extends StatefulWidget {
  const SlideToActButton({
    super.key,
    required this.text,
    required this.onSlideComplete,
    this.backgroundColor = const Color(0xFF1B3238),
    this.thumbColor = const Color(0xFF00B4A0),
    this.textColor = Colors.white,
    this.thumbIconColor = Colors.white,
    this.height = 64.0,
    this.borderRadius = 32.0,
    this.thumbIcon = Icons.power_settings_new_rounded,
    this.isLoading = false,
    this.enabled = true,
  });

  final String text;
  final Future<void> Function() onSlideComplete;
  final Color backgroundColor;
  final Color thumbColor;
  final Color textColor;
  final Color thumbIconColor;
  final double height;
  final double borderRadius;
  final IconData thumbIcon;
  final bool isLoading;
  final bool enabled;

  @override
  State<SlideToActButton> createState() => _SlideToActButtonState();
}

class _SlideToActButtonState extends State<SlideToActButton>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  late AnimationController _resetController;
  late Animation<double> _resetAnimation;
  bool _isActionExecuting = false;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double maxDrag) {
    if (!widget.enabled || widget.isLoading || _isActionExecuting) return;

    setState(() {
      _dragPosition = (_dragPosition + details.delta.dx).clamp(0.0, maxDrag);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, double maxDrag) async {
    if (!widget.enabled || widget.isLoading || _isActionExecuting) return;

    // Trigger completion if dragged more than 80%
    if (_dragPosition >= maxDrag * 0.8) {
      HapticFeedback.mediumImpact();
      setState(() {
        _dragPosition = maxDrag;
        _isActionExecuting = true;
      });

      try {
        await widget.onSlideComplete();
      } finally {
        if (mounted) {
          _animateReset();
          setState(() {
            _isActionExecuting = false;
          });
        }
      }
    } else {
      _animateReset();
    }
  }

  void _animateReset() {
    _resetAnimation = Tween<double>(
      begin: _dragPosition,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _resetController,
      curve: Curves.easeOutCubic,
    ))..addListener(() {
        setState(() {
          _dragPosition = _resetAnimation.value;
        });
      });

    _resetController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final thumbSize = widget.height - 10.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final maxDrag = (totalWidth - thumbSize - 10.0).clamp(0.0, totalWidth);
        final dragProgress = maxDrag > 0 ? (_dragPosition / maxDrag).clamp(0.0, 1.0) : 0.0;

        return Container(
          height: widget.height,
          width: totalWidth,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: widget.backgroundColor.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Center / Background Text Prompt with fade on drag
              Center(
                child: Opacity(
                  opacity: (1.0 - (dragProgress * 1.4)).clamp(0.0, 1.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.text,
                        style: TextStyle(
                          color: widget.textColor.withValues(alpha: 0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sliding Thumb
              Positioned(
                left: 5.0 + _dragPosition,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) =>
                      _onHorizontalDragUpdate(details, maxDrag),
                  onHorizontalDragEnd: (details) =>
                      _onHorizontalDragEnd(details, maxDrag),
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.thumbColor.withValues(alpha: 0.85),
                          widget.thumbColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(widget.borderRadius - 4),
                      boxShadow: [
                        BoxShadow(
                          color: widget.thumbColor.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: widget.isLoading || _isActionExecuting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(
                              widget.thumbIcon,
                              color: widget.thumbIconColor,
                              size: 26,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
