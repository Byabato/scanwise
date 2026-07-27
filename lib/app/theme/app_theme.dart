import 'package:flutter/material.dart';

import 'design_tokens.dart';

/// Builds the light and dark [ThemeData] from centralized design tokens.
/// Feature widgets must read colors, spacing, shape and type from these
/// themes (or the token classes) rather than hard-coding values.
abstract final class AppTheme {
  static final light = _build(
    brightness: Brightness.light,
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    surfaceVariant: AppColors.lightSurfaceVariant,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    divider: AppColors.lightDivider,
    brandPrimary: AppColors.brandPrimary,
    brandSoft: AppColors.brandSoft,
  );

  static final dark = _build(
    brightness: Brightness.dark,
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    surfaceVariant: AppColors.darkSurfaceVariant,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    divider: AppColors.darkDivider,
    brandPrimary: AppColors.brandPrimaryDark,
    brandSoft: AppColors.brandSoftDark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceVariant,
    required Color textPrimary,
    required Color textSecondary,
    required Color divider,
    required Color brandPrimary,
    required Color brandSoft,
  }) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: brandPrimary,
      onPrimary: isDark ? AppColors.darkBackground : Colors.white,
      primaryContainer: brandSoft,
      onPrimaryContainer: textPrimary,
      secondary: AppColors.information,
      onSecondary: Colors.white,
      secondaryContainer: surfaceVariant,
      onSecondaryContainer: textPrimary,
      error: AppColors.critical,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: textSecondary,
      outline: divider,
      outlineVariant: divider,
      inverseSurface: textPrimary,
      onInverseSurface: surface,
      inversePrimary: brandSoft,
      shadow: Colors.black,
      scrim: Colors.black,
    );

    final textTheme = TextTheme(
      headlineSmall: AppTypography.screenTitle.copyWith(color: textPrimary),
      titleMedium: AppTypography.sectionTitle.copyWith(color: textPrimary),
      titleSmall: AppTypography.cardTitle.copyWith(color: textPrimary),
      bodyLarge: AppTypography.body.copyWith(color: textPrimary),
      bodyMedium: AppTypography.supportingText.copyWith(color: textSecondary),
      labelMedium: AppTypography.compactLabel.copyWith(color: textSecondary),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      dividerColor: divider,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: AppElevation.flat,
        titleTextStyle: AppTypography.sectionTitle.copyWith(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: AppElevation.flat,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: divider),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brandPrimary,
          foregroundColor: isDark ? AppColors.darkBackground : Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: AppTypography.cardTitle,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brandPrimary,
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: AppTypography.cardTitle,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: brandSoft,
        height: 64,
        labelTextStyle: WidgetStateProperty.all(
          AppTypography.compactLabel.copyWith(color: textPrimary),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: textSecondary,
        textColor: textPrimary,
        minVerticalPadding: AppSpacing.tight,
      ),
      dividerTheme: DividerThemeData(color: divider, space: 1),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
