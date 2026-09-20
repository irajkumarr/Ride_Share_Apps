import 'package:flutter/material.dart';
import 'package:shared_core/gen/assets.gen.dart';
import 'custom_circular_progress_indicator.dart';
import 'package:flutter_svg/svg.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // using Directionality in case this is loaded before MaterialApp sets it up
    // cleanly or above the app router, though it will be inside MaterialApp's builder
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(Assets.images.noConnection.path),
              const SizedBox(height: 24),
              const Text(
                'Whoops!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'No internet connection found.\nPlease check your connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              const CustomCircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text(
                'Waiting for network...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
