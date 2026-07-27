import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/library/library_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/scanner/scan_screen.dart';
import '../../features/settings/settings_screen.dart';
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
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
