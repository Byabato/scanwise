import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/app/theme/app_theme.dart';
import 'package:scanwise/features/library/application/library_preview_controller.dart';
import 'package:scanwise/features/library/presentation/scan_detail_screen.dart';
import 'package:scanwise/features/library/presentation/widgets/edit_note_sheet.dart';
import 'package:scanwise/shared/fixtures/catalog/library_fixtures.dart';

import '../../support/library_router_harness.dart';

Widget _wrap(ValueChanged<String?> onResult, {String? initialNote}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            final result = await EditNoteSheet.show(
              context,
              initialNote: initialNote,
            );
            onResult(result);
          },
          child: const Text('Open edit note'),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('Save returns the entered text', (tester) async {
    String? result;
    await tester.pumpWidget(_wrap((value) => result = value));

    await tester.tap(find.text('Open edit note'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Front desk credentials');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, 'Front desk credentials');
  });

  testWidgets('pre-fills the initial note for editing', (tester) async {
    await tester.pumpWidget(_wrap((_) {}, initialNote: 'Existing note'));

    await tester.tap(find.text('Open edit note'));
    await tester.pumpAndSettle();

    expect(find.text('Existing note'), findsOneWidget);
    expect(find.text('Edit note'), findsOneWidget);
  });

  testWidgets('Cancel returns null', (tester) async {
    String? result = 'sentinel';
    await tester.pumpWidget(_wrap((value) => result = value));

    await tester.tap(find.text('Open edit note'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });

  testWidgets('round-trips through the Library controller from scan detail', (
    tester,
  ) async {
    final harness = buildLibraryHarness(
      ScanDetailScreen(scanId: wifiLibraryItemFixture.id),
    );
    addTearDown(harness.container.dispose);

    await tester.pumpWidget(harness.widget);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Edit note'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Guest network for lobby');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final updated = harness.container
        .read(libraryPreviewControllerProvider)
        .items
        .firstWhere((item) => item.id == wifiLibraryItemFixture.id);
    expect(updated.note, 'Guest network for lobby');
    expect(find.text('Guest network for lobby'), findsOneWidget);
  });
}
