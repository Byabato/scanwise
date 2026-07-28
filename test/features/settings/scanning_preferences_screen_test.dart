import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/app/theme/app_theme.dart';
import 'package:scanwise/features/settings/presentation/scanning_preferences_screen.dart';

Widget _wrap(Widget child) => MaterialApp(theme: AppTheme.light, home: child);

void main() {
  group('ScanningPreferencesScreen', () {
    testWidgets('renders both toggles and the disabled camera selector', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const ScanningPreferencesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Haptic feedback'), findsOneWidget);
      expect(find.text('Confirm before external actions'), findsOneWidget);
      expect(find.text('Default camera'), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(2));
    });

    testWidgets('haptic feedback starts on and flips off when tapped', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const ScanningPreferencesScreen()));
      await tester.pumpAndSettle();

      final tile = find.ancestor(
        of: find.text('Haptic feedback'),
        matching: find.byType(SwitchListTile),
      );
      expect(tester.widget<SwitchListTile>(tile).value, isTrue);

      await tester.tap(tile);
      await tester.pumpAndSettle();

      expect(tester.widget<SwitchListTile>(tile).value, isFalse);
    });

    testWidgets(
      'confirm before external actions starts on and flips off when tapped',
      (tester) async {
        await tester.pumpWidget(_wrap(const ScanningPreferencesScreen()));
        await tester.pumpAndSettle();

        final tile = find.ancestor(
          of: find.text('Confirm before external actions'),
          matching: find.byType(SwitchListTile),
        );
        expect(tester.widget<SwitchListTile>(tile).value, isTrue);

        await tester.tap(tile);
        await tester.pumpAndSettle();

        expect(tester.widget<SwitchListTile>(tile).value, isFalse);
      },
    );

    testWidgets('the default camera row is a real disabled affordance', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const ScanningPreferencesScreen()));
      await tester.pumpAndSettle();

      final listTile = tester.widget<ListTile>(
        find.ancestor(
          of: find.text('Default camera'),
          matching: find.byType(ListTile),
        ),
      );
      expect(listTile.enabled, isFalse);

      // At least one ancestor Semantics node (ours, wrapping the whole
      // row) reports enabled: false — regardless of any internal Semantics
      // ListTile itself may also contribute.
      final ancestorSemantics = tester.widgetList<Semantics>(
        find.ancestor(
          of: find.text('Default camera'),
          matching: find.byType(Semantics),
        ),
      );
      expect(
        ancestorSemantics.any((s) => s.properties.enabled == false),
        isTrue,
      );
      expect(find.byType(Tooltip), findsWidgets);
    });
  });
}
