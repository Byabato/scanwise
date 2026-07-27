import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/app/theme/app_theme.dart';
import 'package:scanwise/shared/fixtures/catalog/result_fixtures.dart';
import 'package:scanwise/shared/fixtures/models/result_action_fixture.dart';
import 'package:scanwise/shared/presentation/result/scan_result_view.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    ),
  );
}

/// Captures the last value written to the clipboard via the platform
/// channel, since `Clipboard.setData` has no in-memory fake by default.
String? _mockClipboard(WidgetTester tester) {
  String? lastCopiedText;
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'Clipboard.setData') {
        lastCopiedText = (call.arguments as Map)['text'] as String?;
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return lastCopiedText;
}

void main() {
  group('ScanResultView baseline (every result fixture)', () {
    for (final fixture in allResultFixtures) {
      testWidgets('${fixture.kind.name}: shared result hierarchy holds', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_wrap(ScanResultView(fixture: fixture)));
        await tester.pumpAndSettle();

        // Title is rendered.
        expect(find.text(fixture.title), findsOneWidget);

        // Exactly one primary action, and it carries a semantic label.
        expect(find.text(fixture.primaryAction.label), findsOneWidget);
        expect(
          find.bySemanticsLabel(fixture.primaryAction.label),
          findsOneWidget,
        );

        // Raw payload is present but collapsed by default. A handful of
        // fixtures (e.g. a product barcode) legitimately show the same
        // short value as both an interpreted field and the raw payload —
        // only assert absence when the raw payload isn't already visible
        // elsewhere for a good reason.
        expect(find.text('Raw payload'), findsOneWidget);
        final alreadyVisible = {
          fixture.title,
          ...fixture.fields.map((field) => field.value),
        };
        if (!alreadyVisible.contains(fixture.rawPayload)) {
          expect(find.text(fixture.rawPayload), findsNothing);
        }

        // Technical details, when present, are also collapsed by default.
        // Same caveat as the raw payload check above: a technical field's
        // value can legitimately coincide with an already-visible field
        // (e.g. a barcode's symbology text appearing in both places).
        if (fixture.technicalDetails.isNotEmpty) {
          expect(find.text('Technical details'), findsOneWidget);
          final firstDetailValue = fixture.technicalDetails.first.value;
          if (!alreadyVisible.contains(firstDetailValue)) {
            expect(find.text(firstDetailValue), findsNothing);
          }
        }

        handle.dispose();
      });
    }
  });

  group('unique result behavior', () {
    testWidgets('trusted URL shows a responsible, non-certain status', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const ScanResultView(fixture: trustedUrlResultFixture)),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('No obvious structural warning detected'),
        findsOneWidget,
      );
      expect(find.textContaining('cannot confirm'), findsOneWidget);
    });

    testWidgets('suspicious URL shows findings and a more prominent extracted '
        'destination than the full raw address', (tester) async {
      await tester.pumpWidget(
        _wrap(const ScanResultView(fixture: suspiciousUrlResultFixture)),
      );
      await tester.pumpAndSettle();

      expect(find.text('This link looks suspicious'), findsOneWidget);
      expect(find.text('Organization name in a subdomain'), findsOneWidget);
      expect(find.text('Insecure connection'), findsOneWidget);

      // The extracted destination is the title (always visible); the
      // full raw address only appears once technical details expand.
      expect(find.text(suspiciousUrlResultFixture.title), findsOneWidget);
      expect(
        find.textContaining(suspiciousUrlResultFixture.rawPayload),
        findsNothing,
      );
    });

    testWidgets(
      'Wi-Fi password is masked by default, revealable, and copyable',
      (tester) async {
        _mockClipboard(tester);
        await tester.pumpWidget(
          _wrap(const ScanResultView(fixture: wifiResultFixture)),
        );
        await tester.pumpAndSettle();

        expect(find.text('nebo_guest_2024'), findsNothing);
        expect(find.text('••••••••••••'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.visibility_outlined));
        await tester.pumpAndSettle();
        expect(find.text('nebo_guest_2024'), findsOneWidget);

        await tester.tap(find.text('Copy password'));
        await tester.pumpAndSettle();
        expect(find.text('Copied to clipboard'), findsOneWidget);
      },
    );

    testWidgets('contact fields render as grouped, labeled fields', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const ScanResultView(fixture: contactResultFixture)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('+1 415 555 0142'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('sarah.jenkins@techconf.example'), findsOneWidget);
      expect(find.text('Organization'), findsOneWidget);
      expect(find.text('TechConf'), findsOneWidget);
    });

    testWidgets('product result never invents unavailable product data', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const ScanResultView(fixture: productResultFixture)),
      );
      await tester.pumpAndSettle();

      expect(
        find.text("Product details aren't available offline."),
        findsOneWidget,
      );
      expect(find.text('4006381333931'), findsOneWidget);
    });

    testWidgets('calendar event formats date, time and location fields', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const ScanResultView(fixture: calendarEventResultFixture)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fri, 14 Aug 2026'), findsOneWidget);
      expect(find.text('10:00–11:00 EAT'), findsOneWidget);
      expect(find.text('Conference Room B'), findsOneWidget);
    });

    testWidgets('long plain text renders without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrap(const ScanResultView(fixture: plainTextResultFixture)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.textContaining('Booth 14B'), findsOneWidget);
    });

    testWidgets('unsupported content shows an honest fallback, not a guess', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const ScanResultView(fixture: unsupportedResultFixture)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Content type not recognized'), findsOneWidget);
      expect(
        find.text("ScanWise couldn't interpret this code's structure."),
        findsOneWidget,
      );
    });
  });

  group('action tiers', () {
    testWidgets('demonstrable action copies and shows real feedback', (
      tester,
    ) async {
      _mockClipboard(tester);
      await tester.pumpWidget(
        _wrap(const ScanResultView(fixture: trustedUrlResultFixture)),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Copy link'));
      await tester.tap(find.text('Copy link'));
      await tester.pumpAndSettle();

      expect(find.text('Copied to clipboard'), findsOneWidget);
    });

    testWidgets('preview-only action shows its specific preview message', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const ScanResultView(fixture: trustedUrlResultFixture)),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Saving will be available once Library persistence is added.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('disabled primary action is a real disabled button', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const ScanResultView(fixture: trustedUrlResultFixture)),
      );
      await tester.pumpAndSettle();

      expect(
        trustedUrlResultFixture.primaryAction.tier,
        ResultActionTier.disabled,
      );

      final button = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Open website'),
          // `FilledButton.icon` returns a private subclass, so
          // `find.byType(FilledButton)` (exact runtimeType match) would
          // miss it — match by `is FilledButton` instead.
          matching: find.byWidgetPredicate((widget) => widget is FilledButton),
        ),
      );
      expect(button.onPressed, isNull);
    });
  });

  group('accessibility and layout resilience', () {
    testWidgets('renders without overflow at a large text scale', (
      tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: _wrap(
            const ScanResultView(fixture: suspiciousUrlResultFixture),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow at 320dp width', (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrap(const ScanResultView(fixture: wifiResultFixture)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
