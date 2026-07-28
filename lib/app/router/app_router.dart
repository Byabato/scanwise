import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../debug/component_gallery_screen.dart';
import '../../features/library/presentation/collection_detail_screen.dart';
import '../../features/library/presentation/library_screen.dart';
import '../../features/library/presentation/scan_detail_screen.dart';
import '../../features/library/presentation/search_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/scanner/presentation/scan_screen.dart';
import '../../features/settings/presentation/about_screen.dart';
import '../../features/settings/presentation/appearance_screen.dart';
import '../../features/settings/presentation/history_preferences_screen.dart';
import '../../features/settings/presentation/permissions_screen.dart';
import '../../features/settings/presentation/privacy_data_screen.dart';
import '../../features/settings/presentation/scanning_preferences_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/supported_formats_screen.dart';
import 'app_routes.dart';
import 'navigation_shell.dart';

/// App-wide router, scoped to a provider so each [ProviderScope] (the whole
/// app, or an isolated widget test) gets its own [GoRouter] instance and
/// navigation state rather than sharing a global singleton.
///
/// Onboarding is a standalone route shown first on every launch (there is no
/// persistence yet to remember completion). Completing onboarding navigates
/// into the three-destination shell, replacing the history stack so the back
/// button does not return to onboarding.
final routerProvider = Provider<GoRouter>((ref) => _buildRouter());

GoRouter _buildRouter() => GoRouter(
  initialLocation: AppRoutes.onboarding,
  routes: [
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          NavigationShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.scan,
              builder: (context, state) => const ScanScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.library,
              builder: (context, state) => const LibraryScreen(),
              routes: [
                GoRoute(
                  path: 'search',
                  builder: (context, state) => const LibrarySearchScreen(),
                ),
                GoRoute(
                  path: 'scan/:id',
                  builder: (context, state) =>
                      ScanDetailScreen(scanId: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: 'collection/:id',
                  builder: (context, state) => CollectionDetailScreen(
                    collectionId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'privacy',
                  builder: (context, state) => const PrivacyDataScreen(),
                ),
                GoRoute(
                  path: 'scanning',
                  builder: (context, state) =>
                      const ScanningPreferencesScreen(),
                ),
                GoRoute(
                  path: 'history',
                  builder: (context, state) => const HistoryPreferencesScreen(),
                ),
                GoRoute(
                  path: 'appearance',
                  builder: (context, state) => const AppearanceScreen(),
                ),
                GoRoute(
                  path: 'permissions',
                  builder: (context, state) => const PermissionsScreen(),
                ),
                GoRoute(
                  path: 'formats',
                  builder: (context, state) => const SupportedFormatsScreen(),
                ),
                GoRoute(
                  path: 'about',
                  builder: (context, state) => const AboutScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    if (kDebugMode)
      GoRoute(
        path: AppRoutes.debugGallery,
        builder: (context, state) => const ComponentGalleryScreen(),
      ),
  ],
);
