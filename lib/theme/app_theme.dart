import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the application.
/// Implements Slick Black & Yellow design approach optimized for productivity
class AppTheme {
  AppTheme._();

  // Black & Yellow Color Palette
  static const Color primaryLight = Color(0xFFFFC107); // Vibrant yellow
  static const Color primaryDark =
      Color(0xFFFFD54F); // Lighter yellow for dark theme
  static const Color secondaryLight = Color(0xFF424242); // Dark gray
  static const Color secondaryDark =
      Color(0xFF616161); // Lighter gray for dark theme

  static const Color successLight = Color(0xFF4CAF50); // Green
  static const Color successDark = Color(0xFF66BB6A); // Lighter green
  static const Color warningLight = Color(0xFFFF9800); // Orange
  static const Color warningDark = Color(0xFFFFB74D); // Lighter orange
  static const Color errorLight = Color(0xFFDC2626); // Red
  static const Color errorDark = Color(0xFFEF4444); // Lighter red

  static const Color surfaceLight = Color(0xFF000000); // Pure black
  static const Color surfaceDark = Color(0xFF121212); // Material dark
  static const Color backgroundLight =
      Color(0xFF0D0D0D); // Slightly lighter black
  static const Color backgroundDark = Color(0xFF181818); // Darker material

  static const Color textPrimaryLight =
      Color(0xFFFFC107); // Yellow text on black
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // White text
  static const Color textSecondaryLight = Color(0xFFB0B0B0); // Light gray
  static const Color textSecondaryDark = Color(0xFFE0E0E0); // Lighter gray

  static const Color accentLight = Color(0xFFFFEB3B); // Light yellow accent
  static const Color accentDark = Color(0xFFFFF59D); // Very light yellow

  // Card and surface variations
  static const Color cardLight = Color(0xFF1A1A1A); // Dark card on black
  static const Color cardDark = Color(0xFF2A2A2A); // Lighter card for dark mode
  static const Color dialogLight = Color(0xFF1A1A1A);
  static const Color dialogDark = Color(0xFF2A2A2A);

  // Shadow and divider colors
  static const Color shadowLight = Color(0x33FFC107); // Yellow shadow
  static const Color shadowDark = Color(0x44FFFFFF); // White shadow for dark
  static const Color dividerLight = Color(0xFF333333); // Dark divider
  static const Color dividerDark = Color(0xFF444444); // Lighter divider

  // Text emphasis levels
  static const Color textHighEmphasisLight = Color(0xFFFFC107); // Yellow
  static const Color textMediumEmphasisLight = Color(0xFFE0E0E0); // Light gray
  static const Color textDisabledLight = Color(0xFF757575); // Disabled gray

  static const Color textHighEmphasisDark = Color(0xFFFFFFFF); // White
  static const Color textMediumEmphasisDark = Color(0xFFE0E0E0); // Light gray
  static const Color textDisabledDark = Color(0xFF9E9E9E); // Disabled gray

  /// Light theme (actually dark with yellow accents)
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.dark, // Using dark brightness for black theme
    colorScheme: ColorScheme.dark(
      brightness: Brightness.dark,
      primary: primaryLight,
      onPrimary: Colors.black,
      primaryContainer: primaryLight.withAlpha(51),
      onPrimaryContainer: Colors.black,
      secondary: secondaryLight,
      onSecondary: primaryLight,
      secondaryContainer: secondaryLight.withAlpha(51),
      onSecondaryContainer: primaryLight,
      tertiary: accentLight,
      onTertiary: Colors.black,
      tertiaryContainer: accentLight.withAlpha(51),
      onTertiaryContainer: Colors.black,
      error: errorLight,
      onError: Colors.white,
      surface: surfaceLight,
      onSurface: textPrimaryLight,
      onSurfaceVariant: textSecondaryLight,
      outline: dividerLight,
      outlineVariant: dividerLight.withAlpha(128),
      shadow: shadowLight,
      scrim: Colors.black.withAlpha(179),
      inverseSurface: Colors.white,
      onInverseSurface: Colors.black,
      inversePrimary: Colors.black,
    ),
    scaffoldBackgroundColor: backgroundLight,
    cardColor: cardLight,
    dividerColor: dividerLight,

    // AppBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceLight,
      foregroundColor: textPrimaryLight,
      elevation: 0,
      shadowColor: shadowLight,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
        letterSpacing: -0.02,
      ),
      iconTheme: IconThemeData(
        color: textPrimaryLight,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: textPrimaryLight,
        size: 24,
      ),
    ),

    // Card theme
    cardTheme: CardTheme(
      color: cardLight,
      elevation: 4,
      shadowColor: shadowLight,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: primaryLight.withAlpha(51), width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),

    // Bottom navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceLight,
      selectedItemColor: primaryLight,
      unselectedItemColor: textSecondaryLight,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
    ),

    // FAB theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryLight,
      foregroundColor: Colors.black,
      elevation: 8,
      focusElevation: 12,
      hoverElevation: 12,
      highlightElevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: primaryLight,
        elevation: 4,
        shadowColor: shadowLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        side: BorderSide(color: primaryLight, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // Typography
    textTheme: _buildTextTheme(isLight: true),

    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      fillColor: cardLight,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryLight.withAlpha(102), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: dividerLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: errorLight, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: errorLight, width: 2),
      ),
      labelStyle: GoogleFonts.inter(
        color: textSecondaryLight,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: GoogleFonts.inter(
        color: textDisabledLight,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      errorStyle: GoogleFonts.inter(
        color: errorLight,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Interactive elements
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return Colors.grey.shade600;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight.withAlpha(102);
        }
        return Colors.grey.shade700;
      }),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.black),
      side: BorderSide(color: primaryLight, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primaryLight,
      linearTrackColor: primaryLight.withAlpha(51),
      circularTrackColor: primaryLight.withAlpha(51),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: cardLight,
      contentTextStyle: GoogleFonts.inter(
        color: textPrimaryLight,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      actionTextColor: primaryLight,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: primaryLight.withAlpha(102), width: 1),
      ),
      elevation: 8,
    ),

    // Dialog theme
    dialogTheme: DialogTheme(
      backgroundColor: dialogLight,
      elevation: 8,
      shadowColor: shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: primaryLight.withAlpha(102), width: 1),
      ),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondaryLight,
      ),
    ),
  );

  /// Dark theme (same as light for this black/yellow design)
  static ThemeData darkTheme = lightTheme;

  /// Helper method to build text theme using Inter font family
  static TextTheme _buildTextTheme({required bool isLight}) {
    final Color textHighEmphasis = textHighEmphasisLight;
    final Color textMediumEmphasis = textMediumEmphasisLight;
    final Color textDisabled = textDisabledLight;

    return TextTheme(
      // Display styles
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: textHighEmphasis,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: textHighEmphasis,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: textHighEmphasis,
        letterSpacing: 0,
        height: 1.22,
      ),

      // Headline styles
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: textHighEmphasis,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textHighEmphasis,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textHighEmphasis,
        letterSpacing: 0,
        height: 1.33,
      ),

      // Title styles
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textHighEmphasis,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textHighEmphasis,
        letterSpacing: 0.15,
        height: 1.50,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textHighEmphasis,
        letterSpacing: 0.1,
        height: 1.43,
      ),

      // Body styles
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textMediumEmphasis,
        letterSpacing: 0.5,
        height: 1.50,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textMediumEmphasis,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textDisabled,
        letterSpacing: 0.4,
        height: 1.33,
      ),

      // Label styles
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textHighEmphasis,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textMediumEmphasis,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: textDisabled,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }

  /// Helper methods
  static Color getSuccessColor(bool isLight) {
    return isLight ? successLight : successDark;
  }

  static Color getWarningColor(bool isLight) {
    return isLight ? warningLight : warningDark;
  }

  static Color getAccentColor(bool isLight) {
    return isLight ? accentLight : accentDark;
  }
}
