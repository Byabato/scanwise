import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// `Override` isn't re-exported from the main `flutter_riverpod.dart`
// barrel in Riverpod 3.x — it lives in `misc.dart`.
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';
import 'package:scanwise/app/router/app_routes.dart';
import 'package:scanwise/app/theme/app_theme.dart';
import 'package:scanwise/features/library/presentation/collection_detail_screen.dart';
import 'package:scanwise/features/library/presentation/library_screen.dart';
import 'package:scanwise/features/library/presentation/scan_detail_screen.dart';
import 'package:scanwise/features/library/presentation/search_screen.dart';

/// A standalone [GoRouter] covering only the Library feature's real
/// destinations. The production `app_router.dart` doesn't register these
/// nested routes yet (a concurrent milestone task wires them), so widget
/// tests that exercise `context.push`/`context.go` need their own router
/// rather than depending on the full app.
GoRouter buildLibraryTestRouter({String initialLocation = AppRoutes.library}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.scan,
        builder: (context, state) => const _StubScanScreen(),
      ),
      GoRoute(
        path: AppRoutes.library,
        builder: (context, state) => const LibraryScreen(),
        routes: [
          GoRoute(
            path: 'search',
            builder: (context, state) => const LibrarySearchScreen(),
          ),
          GoRoute(
            path: 'scan/:scanId',
            builder: (context, state) =>
                ScanDetailScreen(scanId: state.pathParameters['scanId']!),
          ),
          GoRoute(
            path: 'collection/:collectionId',
            builder: (context, state) => CollectionDetailScreen(
              collectionId: state.pathParameters['collectionId']!,
            ),
          ),
        ],
      ),
    ],
  );
}

/// Wraps [router] with the app theme and an optionally-overridden
/// [ProviderScope], matching the shape of the real app shell closely enough
/// for Library widget tests.
Widget wrapWithLibraryRouter(
  GoRouter router, {
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  );
}

class _StubScanScreen extends StatelessWidget {
  const _StubScanScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Scan destination')));
  }
}

/// A [ProviderContainer] paired with a widget tree pumped via
/// [UncontrolledProviderScope], so a test can both pump [child] and mutate
/// providers directly through [container] (e.g. to drive the controller
/// without going through UI that isn't under test).
class LibraryHarness {
  LibraryHarness({required this.container, required this.widget});

  final ProviderContainer container;
  final Widget widget;
}

/// Builds a non-router harness for widgets that don't need `context.push`.
LibraryHarness buildLibraryHarness(
  Widget child, {
  List<Override> overrides = const [],
}) {
  final container = ProviderContainer(overrides: overrides);
  return LibraryHarness(
    container: container,
    widget: UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: AppTheme.light, home: child),
    ),
  );
}
