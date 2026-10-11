import 'package:flutter/material.dart';

class AppColors {
  static const Color backgroundDark = Color(0xFF020914);
  static const Color surfaceDark = Color(0xFF071322);
  static const Color cardDark = Color(0xFF0D1F32);
  static const Color cardBorderDark = Color(0xFF162E48);

  static const Color primary = Color(0xFF00F2FE);
  static const Color primaryGradientEnd = Color(0xFF2DD4BF);
  static const Color secondary = Color(0xFF38BDF8);
  static const Color accent = Color(0xFF64FFDA);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xD8FFFFFF);
  static const Color textMuted = Color(0x80FFFFFF);

  static const Color success = Color(0xFF2DD4BF);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);
  static const Color info = Color(0xFF38BDF8);
}

class AppTheme {
  static const String dark = 'Dark';
  static const String light = 'Light';
  static const String cyberpunk = 'Cyberpunk Neon';
  static const String emerald = 'Emerald Bio';
  static const String oceanic = 'Oceanic Deep';
  static const String solar = 'Solar Flare';
  static const String amethyst = 'Amethyst Purple';

  static const List<Map<String, String>> themeOptions = [
    {'key': dark, 'label': 'Dark Scientific Cyan'},
    {'key': light, 'label': 'Light Laboratory Mode'},
    {'key': cyberpunk, 'label': 'Cyberpunk Neon Mode'},
    {'key': emerald, 'label': 'Emerald Bio Mode'},
    {'key': oceanic, 'label': 'Oceanic Deep Mode'},
    {'key': solar, 'label': 'Solar Flare Mode'},
    {'key': amethyst, 'label': 'Amethyst Purple Mode'},
  ];

  static ThemeData getTheme(String themeName) {
    switch (themeName) {
      case light:
        return _buildTheme(
          brightness: Brightness.light,
          background: const Color(0xFFF1F5F9),
          surface: const Color(0xFFFFFFFF),
          card: const Color(0xFFE2E8F0),
          cardBorder: const Color(0xFFCBD5E1),
          primary: const Color(0xFF0284C7),
          secondary: const Color(0xFF0D9488),
          accent: const Color(0xFF2563EB),
          textPrimary: const Color(0xFF0F172A),
          textSecondary: const Color(0xFF334155),
        );
      case cyberpunk:
        return _buildTheme(
          brightness: Brightness.dark,
          background: const Color(0xFF090314),
          surface: const Color(0xFF140824),
          card: const Color(0xFF1D0C36),
          cardBorder: const Color(0xFFF43F5E),
          primary: const Color(0xFFF43F5E),
          secondary: const Color(0xFF00F2FE),
          accent: const Color(0xFFA855F7),
          textPrimary: Colors.white,
          textSecondary: const Color(0xFFE2E8F0),
        );
      case emerald:
        return _buildTheme(
          brightness: Brightness.dark,
          background: const Color(0xFF02140D),
          surface: const Color(0xFF062418),
          card: const Color(0xFF0B3826),
          cardBorder: const Color(0xFF10B981),
          primary: const Color(0xFF10B981),
          secondary: const Color(0xFF34D399),
          accent: const Color(0xFF6EE7B7),
          textPrimary: Colors.white,
          textSecondary: const Color(0xFFD1FAE5),
        );
      case oceanic:
        return _buildTheme(
          brightness: Brightness.dark,
          background: const Color(0xFF031024),
          surface: const Color(0xFF071C3D),
          card: const Color(0xFF0D2A5B),
          cardBorder: const Color(0xFF38BDF8),
          primary: const Color(0xFF38BDF8),
          secondary: const Color(0xFF60A5FA),
          accent: const Color(0xFF818CF8),
          textPrimary: Colors.white,
          textSecondary: const Color(0xFFE0F2FE),
        );
      case solar:
        return _buildTheme(
          brightness: Brightness.dark,
          background: const Color(0xFF140D02),
          surface: const Color(0xFF241806),
          card: const Color(0xFF3B270A),
          cardBorder: const Color(0xFFF59E0B),
          primary: const Color(0xFFF59E0B),
          secondary: const Color(0xFFFBBF24),
          accent: const Color(0xFFF97316),
          textPrimary: Colors.white,
          textSecondary: const Color(0xFFFEF3C7),
        );
      case amethyst:
        return _buildTheme(
          brightness: Brightness.dark,
          background: const Color(0xFF10031A),
          surface: const Color(0xFF1C072E),
          card: const Color(0xFF2B0C47),
          cardBorder: const Color(0xFFC084FC),
          primary: const Color(0xFFC084FC),
          secondary: const Color(0xFFE879F9),
          accent: const Color(0xFFA855F7),
          textPrimary: Colors.white,
          textSecondary: const Color(0xFFF3E8FF),
        );
      case dark:
      default:
        return _buildTheme(
          brightness: Brightness.dark,
          background: const Color(0xFF020914),
          surface: const Color(0xFF071322),
          card: const Color(0xFF0D1F32),
          cardBorder: const Color(0xFF162E48),
          primary: const Color(0xFF00F2FE),
          secondary: const Color(0xFF2DD4BF),
          accent: const Color(0xFF64FFDA),
          textPrimary: Colors.white,
          textSecondary: const Color(0xD8FFFFFF),
        );
    }
  }

  static ThemeData get darkTheme => getTheme(dark);

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color card,
    required Color cardBorder,
    required Color primary,
    required Color secondary,
    required Color accent,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: isDark ? const Color(0xFF020914) : Colors.white,
        secondary: secondary,
        onSecondary: isDark ? const Color(0xFF020914) : Colors.white,
        surface: surface,
        onSurface: textPrimary,
        error: const Color(0xFFF87171),
        onError: Colors.white,
      ),
      cardColor: card,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      dividerColor: cardBorder,
      textTheme: (isDark ? ThemeData.dark() : ThemeData.light()).textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        labelStyle: TextStyle(color: textSecondary),
        prefixIconColor: primary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: isDark ? const Color(0xFF020914) : Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }

  static BoxDecoration glassCardDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BoxDecoration(
      color: theme.cardColor.withValues(alpha: isDark ? 0.85 : 0.95),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.1),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          blurRadius: 16,
        ),
      ],
    );
  }
}

