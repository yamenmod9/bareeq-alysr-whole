import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _pageTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
    },
  );

  static TextTheme _textTheme(Brightness brightness) {
    final base = ThemeData(brightness: brightness).textTheme;
    final body = GoogleFonts.interTextTheme(base);
    return body.copyWith(
      headlineLarge: GoogleFonts.manrope(
        textStyle: body.headlineLarge,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.7,
      ),
      headlineMedium: GoogleFonts.manrope(
        textStyle: body.headlineMedium,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      headlineSmall: GoogleFonts.manrope(
        textStyle: body.headlineSmall,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleLarge: GoogleFonts.manrope(
        textStyle: body.titleLarge,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleMedium: GoogleFonts.manrope(
        textStyle: body.titleMedium,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: GoogleFonts.manrope(
        textStyle: body.titleSmall,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: body.bodyLarge?.copyWith(height: 1.35),
      bodyMedium: body.bodyMedium?.copyWith(height: 1.35),
      bodySmall: body.bodySmall?.copyWith(height: 1.35),
      labelLarge: body.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      labelMedium: body.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelSmall: body.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.45,
      ),
    );
  }

  static ThemeData light() {
    final textTheme = _textTheme(Brightness.light);
    final scheme = const ColorScheme.light().copyWith(
      primary: Color(0xFF000000),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF131B2E),
      onPrimaryContainer: Color(0xFFC0CAE0),
      secondary: Color(0xFF37465B),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFD5E3FC),
      onSecondaryContainer: Color(0xFF2F3C4E),
      tertiary: Color(0xFF0C9488),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFF00201D),
      onTertiaryContainer: Color(0xFF89F5E7),
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF93000A),
      surface: Color(0xFFF8F9FF),
      onSurface: Color(0xFF0B1C30),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF1F5FF),
      surfaceContainer: Color(0xFFE8F0FF),
      surfaceContainerHigh: Color(0xFFDDE9FF),
      surfaceContainerHighest: Color(0xFFD2E2FC),
      surfaceDim: Color(0xFFC8D8F2),
      onSurfaceVariant: Color(0xFF344257),
      outline: Color(0xFF76777D),
      outlineVariant: Color(0xFFB6C2D6),
    );

    return ThemeData(
      useMaterial3: true,
      textTheme: textTheme,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      pageTransitionsTheme: _pageTransitions,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surfaceContainerLowest.withValues(alpha: 0.96),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLowest,
        shadowColor: const Color(0x0F0B1C30),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        selectedColor: scheme.secondaryContainer,
        secondarySelectedColor: scheme.tertiaryContainer,
        side: BorderSide.none,
        labelStyle: textTheme.labelMedium?.copyWith(color: scheme.onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        selectedIconTheme: IconThemeData(color: scheme.tertiary),
        selectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: scheme.tertiary,
        ),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLowest.withValues(alpha: 0.82),
        indicatorColor: scheme.surfaceContainerHighest,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelSmall),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        floatingLabelStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onSurface,
        ),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        prefixStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
        suffixStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
        hintStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: scheme.primary.withValues(alpha: 0.2),
            width: 1.2,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.2)),
          backgroundColor: scheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFF89F5E7),
        foregroundColor: const Color(0xFF00201D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: const Color(0xFF89F5E7),
        linearTrackColor: scheme.surfaceContainer,
        circularTrackColor: scheme.surfaceContainer,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.24),
        thickness: 0.8,
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(scheme.surfaceContainerLow),
        dataRowColor: WidgetStatePropertyAll(scheme.surfaceContainerLowest),
        headingTextStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
          letterSpacing: 1.0,
          fontWeight: FontWeight.w700,
        ),
        dataTextStyle: textTheme.bodySmall?.copyWith(color: scheme.onSurface),
        dividerThickness: 0,
      ),
    );
  }

  static ThemeData dark() {
    final textTheme = _textTheme(Brightness.dark);
    final scheme = const ColorScheme.dark().copyWith(
      primary: const Color(0xFFEAF1FF),
      onPrimary: const Color(0xFF131B2E),
      primaryContainer: const Color(0xFF111F37),
      onPrimaryContainer: const Color(0xFFA6B1C5),
      secondary: const Color(0xFFB9C7DF),
      onSecondary: const Color(0xFF1C2B42),
      secondaryContainer: const Color(0xFF243249),
      onSecondaryContainer: const Color(0xFFD5E3FC),
      tertiary: const Color(0xFF89F5E7),
      onTertiary: const Color(0xFF00201D),
      tertiaryContainer: const Color(0xFF00201D),
      onTertiaryContainer: const Color(0xFF89F5E7),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
      surface: const Color(0xFF071219),
      onSurface: const Color(0xFFEAF1FF),
      surfaceContainerLowest: const Color(0xFF0A1825),
      surfaceContainerLow: const Color(0xFF0F1F2F),
      surfaceContainer: const Color(0xFF132536),
      surfaceContainerHigh: const Color(0xFF1A2E42),
      surfaceContainerHighest: const Color(0xFF243A52),
      surfaceDim: const Color(0xFF091624),
      onSurfaceVariant: const Color(0xFFA4B5CB),
      outline: const Color(0xFF6E8097),
      outlineVariant: const Color(0xFF34475C),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: textTheme,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      pageTransitionsTheme: _pageTransitions,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface.withValues(alpha: 0.86),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainer,
        selectedColor: scheme.surfaceContainerHighest,
        side: BorderSide.none,
        labelStyle: textTheme.labelMedium?.copyWith(color: scheme.onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        selectedIconTheme: IconThemeData(color: scheme.tertiary),
        selectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: scheme.tertiary,
        ),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.surfaceContainerHighest,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelSmall),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer,
        floatingLabelStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        hintStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: scheme.primary.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF89F5E7),
          foregroundColor: const Color(0xFF00201D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.35),
          ),
          backgroundColor: scheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(scheme.surfaceContainer),
        dataRowColor: WidgetStatePropertyAll(scheme.surfaceContainerLow),
        headingTextStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
          letterSpacing: 1.0,
          fontWeight: FontWeight.w700,
        ),
        dataTextStyle: textTheme.bodySmall?.copyWith(color: scheme.onSurface),
        dividerThickness: 0,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.3),
        thickness: 0.8,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.tertiary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: scheme.surfaceContainerHighest,
      ),
    );
  }
}
