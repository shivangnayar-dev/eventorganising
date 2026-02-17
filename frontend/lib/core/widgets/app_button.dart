import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = true,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(label),
      ],
    );

    if (isPrimary) {
      return FilledButton(onPressed: onPressed, child: child);
    }
    return OutlinedButton(onPressed: onPressed, child: child);
  }
}
