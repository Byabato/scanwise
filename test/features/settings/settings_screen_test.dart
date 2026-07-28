import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/settings_test_harness.dart';

void main() {
  group('SettingsScreen', () {
    testWidgets('renders every section and row', (tester) async {
      await tester.pumpWidget(wrapSettingsRouter());
      await tester.pumpAndSettle();

      // The home list is a plain (sliver-backed) ListView, so rows below
      // the fold aren't built into the tree until scrolled into view —
      // scroll each one in before asserting on it, per the known gotcha of
      // off-screen content in scrollables.
      final scrollable = find.byType(Scrollable);

      expect(find.text('Privacy'), findsOneWidget);
      expect(find.text('Privacy and data'), findsOneWidget);
      expect(find.text('Scanning'), findsOneWidget);
      expect(find.text('Scanning preferences'), findsOneWidget);
      expect(find.text('Supported formats'), findsOneWidget);
      expect(find.text('Permissions'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('History preferences'),
        300,
        scrollable: scrollable,
      );
      expect(find.text('History'), findsOneWidget);
      expect(find.text('History preferences'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Theme'),
        300,
        scrollable: scrollable,
      );
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('System'), findsOneWidget); // default theme subtitle

      await tester.scrollUntilVisible(
        find.text('About ScanWise'),
        300,
        scrollable: scrollable,
      );
      expect(find.text('About'), findsOneWidget);
      expect(find.text('About ScanWise'), findsOneWidget);
    });

    testWidgets('Privacy and data row navigates to the privacy screen', (
      tester,
    ) async {
      await tester.pumpWidget(wrapSettingsRouter());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Privacy and data'));
      await tester.pumpAndSettle();

      expect(find.text('Process scans on device'), findsOneWidget);
    });

    testWidgets('Scanning preferences row navigates to the scanning screen', (
      tester,
    ) async {
      await tester.pumpWidget(wrapSettingsRouter());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Scanning preferences'));
      await tester.pumpAndSettle();

      expect(find.text('Haptic feedback'), findsOneWidget);
    });

    testWidgets('Supported formats row navigates to the formats screen', (
      tester,
    ) async {
      await tester.pumpWidget(wrapSettingsRouter());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Supported formats'));
      await tester.pumpAndSettle();

      expect(find.text('QR Code'), findsOneWidget);
    });

    testWidgets('Permissions row navigates to the permissions screen', (
      tester,
    ) async {
      await tester.pumpWidget(wrapSettingsRouter());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Permissions'));
      await tester.pumpAndSettle();

      expect(find.text('Open app settings'), findsOneWidget);
    });

    testWidgets('History preferences row navigates to the history screen', (
      tester,
    ) async {
      await tester.pumpWidget(wrapSettingsRouter());
      await tester.pumpAndSettle();

      await tester.tap(find.text('History preferences'));
      await tester.pumpAndSettle();

      expect(find.text('Recognize repeated scans'), findsOneWidget);
    });

    testWidgets('Theme row navigates to the Appearance screen', (tester) async {
      await tester.pumpWidget(wrapSettingsRouter());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Theme'),
        300,
        scrollable: find.byType(Scrollable),
      );
      await tester.ensureVisible(find.text('Theme'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      // App bar title, distinct from the "Theme" section heading it came
      // from (that heading does not exist on this destination screen).
      expect(find.text('Appearance'), findsOneWidget);
    });

    testWidgets('About ScanWise row navigates to the about screen', (
      tester,
    ) async {
      await tester.pumpWidget(wrapSettingsRouter());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('About ScanWise'),
        300,
        scrollable: find.byType(Scrollable),
      );
      await tester.tap(find.text('About ScanWise'));
      await tester.pumpAndSettle();

      expect(find.text('Version 1.0.0'), findsOneWidget);
    });
  });
}
