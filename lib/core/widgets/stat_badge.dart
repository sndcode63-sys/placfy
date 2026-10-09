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
    this.color = AppColors.primary,
    this.isSolid = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isSolid ? color : AppColors.tint(color, 0.12);
    final border = isSolid ? color : AppColors.tint(color, 0.30);
    final fg = isSolid ? Colors.white : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: fg,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
