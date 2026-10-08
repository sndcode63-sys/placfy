import 'package:flutter/material.dart';

/// Modern, Vibrant Color Palette for Placfy
class AppColors {
  // Brand Primary (Modern Gradient Purple)
  static const Color brandPurple = Color(0xFF6366F1);
  static const Color brandPurpleLight = Color(0xFFF5F3FF);
  static const Color brandPurpleDark = Color(0xFF4F46E5);
  static const Color brandGradientStart = Color(0xFF6366F1);
  static const Color brandGradientEnd = Color(0xFF8B5CF6);

  // Backgrounds (Modern Light Mode)
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF3F4F6);
  static const Color surfaceHover = Color(0xFFE5E7EB);

  // Borders & Dividers
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderSubtle = Color(0xFFD1D5DB);

  // Typography (Modern Dark Gray)
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Status & Accent Badges (Modern Vibrant Colors)
  static const Color statusSuccess = Color(0xFF10B981);
  static const Color statusSuccessBg = Color(0xFFD1FAE5);
  static const Color statusSuccessBorder = Color(0xFF6EE7B7);

  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusWarningBg = Color(0xFFFEF3C7);
  static const Color statusWarningBorder = Color(0xFFFCD34D);

  static const Color statusError = Color(0xFFEF4444);
  static const Color statusErrorBg = Color(0xFFFEE2E2);
  static const Color statusErrorBorder = Color(0xFFFCA5A5);

  static const Color statusInfo = Color(0xFF3B82F6);
  static const Color statusInfoBg = Color(0xFFDBEAFE);
  static const Color statusInfoBorder = Color(0xFF93C5FD);

  // Additional Accents
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color accentTealBg = Color(0xFFCCFBF1);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentPinkBg = Color(0xFFFBCFE8);

  // Enhanced Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: Color(0x15000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];
}
