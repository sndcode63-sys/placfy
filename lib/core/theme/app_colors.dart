import 'package:flutter/material.dart';

/// Placfy design tokens — fully light theme.
///
/// White backgrounds, solid white cards with soft borders, slate text and a
/// blue brand accent. There are no translucent / glass surfaces any more.
///
/// Legacy names (brandPurple, surfaceCard, bgDeep, …) are kept so older
/// widgets keep compiling; they now resolve to the light palette.
class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDeep = Color(0xFF1D4ED8);
  static const Color accent = Color(0xFF0891B2);
  static const Color violet = Color(0xFF7C3AED);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB), Color(0xFF0891B2)],
  );

  // ── Backgrounds (all plain white) ────────────────────────────────────────
  static const Color bgTop = Color(0xFFFFFFFF);
  static const Color bgMid = Color(0xFFFFFFFF);
  static const Color bgDeep = Color(0xFFFFFFFF);

  // ── Surfaces (always solid) ──────────────────────────────────────────────
  static const Color surfaceSheet = Color(0xFFFFFFFF);
  static const Color surfaceField = Color(0xFFF1F5F9);

  // ── Legacy aliases ───────────────────────────────────────────────────────
  static const Color brandPurple = primary;
  static const Color brandPurpleLight = Color(0xFFEFF6FF);
  static const Color brandPurpleDark = primaryDeep;
  static const Color brandGradientStart = Color(0xFF3B82F6);
  static const Color brandGradientEnd = Color(0xFF06B6D4);

  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF1F5F9);
  static const Color surfaceHover = Color(0xFFE2E8F0);

  // ── Borders ──────────────────────────────────────────────────────────────
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFCBD5E1);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF64748B);

  // ── Status (solid tints, readable on white) ──────────────────────────────
  static const Color statusSuccess = Color(0xFF059669);
  static const Color statusSuccessBg = Color(0xFFD1FAE5);
  static const Color statusSuccessBorder = Color(0xFFA7F3D0);

  static const Color statusWarning = Color(0xFFD97706);
  static const Color statusWarningBg = Color(0xFFFEF3C7);
  static const Color statusWarningBorder = Color(0xFFFDE68A);

  static const Color statusError = Color(0xFFDC2626);
  static const Color statusErrorBg = Color(0xFFFEE2E2);
  static const Color statusErrorBorder = Color(0xFFFECACA);

  static const Color statusInfo = Color(0xFF2563EB);
  static const Color statusInfoBg = Color(0xFFDBEAFE);
  static const Color statusInfoBorder = Color(0xFFBFDBFE);

  static const Color accentTeal = Color(0xFF0D9488);
  static const Color accentTealBg = Color(0xFFCCFBF1);
  static const Color accentPink = Color(0xFFDB2777);
  static const Color accentPinkBg = Color(0xFFFCE7F3);

  // ── Shadows (soft, light) ────────────────────────────────────────────────
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x140F172A),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: Color(0x1F0F172A),
      blurRadius: 28,
      offset: Offset(0, 10),
    ),
  ];

  /// Scrim behind dialogs / bottom sheets.
  static const Color scrim = Color(0x520F172A);

  /// Solid tint of [color] on white (use instead of a translucent fill).
  static Color tint(Color color, [double strength = 0.12]) =>
      Color.alphaBlend(color.withValues(alpha: strength), Colors.white);
}
