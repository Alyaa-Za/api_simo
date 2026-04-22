import 'package:flutter/material.dart';
import '../../core/ui/app_color.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onAction;
  final String actionText;

  const EmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.inbox,
    this.onAction,
    this.actionText = 'Add',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.textGrey),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textGrey)),
            if (onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(onPressed: onAction, child: Text(actionText)),
            ],
          ],
        ),
      ),
    );
  }
}