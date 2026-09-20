import 'package:flutter/material.dart';
import '../../../../gen/assets.gen.dart';
import 'package:lottie/lottie.dart';

class EmptyView extends StatelessWidget {
  final String? message;
  final bool showError;
  final VoidCallback? onRetry;

  const EmptyView({super.key, this.message, this.showError = true, this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (showError == false) {
      return const SizedBox.shrink();
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 100,
            width: 150,
            child: Lottie.asset(Assets.animation.fail.path),
          ),
          const SizedBox(
            height: 5,
          ),
          Center(
            child: Text(
              message ?? 'Oooops ! ..',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
          ),
          if (onRetry != null)
            Container(
              padding: const EdgeInsets.only(top: 20),
              child: OutlinedButton(
                onPressed: onRetry,
                child: const Text('Try Again'),
              ),
            )
          else
            Container(),
        ],
      );
    }
  }
}
