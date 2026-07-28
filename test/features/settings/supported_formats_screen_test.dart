import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/app/theme/app_theme.dart';
import 'package:scanwise/features/settings/presentation/supported_formats_screen.dart';

Widget _wrap(Widget child) => MaterialApp(theme: AppTheme.light, home: child);

void main() {
  group('SupportedFormatsScreen', () {
    testWidgets('lists every symbology from v1-scope, grouped by kind', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const SupportedFormatsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('2D codes'), findsOneWidget);
      expect(find.text('Linear barcodes'), findsOneWidget);

      // docs/product/v1-scope.md "Supported symbologies", exhaustively.
      for (final format in [
        'QR Code',
        'EAN-8',
        'EAN-13',
        'UPC-A',
        'UPC-E',
        'Code 128',
        'Data Matrix',
        'PDF417',
        'Aztec',
      ]) {
        expect(find.text(format), findsOneWidget, reason: format);
      }
    });

    testWidgets('rows are informational, not navigable', (tester) async {
      await tester.pumpWidget(_wrap(const SupportedFormatsScreen()));
      await tester.pumpAndSettle();

      final tile = tester.widget<ListTile>(
        find.ancestor(
          of: find.text('QR Code'),
          matching: find.byType(ListTile),
        ),
      );
      expect(tile.onTap, isNull);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });
  });
}
