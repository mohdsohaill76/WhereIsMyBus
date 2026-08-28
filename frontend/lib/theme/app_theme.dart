import 'package:flutter/material.dart';

/// Centralized Premium Dark-First Design System for WhereIsMyBus V2
/// Inspired by modern high-craft mobility and developer platforms.
class AppTheme {
  // ── 1. Color Palette: Dark Canvas & Surface Hierarchy ────────────────────
  static const Color bgDark = Color(0xFF080C14); // Deepest dark navy/charcoal canvas
  static const Color bgSubtle = Color(0xFF0B111E); // Secondary background canvas
  static const Color surface0 = Color(0xFF080C14);
  static const Color surfaceLayer1 = Color(0xFF0F172A); // Primary dark surface (cards, containers)
  static const Color surfaceLayer2 = Color(0xFF162238); // Elevated surface (headers, sheets)
  static const Color surfaceLayer3 = Color(0xFF1E2E4A); // Interactive / floating elevated surface
  static const Color surfaceInteractive = Color(0xFF243656); // Hovered / focused surface
  static const Color surfaceGlass = Color(0xCC0F172A); // Frosted dark glass overlay
  static const Color bgSurfaceCard = Color(0xFF0F172A); // Card background token

  // ── 2. Color Palette: Brand & Accents ────────────────────────────────────
  static const Color primaryBlue = Color(0xFF3B82F6); // Electric Blue
  static const Color primaryBlueHover = Color(0xFF2563EB); // Deep Electric Blue
  static const Color primaryBlueLight = Color(0xFF60A5FA); // Light Blue Accent
  static const Color primaryBlueGlow = Color(0x333B82F6); // Ambient blue glow
  static const Color accentIndigo = Color(0xFF6366F1); // Indigo Accent
  static const Color accentPurple = Color(0xFF8B5CF6); // Modern Purple Accent
  static const Color accentCyan = Color(0xFF06B6D4); // Cyan Accent
  static const Color accentAmber = Color(0xFFF59E0B); // Amber Accent

  // ── 3. Color Palette: Text Hierarchy ───────────────────────────────────
  static const Color textPrimary = Color(0xFFF8FAFC); // Near-white (Slate 50)
  static const Color textSecondary = Color(0xFF94A3B8); // Muted slate (Slate 400)
  static const Color textMuted = Color(0xFF64748B); // Slate 500
  static const Color textTertiary = Color(0xFF475569); // Slate 600

  // ── 4. Color Palette: Borders & Dividers ───────────────────────────────
  static const Color borderSubtle = Color(0xFF1E293B); // Slate 800
  static const Color borderMedium = Color(0xFF334155); // Slate 700
  static const Color borderLight = Color(0xFF475569); // Slate 600
  static const Color borderAccent = Color(0x4D3B82F6); // Subtle electric blue border

  // ── 5. Color Palette: Status Colors (Dark-Mode Harmonized) ─────────────
  // LIVE / Moving / Active (Emerald)
  static const Color statusLive = Color(0xFF10B981);
  static const Color statusLiveBg = Color(0x1F10B981); // ~12% opacity
  static const Color statusLiveBorder = Color(0x4D10B981); // ~30% opacity
  static const Color statusLiveGlow = Color(0x4010B981);

  // STOPPED / Waiting / Warning (Amber)
  static const Color statusStopped = Color(0xFFF59E0B);
  static const Color statusStoppedBg = Color(0x1FF59E0B);
  static const Color statusStoppedBorder = Color(0x4DF59E0B);
  static const Color statusWarning = Color(0xFFF59E0B);

  // STALE / Offline / Error (Coral Red)
  static const Color statusOffline = Color(0xFFEF4444);
  static const Color statusOfflineBg = Color(0x1FEF4444);
  static const Color statusOfflineBorder = Color(0x4DEF4444);
  static const Color statusError = Color(0xFFEF4444);
  static const Color statusStale = Color(0xFFEF4444);

  // ── 6. Spacing Tokens (Consistent 4px/8px Grid System) ──────────────────
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
  static const double space36 = 36.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;

  // ── 7. Corner Radii ────────────────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusCard = 16.0;
  static const double radiusSurface = 20.0;
  static const double radiusSheet = 24.0;
  static const double radiusPill = 999.0;

  // ── Button Styles ───────────────────────────────────────────────────────
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        elevation: 0,
      );

  // ── 8. Layout Constraints (Preserved for backwards compatibility) ───────
  static const double maxContentWidth = 960.0;
  static const double maxTabletWidth = 1140.0;

  // ── 9. Typography Hierarchy Tokens ─────────────────────────────────────
  static const TextStyle display = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.9,
    color: textPrimary,
    height: 1.15,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    color: textPrimary,
    height: 1.2,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    color: textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
    color: textSecondary,
    height: 1.45,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: textMuted,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    color: textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    color: textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.4,
    color: textTertiary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textTertiary,
  );

  // ── 10. Shadow & Elevation Tokens ──────────────────────────────────────
  static const List<BoxShadow> shadowSubtle = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowElevated = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> shadowFloating = [
    BoxShadow(
      color: Color(0x55000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  // ── 11. Gradients ──────────────────────────────────────────────────────
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F172A),
      Color(0xFF080C14),
    ],
  );

  static const LinearGradient accentButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3B82F6),
      Color(0xFF2563EB),
    ],
  );

  static const LinearGradient etaHeroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF121E36),
      Color(0xFF0F172A),
    ],
  );

  // ── 12. Reusable Component Decorators ──────────────────────────────────

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

  /// Text Field / Input Decoration Wrapper
  static InputDecoration searchInputDecoration({
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: textTertiary,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: surfaceLayer1,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusCard),
        borderSide: const BorderSide(color: borderMedium, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusCard),
        borderSide: const BorderSide(color: borderMedium, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusCard),
        borderSide: const BorderSide(color: primaryBlue, width: 1.5),
      ),
    );
  }

  // ── 13. Material 3 Dark Theme Configuration ───────────────────────────
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
      cardTheme: CardThemeData(
        color: surfaceLayer1,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: surfaceLayer3,
          borderRadius: BorderRadius.circular(radiusSm),
          border: Border.all(color: borderMedium),
        ),
        textStyle: const TextStyle(
          color: textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
