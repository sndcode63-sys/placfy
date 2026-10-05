import 'package:flutter/material.dart';

/// Clean, Minimalist Light Mode Color Palette for Placfy
class AppColors {
  // Brand Primary (Matches official Placfy logo)
  static const Color brandPurple = Color(0xFF5452EC);
  static const Color brandPurpleLight = Color(0xFFEEF2FF);
  static const Color brandPurpleDark = Color(0xFF4338CA);

  // Backgrounds (Clean SaaS Light Mode)
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceWhite = Color(0xFFFFFFFF);    // Pure White
  static const Color surfaceCard = Color(0xFFFFFFFF);     // Pure White
  static const Color surfaceSubtle = Color(0xFFF1F5F9);   // Slate 100
  static const Color surfaceHover = Color(0xFFE2E8F0);    // Slate 200

  // Borders & Dividers
  static const Color borderLight = Color(0xFFE2E8F0);     // Slate 200
  static const Color borderSubtle = Color(0xFFCBD5E1);    // Slate 300

  // Typography (Deep Charcoal / Slate for maximum readability)
  static const Color textPrimary = Color(0xFF0F172A);     // Slate 900
  static const Color textSecondary = Color(0xFF475569);   // Slate 600
  static const Color textMuted = Color(0xFF94A3B8);       // Slate 400

  // Status & Accent Badges (Soft Pastel backgrounds with high-contrast text)
  static const Color statusSuccess = Color(0xFF059669);
  static const Color statusSuccessBg = Color(0xFFECFDF5);
  static const Color statusSuccessBorder = Color(0xFFA7F3D0);

  static const Color statusWarning = Color(0xFFD97706);
  static const Color statusWarningBg = Color(0xFFFFFBEB);
  static const Color statusWarningBorder = Color(0xFFFDE68A);

  static const Color statusError = Color(0xFFDC2626);
  static const Color statusErrorBg = Color(0xFFFEF2F2);
  static const Color statusErrorBorder = Color(0xFFFECACA);

  static const Color statusInfo = Color(0xFF2563EB);
  static const Color statusInfoBg = Color(0xFFEFF6FF);
  static const Color statusInfoBorder = Color(0xFFBFDBFE);

  // Additional Accents
  static const Color accentTeal = Color(0xFF0D9488);
  static const Color accentTealBg = Color(0xFFF0FDFA);

  // Subtle clean shadow
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
}
