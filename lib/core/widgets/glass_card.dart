import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Solid white card surface used across the app (name kept for compatibility).
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final bool hasGlow;
  final bool blur;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius = 20.0,
    this.borderColor,
    this.backgroundColor,
    this.hasGlow = false,
    this.blur = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    Widget content = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );

    content = ClipRRect(
      borderRadius: radius,
      child: content,
    );

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: radius,
        border: Border.all(
          color: borderColor ??
              (hasGlow
                  ? AppColors.primary.withValues(alpha: 0.45)
                  : AppColors.borderLight),
        ),
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ]
            : AppColors.cardShadow,
      ),
      child: content,
    );
  }
}
