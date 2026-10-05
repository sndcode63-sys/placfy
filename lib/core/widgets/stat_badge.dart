import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final bool isSolid;

  const StatBadge({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.brandPurple,
    this.isSolid = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isSolid ? color : color.withValues(alpha: 0.08);
    final borderColor = isSolid ? Colors.transparent : color.withValues(alpha: 0.25);
    final textColor = isSolid ? Colors.white : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: textColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
