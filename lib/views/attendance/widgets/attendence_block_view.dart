import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Full-page message shown instead of the check-in card when the user
/// cannot mark attendance (no policy assigned / not onboarded yet).
class AttendanceBlockedView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Future<void> Function()? onRefresh;

  const AttendanceBlockedView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final content = LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 40, color: const Color(0xFF6366F1)),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  if (onRefresh != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Pull down to refresh',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (onRefresh == null) return content;
    return RefreshIndicator(
      color: const Color(0xFF6366F1),
      onRefresh: onRefresh!,
      child: content,
    );
  }
}
