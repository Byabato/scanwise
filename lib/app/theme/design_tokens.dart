import 'package:flutter/material.dart';

/// Centralized color tokens. Values follow docs/design/design-system.md.
///
/// The scanner surface colors are fixed (near-black with warm-white
/// foreground) regardless of the active app theme, matching the approved
/// dark scanner treatment.
abstract final class AppColors {
  // Light theme.
  static const lightBackground = Color(0xFFF7F8F6);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF1F3F0);
  static const lightTextPrimary = Color(0xFF161A18);
  static const lightTextSecondary = Color(0xFF646B67);
  static const lightDivider = Color(0xFFE2E6E2);

  // Dark theme (derived to preserve contrast against the light palette).
  static const darkBackground = Color(0xFF10130F);
  static const darkSurface = Color(0xFF171B17);
  static const darkSurfaceVariant = Color(0xFF1E231E);
  static const darkTextPrimary = Color(0xFFEDEFEA);
  static const darkTextSecondary = Color(0xFFA9B0AA);
  static const darkDivider = Color(0xFF2B322B);

  // Brand and semantic colors, shared across themes.
  static const brandPrimary = Color(0xFF176B55);
  static const brandPrimaryDark = Color(0xFF4CA98A);
  static const brandSoft = Color(0xFFDDEFE8);
  static const brandSoftDark = Color(0xFF1F3A30);
  static const information = Color(0xFF356B8C);
  static const caution = Color(0xFFA66610);
  static const critical = Color(0xFFB43A3A);
  static const positive = Color(0xFF287A55);

  // Scanner surface, independent of light/dark theme.
  static const scannerSurface = Color(0xFF0E100D);
  static const scannerForeground = Color(0xFFF5F1EA);
  static const scannerFrameIdle = Color(0xFFF5F1EA);
  static const scannerFrameDetected = Color(0xFF4CA98A);
}

/// Sentence-case, restrained type hierarchy. No uppercase transforms except
/// for compact technical labels applied directly at the call site.
abstract final class AppTypography {
  static const screenTitle = TextStyle(
    fontSize: 24,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );
  static const sectionTitle = TextStyle(
    fontSize: 19,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );
  static const cardTitle = TextStyle(
    fontSize: 16,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );
  static const body = TextStyle(
    fontSize: 16,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );
  static const supportingText = TextStyle(
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );
  static const compactLabel = TextStyle(
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w500,
  );
}

/// 8-point spacing scale.
abstract final class AppSpacing {
  static const micro = 4.0;
  static const tight = 8.0;
  static const compact = 12.0;
  static const standard = 16.0;
  static const screen = 20.0;
  static const section = 24.0;
  static const major = 32.0;
}

/// Corner-radius tokens. Not every control is pill-shaped.
abstract final class AppRadius {
  static const card = 20.0;
  static const sheetTop = 28.0;
  static const button = 16.0;
  static const chip = 100.0;
}

/// Elevation reserved for result sheets, floating camera controls, dialogs
/// and transient overlays. Everything else prefers spacing, tonal surfaces
/// or borders.
abstract final class AppElevation {
  static const flat = 0.0;
  static const resultSheet = 3.0;
  static const floatingControl = 2.0;
  static const dialog = 6.0;
}

/// Motion durations and curves. Restrained and functional, never decorative.
abstract final class AppMotion {
  static const detectionFeedback = Duration(milliseconds: 180);
  static const resultSheetEntrance = Duration(milliseconds: 240);
  static const stateTransition = Duration(milliseconds: 220);
  static const standardCurve = Curves.easeOutCubic;
}
