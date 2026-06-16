import 'package:flutter/material.dart';

class AppColors {
  // ── Content backgrounds (warm linen, not white, not beige-gold) ───────────
  static const Color bg        = Color(0xFFF7F5F2);   // warm linen
  static const Color bgSubtle  = Color(0xFFEFECE6);   // slightly deeper
  static const Color surface   = Color(0xFFFFFFFF);
  static const Color surfaceAlt= Color(0xFFF3F0EA);

  // ── Sidebar — deep olive/slate, NOT black ─────────────────────────────────
  static const Color sidebarBg     = Color(0xFF1E2A1E);  // deep forest green
  static const Color sidebarHover  = Color(0xFF253025);
  static const Color sidebarBorder = Color(0xFF2E3D2E);
  static const Color sidebarText   = Color(0xFFB8C9B0);  // muted sage

  // ── Accent — rich olive gold ───────────────────────────────────────────────
  static const Color accent      = Color(0xFF7D9B4E);  // olive green
  static const Color accentWarm  = Color(0xFFB8943F);  // warm gold (buttons)
  static const Color accentLight = Color(0xFFEDF3E0);  // very light olive

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success      = Color(0xFF3A7D44);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error        = Color(0xFFB94040);
  static const Color errorLight   = Color(0xFFFDECEA);
  static const Color warning      = Color(0xFFB7860B);
  static const Color warningLight = Color(0xFFFFF8E1);

  // ── Text — high contrast on warm bg ───────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1A1F1A);
  static const Color textSecondary = Color(0xFF4A5548);
  static const Color textMuted     = Color(0xFF8A9885);

  // ── Borders ───────────────────────────────────────────────────────────────
  static const Color border      = Color(0xFFDDD9D0);
  static const Color borderFocus = Color(0xFF7D9B4E);

  // ── Aliases so existing files compile ────────────────────────────────────
  static const Color primaryGreen  = accent;
  static const Color successGreen  = success;
  static const Color errorRed      = error;
  static const Color accentGold    = warning;
  static const Color infoBlue      = Color(0xFF31445C);
  static const Color lightGreen    = successLight;
  static const Color background    = bg;
  static const Color cardBackground= surface;
  static const Color adminBg       = bg;
  static const Color adminSurface  = surface;
  static const Color adminBorder   = border;
  static const Color textMutedColor= textMuted;
  // Keep old accent alias for login button
  static const Color accentDark    = Color(0xFF5A7235);
}