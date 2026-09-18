import 'package:flutter/material.dart';

class AppTheme {
  static const purple = Color(0xFF461D7C);
  static const gold = Color(0xFFFDD023);
  static const background = Color(0xFFF7F7FA);
  static const ink = Color(0xFF211B2A);

  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: purple,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFEADFF5),
      onPrimaryContainer: purple,
      secondary: gold,
      onSecondary: ink,
      secondaryContainer: Color(0xFFFFF2B8),
      onSecondaryContainer: ink,
      surface: Colors.white,
      onSurface: ink,
      surfaceContainerLow: background,
      surfaceContainerHighest: Color(0xFFE9E7EE),
      outline: Color(0xFF79717F),
      outlineVariant: Color(0xFFDDD9E3),
    );

    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: background,
      textTheme: base.textTheme.copyWith(
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          color: purple,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          color: purple,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          color: purple,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: base.textTheme.titleSmall?.copyWith(
          color: purple,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: purple,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFDDD9E3)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: scheme.primaryContainer,
        elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurface,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurface,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
          );
        }),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: purple,
        foregroundColor: Colors.white,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: scheme.secondaryContainer,
        labelStyle: const TextStyle(color: ink),
        iconTheme: const IconThemeData(color: purple),
        side: BorderSide.none,
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: const WidgetStatePropertyAll(Colors.white),
        elevation: const WidgetStatePropertyAll(0),
        side: const WidgetStatePropertyAll(
          BorderSide(color: Color(0xFFDDD9E3)),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: purple, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFDDD9E3)),
    );
  }
}
