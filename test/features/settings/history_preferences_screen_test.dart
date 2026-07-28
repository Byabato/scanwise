import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/app/theme/app_theme.dart';
import 'package:scanwise/features/settings/presentation/history_preferences_screen.dart';

Widget _wrap(Widget child) => MaterialApp(theme: AppTheme.light, home: child);

void main() {
  group('HistoryPreferencesScreen', () {
    testWidgets('renders all three preference rows, all on by default', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const HistoryPreferencesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Recognize repeated scans'), findsOneWidget);
      expect(find.text('Show occurrence count'), findsOneWidget);
      expect(find.text('Keep scan source'), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(3));

      for (final title in [
        'Recognize repeated scans',
        'Show occurrence count',
        'Keep scan source',
      ]) {
        final tile = find.ancestor(
          of: find.text(title),
          matching: find.byType(SwitchListTile),
        );
        expect(tester.widget<SwitchListTile>(tile).value, isTrue);
      }
    });

    testWidgets('each toggle flips independently', (tester) async {
      await tester.pumpWidget(_wrap(const HistoryPreferencesScreen()));
      await tester.pumpAndSettle();

      final occurrenceTile = find.ancestor(
        of: find.text('Show occurrence count'),
        matching: find.byType(SwitchListTile),
      );

      await tester.tap(occurrenceTile);
      await tester.pumpAndSettle();

      expect(tester.widget<SwitchListTile>(occurrenceTile).value, isFalse);

      // The other two rows are unaffected.
      final repeatedTile = find.ancestor(
        of: find.text('Recognize repeated scans'),
        matching: find.byType(SwitchListTile),
      );
      final sourceTile = find.ancestor(
        of: find.text('Keep scan source'),
        matching: find.byType(SwitchListTile),
      );
      expect(tester.widget<SwitchListTile>(repeatedTile).value, isTrue);
      expect(tester.widget<SwitchListTile>(sourceTile).value, isTrue);
    });
  });
}
