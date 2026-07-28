import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/library/application/library_preview_controller.dart';
import '../features/library/presentation/collection_detail_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/library/presentation/scan_detail_screen.dart';
import '../features/library/presentation/search_screen.dart';
import '../features/scanner/presentation/scan_screen.dart';
import '../features/scanner/presentation/states/gallery_loading_state.dart';
import '../features/scanner/presentation/states/no_code_found_state.dart';
import '../features/scanner/presentation/states/permission_denied_state.dart';
import '../features/scanner/presentation/states/permission_permanently_denied_state.dart';
import '../features/scanner/presentation/states/scanner_detected_state.dart';
import '../features/scanner/presentation/states/scanner_unavailable_state.dart';
import '../features/settings/presentation/about_screen.dart';
import '../features/settings/presentation/appearance_screen.dart';
import '../features/settings/presentation/history_preferences_screen.dart';
import '../features/settings/presentation/permissions_screen.dart';
import '../features/settings/presentation/privacy_data_screen.dart';
import '../features/settings/presentation/scanning_preferences_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/presentation/supported_formats_screen.dart';
import '../shared/fixtures/catalog/collection_fixtures.dart';
import '../shared/fixtures/catalog/library_fixtures.dart';
import '../shared/fixtures/catalog/result_fixtures.dart';
import '../shared/fixtures/models/result_fixture.dart';
import '../shared/presentation/result/scan_result_view.dart';

/// Milestone-scoped, debug-only screen for reviewing every scanner state,
/// result fixture, Library state and Settings screen without needing real
/// camera, permission or persistence integration.
///
/// Registered as a route only when `kDebugMode` is true (see
/// app/router/app_router.dart) and reachable only from a debug-only row in
/// Settings → About — never from production navigation or the Scan screen
/// itself. Widget tests build target widgets/states directly and do not
/// depend on this screen.
class ComponentGalleryScreen extends StatelessWidget {
  const ComponentGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Component gallery')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const _SectionHeader('Scanner states'),
          _GalleryTile(label: 'Default', builder: (_) => const ScanScreen()),
          _GalleryTile(
            label: 'Detected',
            builder: (_) =>
                ScannerDetectedState(fixture: trustedUrlResultFixture),
          ),
          _GalleryTile(
            label: 'Gallery loading',
            builder: (_) => const GalleryLoadingState(),
          ),
          _GalleryTile(
            label: 'Scanner unavailable',
            builder: (_) => const ScannerUnavailableState(),
          ),
          _GalleryTile(
            label: 'No code found',
            builder: (_) => const NoCodeFoundState(),
          ),
          _GalleryTile(
            label: 'Permission denied',
            builder: (_) => const PermissionDeniedState(),
          ),
          _GalleryTile(
            label: 'Permission permanently denied',
            builder: (_) => const PermissionPermanentlyDeniedState(),
          ),
          const _SectionHeader('Result fixtures'),
          for (final fixture in allResultFixtures)
            _GalleryTile(
              label: '${fixture.typeLabel} — ${fixture.title}',
              builder: (_) => _ResultFixturePreviewScreen(fixture: fixture),
            ),
          const _SectionHeader('Library'),
          _GalleryTile(
            label: 'Populated',
            builder: (_) => const LibraryScreen(),
          ),
          _GalleryTile(
            label: 'Empty',
            builder: (_) => ProviderScope(
              overrides: [
                libraryPreviewSeedProvider.overrideWithValue(
                  emptyLibraryItemFixtures,
                ),
              ],
              child: const LibraryScreen(),
            ),
          ),
          _GalleryTile(
            label: 'Loading',
            builder: (_) => const LibraryScreen(
              previewDisplayState: LibraryDisplayState.loading,
            ),
          ),
          _GalleryTile(
            label: 'Error',
            builder: (_) => const LibraryScreen(
              previewDisplayState: LibraryDisplayState.error,
            ),
          ),
          _GalleryTile(
            label: 'Search',
            builder: (_) => const LibrarySearchScreen(),
          ),
          _GalleryTile(
            label: 'Scan detail',
            builder: (_) =>
                ScanDetailScreen(scanId: trustedUrlLibraryItemFixture.id),
          ),
          _GalleryTile(
            label: 'Collection detail',
            builder: (_) => CollectionDetailScreen(
              collectionId: researchCollectionFixture.id,
            ),
          ),
          const _SectionHeader('Settings'),
          _GalleryTile(
            label: 'Settings home',
            builder: (_) => const SettingsScreen(),
          ),
          _GalleryTile(
            label: 'Privacy and data',
            builder: (_) => const PrivacyDataScreen(),
          ),
          _GalleryTile(
            label: 'Scanning preferences',
            builder: (_) => const ScanningPreferencesScreen(),
          ),
          _GalleryTile(
            label: 'History preferences',
            builder: (_) => const HistoryPreferencesScreen(),
          ),
          _GalleryTile(
            label: 'Appearance',
            builder: (_) => const AppearanceScreen(),
          ),
          _GalleryTile(
            label: 'Permissions',
            builder: (_) => const PermissionsScreen(),
          ),
          _GalleryTile(
            label: 'Supported formats',
            builder: (_) => const SupportedFormatsScreen(),
          ),
          _GalleryTile(label: 'About', builder: (_) => const AboutScreen()),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({required this.label, required this.builder});

  final String label;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () =>
          Navigator.of(context).push(MaterialPageRoute(builder: builder)),
    );
  }
}

class _ResultFixturePreviewScreen extends StatelessWidget {
  const _ResultFixturePreviewScreen({required this.fixture});

  final ResultFixture fixture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(fixture.typeLabel)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ScanResultView(fixture: fixture),
      ),
    );
  }
}
