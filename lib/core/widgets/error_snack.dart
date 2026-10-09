import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Light, readable error toast: red icon, bold title, clean message.
void showErrorSnack(BuildContext context, String? title, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: AppColors.statusErrorBg,
        duration: const Duration(seconds: 5),
        content: ErrorBanner(title: title, message: message, framed: false),
      ),
    );
}

/// Reusable error block (used in snackbars and inside dialogs).
class ErrorBanner extends StatelessWidget {
  final String? title;
  final String message;
  final bool framed;
  final VoidCallback? onClose;

  const ErrorBanner({
    super.key,
    this.title,
    required this.message,
    this.framed = true,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.error_outline_rounded,
              color: AppColors.statusError, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null && title!.isNotEmpty)
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.statusError,
                  ),
                ),
              if (title != null && title!.isNotEmpty) const SizedBox(height: 2),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (onClose != null)
          GestureDetector(
            onTap: onClose,
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.close_rounded,
                  size: 18, color: AppColors.textMuted),
            ),
          ),
      ],
    );
    if (!framed) return row;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.statusErrorBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.statusErrorBorder),
      ),
      child: row,
    );
  }
}
