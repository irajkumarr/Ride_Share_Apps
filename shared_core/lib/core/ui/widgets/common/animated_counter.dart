import 'package:flutter/material.dart';
import 'dart:async';

/// Animated counter that counts up or down to a target value
///
/// Usage:
/// ```dart
/// // Count up to 1000
/// AnimatedCounter(
///   value: 1000,
///   duration: const Duration(seconds: 2),
///   prefix: '\$',
///   style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
/// )
/// ```
class AnimatedCounter extends StatefulWidget {
  final double value;
  final Duration duration;
  final String? prefix;
  final String? suffix;
  final TextStyle? style;
  final int decimalPlaces;
  final bool showComma;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(seconds: 2),
    this.prefix,
    this.suffix,
    this.style,
    this.decimalPlaces = 0,
    this.showComma = true,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation =
        Tween<double>(
          begin: 0,
          end: widget.value,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
          ),
        );

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animation =
          Tween<double>(
            begin: _previousValue,
            end: widget.value,
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Curves.easeOutCubic,
            ),
          );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(double number) {
    if (widget.showComma) {
      return number
          .toStringAsFixed(widget.decimalPlaces)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    return number.toStringAsFixed(widget.decimalPlaces);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final displayValue = _formatNumber(_animation.value);
        return Text(
          '${widget.prefix ?? ''}$displayValue${widget.suffix ?? ''}',
          style: widget.style ?? Theme.of(context).textTheme.headlineMedium,
        );
      },
    );
  }
}

/// Timer countdown widget
///
/// Usage:
/// ```dart
/// CountdownTimer(
///   endTime: DateTime.now().add(Duration(hours: 1)),
///   onComplete: () => print('Timer completed'),
///   builder: (remaining) => Text(remaining),
/// )
/// ```
class CountdownTimer extends StatefulWidget {
  final DateTime endTime;
  final VoidCallback? onComplete;
  final Widget Function(Duration remaining) builder;
  final Duration tickInterval;

  const CountdownTimer({
    super.key,
    required this.endTime,
    this.onComplete,
    required this.builder,
    this.tickInterval = const Duration(seconds: 1),
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _remaining = widget.endTime.difference(DateTime.now());
    if (_remaining.isNegative) {
      _remaining = Duration.zero;
      widget.onComplete?.call();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(widget.tickInterval, (_) {
      if (!mounted) return;
      setState(() {
        _remaining = widget.endTime.difference(DateTime.now());
        if (_remaining.isNegative) {
          _remaining = Duration.zero;
          _timer.cancel();
          widget.onComplete?.call();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_remaining);
  }
}

/// Simple formatted countdown (HH:MM:SS)
///
/// Usage:
/// ```dart
/// FormatCountdown(endTime: DateTime.now().add(Duration(hours: 2)))
/// ```
class FormatCountdown extends StatelessWidget {
  final DateTime endTime;
  final TextStyle? style;
  final bool showDays;

  const FormatCountdown({
    super.key,
    required this.endTime,
    this.style,
    this.showDays = false,
  });

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return '00:00:00';

    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (showDays) {
      final days = duration.inDays;
      return '$days:$hours:$minutes:$seconds';
    }
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return CountdownTimer(
      endTime: endTime,
      builder: (remaining) => Text(
        _formatDuration(remaining),
        style: style ?? Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
