import 'package:flutter/material.dart';

class AppTheme {
  // Brand & Palette
  static const Color primaryNavy = Color(0xFF0F172A);
  static const Color primaryNavyLight = Color(0xFF1E293B);
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryBlueDark = Color(0xFF1D4ED8);
  static const Color accentIndigo = Color(0xFF4F46E5);
  static const Color accentPurple = Color(0xFF7C3AED);
  static const Color bgSlate = Color(0xFFF8FAFC);
  static const Color cardSurface = Colors.white;

  // Text Colors
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textSubtle = Color(0xFF94A3B8);
  static const Color borderColor = Color(0xFFE2E8F0);

  // Status Colors (Moving / Active)
  static const Color statusLiveBg = Color(0xFFECFDF5);
  static const Color statusLiveText = Color(0xFF047857);
  static const Color statusLiveDot = Color(0xFF10B981);
  static const Color statusLiveBorder = Color(0xFFA7F3D0);

  // Status Colors (Stopped)
  static const Color statusStoppedBg = Color(0xFFFFFBEB);
  static const Color statusStoppedText = Color(0xFFB45309);
  static const Color statusStoppedDot = Color(0xFFF59E0B);
  static const Color statusStoppedBorder = Color(0xFFFDE68A);

  // Status Colors (Offline)
  static const Color statusOfflineBg = Color(0xFFF1F5F9);
  static const Color statusOfflineText = Color(0xFF475569);
  static const Color statusOfflineDot = Color(0xFF94A3B8);
  static const Color statusOfflineBorder = Color(0xFFCBD5E1);

  // Modern Card Decoration Helper
  static BoxDecoration cardDecoration({
    Color background = cardSurface,
    Color border = borderColor,
    double radius = 16.0,
    bool elevated = true,
  }) {
    return BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border, width: 1),
      boxShadow: elevated
          ? const [
              BoxShadow(
                color: Color(0x0A0F172A),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
              BoxShadow(
                color: Color(0x040F172A),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ]
          : null,
    );
  }

  // Floating Sheet Decoration Helper
  static BoxDecoration sheetDecoration({
    Color background = cardSurface,
    double radius = 24.0,
  }) {
    return BoxDecoration(
      color: background,
      borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1F0F172A),
          blurRadius: 24,
          offset: Offset(0, -6),
        ),
      ],
    );
  }

  // Premium Header Gradient
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F172A),
      Color(0xFF1E293B),
    ],
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgSlate,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        surface: cardSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
