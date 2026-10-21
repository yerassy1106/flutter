import 'package:flutter/material.dart';

/// R23: one widget for every empty state: icon, message, optional button.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.buttonLabel,
    this.onPressed,
  });

  final IconData icon;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = buttonLabel;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            if (label != null && onPressed != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: onPressed, child: Text(label)),
            ],
          ],
        ),
      ),
    );
  }
}
