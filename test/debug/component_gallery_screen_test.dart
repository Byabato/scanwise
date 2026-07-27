import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/app/theme/app_theme.dart';
import 'package:scanwise/debug/component_gallery_screen.dart';

void main() {
  testWidgets('lists every scanner state and result fixture, and navigates '
      'into a result preview', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const ComponentGalleryScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Scanner states'), findsOneWidget);
    expect(find.text('Result fixtures'), findsOneWidget);
    expect(find.text('Detected'), findsOneWidget);

    await tester.tap(find.textContaining('Website link').first);
    await tester.pumpAndSettle();

    expect(find.text('Website link'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
