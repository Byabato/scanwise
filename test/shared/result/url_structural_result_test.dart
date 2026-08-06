import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/app/theme/app_theme.dart';
import 'package:scanwise/features/scanning/domain/entities/scan_candidate.dart';
import 'package:scanwise/features/scanning/domain/enums/barcode_symbology.dart';
import 'package:scanwise/features/scanning/domain/enums/scan_source.dart';
import 'package:scanwise/features/scanning/domain/parsing/parser_registry.dart';
import 'package:scanwise/features/scanning/domain/parsing/scan_parse_outcome.dart';
import 'package:scanwise/features/scanning/presentation/mapping/parsed_scan_presentation_mapper.dart';
import 'package:scanwise/shared/fixtures/models/result_fixture.dart';
import 'package:scanwise/shared/presentation/result/scan_result_view.dart';

/// Widget-level coverage for Milestone 004: a real [ParsedScan] with
/// structural findings, run through the *same* [ScanResultView] the
/// fixture catalog uses (no parallel security UI) — see
/// docs/engineering/url-structural-analysis.md.
void main() {
  ResultFixture liveFixture(String rawValue) {
    final candidate = ScanCandidate(
      rawValue: rawValue,
      symbology: BarcodeSymbology.qrCode,
      source: ScanSource.camera,
      capturedAt: DateTime.utc(2026, 1, 1),
    );
    final outcome = ParserRegistry().parse(candidate);
    return mapParsedScanToResultFixture(
      (outcome as ScanParseOutcomeSuccess).scan,
    );
  }

  Widget wrap(Widget child) {
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

  testWidgets('severity is conveyed through text/semantics, not color alone', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final fixture = liveFixture('http://user:secret@127.0.0.1:9443/path');

    await tester.pumpWidget(wrap(ScanResultView(fixture: fixture)));
    await tester.pumpAndSettle();

    // The severity word appears in visible text, and the merged
    // semantics node for the banner states it explicitly — a
    // screen-reader user gets the same signal as a sighted user reading
    // color/icon.
    expect(find.textContaining('High concern'), findsNothing);
    expect(find.bySemanticsLabel(RegExp('High concern.*')), findsOneWidget);

    handle.dispose();
  });

  testWidgets('the destination host is prominent; the full raw address with '
      'credentials stays collapsed behind raw payload', (tester) async {
    final fixture = liveFixture('http://user:secret@127.0.0.1:9443/path');

    await tester.pumpWidget(wrap(ScanResultView(fixture: fixture)));
    await tester.pumpAndSettle();

    expect(find.text('127.0.0.1'), findsWidgets);
    expect(find.textContaining('secret'), findsNothing);
  });

  testWidgets(
    'findings render in the same order the domain layer produced them',
    (tester) async {
      final fixture = liveFixture('http://user:secret@127.0.0.1:9443/path');

      await tester.pumpWidget(wrap(ScanResultView(fixture: fixture)));
      await tester.pumpAndSettle();

      final codes = fixture.security!.findings.map((f) => f.title).toList();
      final positions = codes
          .map((title) => tester.getTopLeft(find.text(title)).dy)
          .toList();
      expect(
        positions,
        orderedEquals([...positions]..sort()),
        reason: 'findings should render top-to-bottom in domain order',
      );
    },
  );

  testWidgets('a long hostname and long finding explanations render without '
      'overflow at 320dp width and a large text scale', (tester) async {
    final longHost = '${'sub.' * 20}example.com';
    final fixture = liveFixture('http://user:secret@$longHost:9443/path');

    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: wrap(ScanResultView(fixture: fixture)),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('a trusted (no-finding) live URL shows the no-warning state', (
    tester,
  ) async {
    final fixture = liveFixture('https://example.com/account');

    await tester.pumpWidget(wrap(ScanResultView(fixture: fixture)));
    await tester.pumpAndSettle();

    expect(find.text('No obvious structural warning detected'), findsOneWidget);
  });
}
