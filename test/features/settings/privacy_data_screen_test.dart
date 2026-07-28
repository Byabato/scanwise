import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/app/theme/app_theme.dart';
import 'package:scanwise/features/settings/presentation/privacy_data_screen.dart';

Widget _wrap(Widget child) => MaterialApp(theme: AppTheme.light, home: child);

void main() {
  group('PrivacyDataScreen', () {
    testWidgets('renders the always-on status row and both toggles', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const PrivacyDataScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Process scans on device'), findsOneWidget);
      expect(find.text('Always on'), findsOneWidget);
      expect(find.text('Incognito scanning'), findsOneWidget);
      expect(find.text('Automatically save scans'), findsOneWidget);
      expect(find.text('Clear scan history'), findsOneWidget);
    });

    testWidgets('the always-on status row has no switch to toggle', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const PrivacyDataScreen()));
      await tester.pumpAndSettle();

      // Only the two real preferences (incognito, auto-save) render a
      // Switch; "Process scans on device" is a status row, not a toggle.
      expect(find.byType(Switch), findsNWidgets(2));
    });

    testWidgets('incognito scanning starts off and flips on when tapped', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const PrivacyDataScreen()));
      await tester.pumpAndSettle();

      final incognitoTile = find.ancestor(
        of: find.text('Incognito scanning'),
        matching: find.byType(SwitchListTile),
      );
      expect(tester.widget<SwitchListTile>(incognitoTile).value, isFalse);

      await tester.tap(incognitoTile);
      await tester.pumpAndSettle();

      expect(tester.widget<SwitchListTile>(incognitoTile).value, isTrue);
    });

    testWidgets('automatically save scans starts on and flips off', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const PrivacyDataScreen()));
      await tester.pumpAndSettle();

      final autoSaveTile = find.ancestor(
        of: find.text('Automatically save scans'),
        matching: find.byType(SwitchListTile),
      );
      expect(tester.widget<SwitchListTile>(autoSaveTile).value, isTrue);

      await tester.tap(autoSaveTile);
      await tester.pumpAndSettle();

      expect(tester.widget<SwitchListTile>(autoSaveTile).value, isFalse);
    });

    testWidgets(
      'clearing history requires confirmation and then shows an honest '
      'preview notice',
      (tester) async {
        await tester.pumpWidget(_wrap(const PrivacyDataScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Clear scan history'));
        await tester.pumpAndSettle();

        expect(find.text('Clear scan history?'), findsOneWidget);
        expect(
          find.text(
            "History cleared (preview) — Library persistence isn't "
            'connected yet',
          ),
          findsNothing,
        );

        await tester.tap(find.text('Clear history'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            "History cleared (preview) — Library persistence isn't "
            'connected yet',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('cancelling the confirmation sheet clears nothing', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const PrivacyDataScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clear scan history'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          "History cleared (preview) — Library persistence isn't "
          'connected yet',
        ),
        findsNothing,
      );
    });
  });
}
