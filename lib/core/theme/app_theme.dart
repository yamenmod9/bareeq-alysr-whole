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
      // Primary - Deep Blue/Black for main actions
      primary: Color(0xFF1A237E),  // Deep indigo blue
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFE8EAF6),  // Light indigo container
      onPrimaryContainer: Color(0xFF000051),
      
      // Secondary - Professional gray-blue
      secondary: Color(0xFF455A64),  // Blue gray
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFCFD8DC),  // Light blue gray
      onSecondaryContainer: Color(0xFF263238),
      
      // Tertiary - Fresh teal/green for success states
      tertiary: Color(0xFF00897B),  // Teal
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFB2DFDB),  // Light teal
      onTertiaryContainer: Color(0xFF004D40),
      
      // Error - Clear red for errors
      error: Color(0xFFD32F2F),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFCDD2),
      onErrorContainer: Color(0xFFB71C1C),
      
      // Surface - Clean white/gray backgrounds
      surface: Color(0xFFFAFAFA),  // Very light gray
      onSurface: Color(0xFF212121),  // Near black for text
      surfaceContainerLowest: Color(0xFFFFFFFF),  // Pure white
      surfaceContainerLow: Color(0xFFF5F5F5),  // Light gray
      surfaceContainer: Color(0xFFEEEEEE),  // Medium light gray
      surfaceContainerHigh: Color(0xFFE0E0E0),  // Medium gray
      surfaceContainerHighest: Color(0xFFD6D6D6),  // Darker gray
      surfaceDim: Color(0xFFBDBDBD),
      onSurfaceVariant: Color(0xFF616161),  // Medium dark gray
      outline: Color(0xFF9E9E9E),  // Gray for borders
      outlineVariant: Color(0xFFE0E0E0),  // Light gray for subtle borders
    );

    return ThemeData(
      useMaterial3: true,
      textTheme: textTheme,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      pageTransitionsTheme: _pageTransitions,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: scheme.primary.withValues(alpha: 0.05),
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        color: scheme.surfaceContainerLowest,
        shadowColor: scheme.shadow.withValues(alpha: 0.08),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.3)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        selectedColor: scheme.primaryContainer,
        secondarySelectedColor: scheme.tertiaryContainer,
        side: BorderSide.none,
        labelStyle: textTheme.labelMedium?.copyWith(color: scheme.onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        selectedIconTheme: IconThemeData(color: scheme.primary, size: 24),
        selectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 24),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelSmall),
        elevation: 3,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        floatingLabelStyle: textTheme.labelMedium?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w600,
        ),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        prefixStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
        suffixStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
        hintStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: scheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: scheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: scheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: scheme.error,
            width: 2,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.3)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 2,
          shadowColor: scheme.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.5), width: 1.5),
          backgroundColor: scheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.tertiary,
        foregroundColor: scheme.onTertiary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primaryContainer,
        circularTrackColor: scheme.primaryContainer,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(scheme.surfaceContainerLow),
        dataRowColor: WidgetStatePropertyAll(scheme.surfaceContainerLowest),
        headingTextStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onSurface,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w700,
        ),
        dataTextStyle: textTheme.bodySmall?.copyWith(color: scheme.onSurface),
        dividerThickness: 1,
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
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
