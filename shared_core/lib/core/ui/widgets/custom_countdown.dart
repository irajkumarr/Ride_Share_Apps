import 'package:flutter/material.dart';
import 'dart:async';

import '../../utils/colors.dart';

class CountdownTimer extends StatefulWidget {
  final Duration duration;

  CountdownTimer({required this.duration});

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  Duration _remainingTime = const Duration();

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.duration;
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime -= const Duration(seconds: 1);
        } else {
          _timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int days = _remainingTime.inDays;
    int hours = _remainingTime.inHours % 24;
    int minutes = _remainingTime.inMinutes % 60;
    int seconds = _remainingTime.inSeconds % 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildTimeBox(days.toString().padLeft(2, '0'), 'Days'),
        _buildTimeBox(hours.toString().padLeft(2, '0'), 'Hours'),
        _buildTimeBox(minutes.toString().padLeft(2, '0'), 'Minutes'),
        _buildTimeBox(seconds.toString().padLeft(2, '0'), 'Seconds'),
      ],
    );
  }

  Widget _buildTimeBox(String time, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$time${label != 'Seconds' ? ' : ' : ''}', // ${label != 'Seconds' ? ':':''}
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            // fontWeight: FontWeight.bold,
            color: AppColor.secondary,
          ),
        ),

        // Text(
        //   label,
        //   style: TextStyle(
        //     fontSize: 12,
        //   ),
        // ),
      ],
    );
  }
}
