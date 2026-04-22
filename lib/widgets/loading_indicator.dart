import 'package:flutter/material.dart';
import '../../core/ui/app_color.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;
  const LoadingIndicator({super.key, this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}