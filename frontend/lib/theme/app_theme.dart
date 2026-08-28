import 'package:flutter/material.dart';

/// Centralized Premium Dark-Mode Design System for WhereIsMyBus
class AppTheme {
  // ── Palette: Dark Canvas & Surface Hierarchy ─────────────────────────
  static const Color bgDark = Color(0xFF080C14); // Deepest dark navy/charcoal canvas
  static const Color surfaceLayer1 = Color(0xFF0F172A); // Primary dark surface (cards, containers)
  static const Color surfaceLayer2 = Color(0xFF162238); // Elevated surface (headers, modal sheets)
  static const Color surfaceLayer3 = Color(0xFF1E2E4A); // Interactive / floating elevated surface
  static const Color surfaceGlass = Color(0xCC0F172A); // Frosted dark glass overlay

  // ── Palette: Brand Accents ──────────────────────────────────────────
  static const Color primaryBlue = Color(0xFF3B82F6); // Electric Blue
  static const Color primaryBlueHover = Color(0xFF2563EB); // Deep Electric Blue
  static const Color primaryBlueLight = Color(0xFF60A5FA); // Light Blue Accent
  static const Color primaryBlueGlow = Color(0x333B82F6); // Ambient blue glow
  static const Color accentIndigo = Color(0xFF6366F1); // Indigo Accent
  static const Color accentPurple = Color(0xFF8B5CF6); // Modern Purple Accent
  static const Color accentCyan = Color(0xFF06B6D4); // Cyan Accent

  // ── Palette: Text Hierarchy ─────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF8FAFC); // Near-white (Slate 50)
  static const Color textSecondary = Color(0xFF94A3B8); // Muted slate (Slate 400)
  static const Color textMuted = Color(0xFF64748B); // Slate 500
  static const Color textTertiary = Color(0xFF475569); // Slate 600

  // ── Palette: Borders & Dividers ─────────────────────────────────────
  static const Color borderSubtle = Color(0xFF1E293B); // Slate 800
  static const Color borderMedium = Color(0xFF334155); // Slate 700
  static const Color borderLight = Color(0xFF475569); // Slate 600
  static const Color borderAccent = Color(0x4D3B82F6); // Subtle electric blue border

  // ── Palette: Status Colors (Dark Mode Harmonized) ────────────────────
  // LIVE / Moving / Active (Emerald)
  static const Color statusLive = Color(0xFF10B981);
  static const Color statusLiveBg = Color(0x1F10B981); // 12% opacity
  static const Color statusLiveBorder = Color(0x4D10B981); // 30% opacity
  static const Color statusLiveGlow = Color(0x4010B981);

  // STOPPED / Waiting / Idling (Amber)
  static const Color statusStopped = Color(0xFFF59E0B);
  static const Color statusStoppedBg = Color(0x1FF59E0B);
  static const Color statusStoppedBorder = Color(0x4DF59E0B);

  // STALE / Offline / Warning (Red/Coral)
  static const Color statusOffline = Color(0xFFEF4444);
  static const Color statusOfflineBg = Color(0x1FEF4444);
  static const Color statusOfflineBorder = Color(0x4DEF4444);

  // ── Spacing Tokens (8px grid system) ────────────────────────────────
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space14 = 14.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;

  // ── Corner Radii ────────────────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusCard = 16.0;
  static const double radiusSurface = 20.0;
  static const double radiusSheet = 24.0;
  static const double radiusPill = 999.0;

  // ── Layout Max Width Constraints ────────────────────────────────────
  static const double maxContentWidth = 920.0;
  static const double maxTabletWidth = 1140.0;

  // ── Reusable Component Decorators ───────────────────────────────────

  /// Layered Dark Card Decoration
  static BoxDecoration cardDecoration({
    Color background = surfaceLayer1,
    Color border = borderSubtle,
    double radius = radiusCard,
    bool elevated = true,
    Color? glowColor,
  }) {
    return BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border, width: 1),
      boxShadow: [
        if (elevated)
          const BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        if (glowColor != null)
          BoxShadow(
            color: glowColor.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
      ],
    );
  }

  /// Floating Frosted Glass / Dock Decoration
  static BoxDecoration glassDecoration({
    Color background = surfaceGlass,
    Color border = borderMedium,
    double radius = radiusPill,
    bool glow = true,
  }) {
    return BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border, width: 1),
      boxShadow: [
        const BoxShadow(
          color: Color(0x55000000),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
        if (glow)
          const BoxShadow(
            color: Color(0x1A3B82F6),
            blurRadius: 12,
            offset: Offset(0, 0),
          ),
      ],
    );
  }

  /// Bottom Sheet / Telemetry Panel Decoration
  static BoxDecoration sheetDecoration({
    Color background = surfaceLayer1,
    double radius = radiusSheet,
  }) {
    return BoxDecoration(
      color: background,
      borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
      border: const Border(
        top: BorderSide(color: borderMedium, width: 1),
        left: BorderSide(color: borderSubtle, width: 1),
        right: BorderSide(color: borderSubtle, width: 1),
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 32,
          offset: Offset(0, -8),
        ),
      ],
    );
  }

  /// Hero Header Subtle Gradient
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F172A),
      Color(0xFF080C14),
    ],
  );

  /// Electric Blue Accent Gradient (for Hero Action Buttons)
  static const LinearGradient accentButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3B82F6),
      Color(0xFF2563EB),
    ],
  );

  /// ETA Card Dark Mesh Gradient
  static const LinearGradient etaHeroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF121E36),
      Color(0xFF0F172A),
    ],
  );

  // ── Material 3 Dark Theme ────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: accentPurple,
        surface: surfaceLayer1,
        onSurface: textPrimary,
        onPrimary: Colors.white,
        outline: borderMedium,
        error: statusOffline,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLayer1,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      dividerTheme: const DividerThemeData(
        color: borderSubtle,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
