import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/library/application/library_preview_controller.dart';
import '../features/scanning/domain/entities/scan_candidate.dart';
import '../features/scanning/domain/enums/barcode_symbology.dart';
import '../features/scanning/domain/enums/scan_source.dart';
import '../features/scanning/domain/parsing/parser_registry.dart';
import '../features/scanning/domain/parsing/scan_parse_outcome.dart';
import '../features/scanning/presentation/mapping/parsed_scan_presentation_mapper.dart';
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
          const _SectionHeader('URL structural analysis (Milestone 004)'),
          for (final sample in _urlAnalysisSamples)
            _GalleryTile(
              label: sample.label,
              builder: (_) =>
                  _ResultFixturePreviewScreen(fixture: sample.buildFixture()),
            ),
          const _SectionHeader('Parsed scans (live, Milestone 003)'),
          for (final sample in _liveParsedScanSamples)
            _GalleryTile(
              label: sample.label,
              builder: (_) =>
                  _ResultFixturePreviewScreen(fixture: sample.buildFixture()),
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

/// One raw scan value run through the real Milestone 003 pipeline
/// ([ParserRegistry] → [mapParsedScanToResultFixture]) instead of a
/// hand-authored fixture — demonstrates that authoritative [ParsedScan]
/// output renders through the same unmodified [ScanResultView] the
/// fixture catalog does, without replacing that catalog (see
/// docs/plans/003-domain-and-parsing.md).
class _LiveScanSample {
  const _LiveScanSample({required this.label, required this.candidate});

  final String label;
  final ScanCandidate candidate;

  ResultFixture buildFixture() {
    final outcome = ParserRegistry().parse(candidate);
    if (outcome is ScanParseOutcomeSuccess) {
      return mapParsedScanToResultFixture(outcome.scan);
    }
    // Only reachable for empty/oversized input, neither of which any
    // sample below produces.
    throw StateError('Live gallery sample "$label" failed to parse.');
  }
}

_LiveScanSample _sample(
  String label,
  String rawValue, {
  BarcodeSymbology symbology = BarcodeSymbology.qrCode,
}) {
  return _LiveScanSample(
    label: label,
    candidate: ScanCandidate(
      rawValue: rawValue,
      symbology: symbology,
      source: ScanSource.camera,
      capturedAt: DateTime.utc(2026, 8, 14, 10),
    ),
  );
}

final List<_LiveScanSample> _liveParsedScanSamples = [
  _sample('URL', 'https://udsm.ac.tz/account?ref=poster-2026'),
  _sample('Wi-Fi', 'WIFI:T:WPA;S:NEBO Guest;P:nebo_guest_2024;H:false;;'),
  _sample(
    'Contact (vCard)',
    'BEGIN:VCARD\nVERSION:3.0\nN:Jenkins;Sarah;;;\nORG:TechConf\n'
        'TEL:+14155550142\nEMAIL:sarah.jenkins@techconf.example\n'
        'URL:https://techconf.example\nEND:VCARD',
  ),
  _sample('Email', 'mailto:admissions@udsm.ac.tz'),
  _sample('Phone', 'tel:+255222410500'),
  _sample('SMS', 'smsto:+255754000111:REG 2026 to confirm attendance'),
  _sample('Location', 'geo:-6.7735,39.2087?q=Mlimani%20City%20Mall'),
  _sample(
    'Calendar event',
    'BEGIN:VEVENT\nSUMMARY:ScanWise Product Review\n'
        'DTSTART:20260814T100000Z\nDTEND:20260814T110000Z\n'
        'LOCATION:Conference Room B\nORGANIZER:mailto:kelvin@scanwise.example\n'
        'END:VEVENT',
  ),
  _sample(
    'Product (EAN-13)',
    '4006381333931',
    symbology: BarcodeSymbology.ean13,
  ),
  _sample(
    'ISBN (EAN-13, Bookland)',
    '9780306406157',
    symbology: BarcodeSymbology.ean13,
  ),
  _sample('Plain text', 'Booth 14B — badge pickup opens 08:00.'),
  _sample('Unknown', '\x01\x02unreadable'),
];

final List<_LiveScanSample> _urlAnalysisSamples = [
  _sample('Normal HTTPS', 'https://example.com/account'),
  _sample('HTTP', 'http://example.com/account'),
  _sample('Explicit default port', 'https://example.com:443'),
  _sample('Unusual port', 'https://example.com:9443'),
  _sample('IPv4 host', 'https://8.8.8.8'),
  _sample('IPv6 host', 'https://[2001:4860:4860::8888]'),
  _sample('Localhost', 'http://localhost:8080'),
  _sample('Private network', 'https://192.168.1.20'),
  _sample('Excessive subdomains', 'https://a.b.c.d.e.f.example.com'),
  _sample('Embedded credentials', 'https://account.example:masked@example.net'),
  _sample('Punycode', 'https://xn--bcher-kva.example'),
  _sample('Unicode hostname', 'https://bücher.example'),
  _sample('Shortened URL', 'https://bit.ly/example'),
  _sample(
    'Nested URL',
    'https://example.com/go?next=https%3A%2F%2Fother.example',
  ),
  _sample('Malformed encoding', 'https://example.com/%zz'),
  _sample('Unsupported scheme', 'ftp://example.com/file'),
  _sample('Multiple findings', 'http://user:masked@127.0.0.1:9443/path'),
];
