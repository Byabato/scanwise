import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scanwise/app/router/app_routes.dart';
import 'package:scanwise/app/theme/app_theme.dart';
import 'package:scanwise/features/settings/presentation/about_screen.dart';
import 'package:scanwise/features/settings/presentation/appearance_screen.dart';
import 'package:scanwise/features/settings/presentation/history_preferences_screen.dart';
import 'package:scanwise/features/settings/presentation/permissions_screen.dart';
import 'package:scanwise/features/settings/presentation/privacy_data_screen.dart';
import 'package:scanwise/features/settings/presentation/scanning_preferences_screen.dart';
import 'package:scanwise/features/settings/presentation/settings_screen.dart';
import 'package:scanwise/features/settings/presentation/supported_formats_screen.dart';

/// A GoRouter scoped to Settings' own routes (plus a debug-gallery stub),
/// mirroring how app_router.dart will nest them once it's wired up. This
/// lets navigation tests exercise real `context.push` calls end to end
/// instead of mocking navigation.
Widget wrapSettingsRouter({String initialLocation = AppRoutes.settings}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsPrivacy,
        builder: (context, state) => const PrivacyDataScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsScanning,
        builder: (context, state) => const ScanningPreferencesScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsHistory,
        builder: (context, state) => const HistoryPreferencesScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsAppearance,
        builder: (context, state) => const AppearanceScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsPermissions,
        builder: (context, state) => const PermissionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsFormats,
        builder: (context, state) => const SupportedFormatsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsAbout,
        builder: (context, state) => const AboutScreen(),
      ),
      // Stands in for the real, kDebugMode-gated ComponentGalleryScreen
      // (lib/debug/component_gallery_screen.dart), which is out of this
      // feature's editable scope. Only the navigation target matters here.
      GoRoute(
        path: AppRoutes.debugGallery,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Debug gallery stub'))),
      ),
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  );
}
