import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'common_widgets.dart';
import 'custom_button.dart';

/// Consistent dialog: icon, title, message, optional body and actions.
class GlassDialog extends StatelessWidget {
  final IconData? icon;
  final Color iconColor;
  final String title;
  final String? message;
  final Widget? child;
  final List<Widget> actions;

  const GlassDialog({
    super.key,
    this.icon,
    this.iconColor = AppColors.primary,
    required this.title,
    this.message,
    this.child,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (icon != null)
                Center(child: IconBadge(icon: icon!, color: iconColor, size: 56)),
              if (icon != null) const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: AppColors.textPrimary,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (child != null) ...[
                const SizedBox(height: 16),
                child!,
              ],
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 22),
                Row(
                  children: [
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(child: actions[i]),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet surface with drag handle.
class GlassSheet extends StatelessWidget {
  final Widget child;
  const GlassSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: mq.size.height * 0.92),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceSheet,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: const [
            BoxShadow(color: Color(0x1F0F172A), blurRadius: 32),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              10,
              20,
              20 + mq.viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderSubtle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<T?> showGlassSheet<T>(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: builder,
  );
}

/// Small helper for dialog buttons.
Widget dialogButton(
  String text,
  VoidCallback onPressed, {
  bool outlined = false,
  Color? color,
}) {
  return CustomButton(
    text: text,
    onPressed: onPressed,
    isOutlined: outlined,
    backgroundColor: outlined ? null : color,
    height: 48,
    borderRadius: 14,
  );
}
