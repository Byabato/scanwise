import 'package:flutter/material.dart';

import '../features/scanner/presentation/scan_screen.dart';
import '../features/scanner/presentation/states/gallery_loading_state.dart';
import '../features/scanner/presentation/states/no_code_found_state.dart';
import '../features/scanner/presentation/states/permission_denied_state.dart';
import '../features/scanner/presentation/states/permission_permanently_denied_state.dart';
import '../features/scanner/presentation/states/scanner_detected_state.dart';
import '../features/scanner/presentation/states/scanner_unavailable_state.dart';
import '../shared/fixtures/catalog/result_fixtures.dart';
import '../shared/fixtures/models/result_fixture.dart';
import '../shared/presentation/result/scan_result_view.dart';

/// Milestone-scoped, debug-only screen for reviewing every scanner state
/// and result fixture (and, once Milestone 002B lands, every Library and
/// Settings variant) without needing real camera, permission or
/// persistence integration.
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
