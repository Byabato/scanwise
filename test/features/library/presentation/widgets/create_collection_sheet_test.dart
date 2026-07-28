import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/app/theme/app_theme.dart';
import 'package:scanwise/features/library/presentation/widgets/create_collection_sheet.dart';
import 'package:scanwise/shared/fixtures/models/collection_fixture.dart';

Widget _wrap(ValueChanged<CollectionFixture?> onResult) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            final result = await CreateCollectionSheet.show(context);
            onResult(result);
          },
          child: const Text('Open create collection'),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('Save is disabled until a name is entered', (tester) async {
    await tester.pumpWidget(_wrap((_) {}));

    await tester.tap(find.text('Open create collection'));
    await tester.pumpAndSettle();

    final saveButtonBefore = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Save'),
        matching: find.byWidgetPredicate((widget) => widget is FilledButton),
      ),
    );
    expect(saveButtonBefore.onPressed, isNull);

    await tester.enterText(
      find.widgetWithText(TextField, 'Name').first,
      'Field visits',
    );
    await tester.pumpAndSettle();

    final saveButtonAfter = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Save'),
        matching: find.byWidgetPredicate((widget) => widget is FilledButton),
      ),
    );
    expect(saveButtonAfter.onPressed, isNotNull);
  });

  testWidgets('Save returns a new collection with the entered fields', (
    tester,
  ) async {
    CollectionFixture? created;
    await tester.pumpWidget(_wrap((value) => created = value));

    await tester.tap(find.text('Open create collection'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Name').first,
      'Field visits',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Description (optional)').first,
      'Site inspection scans',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(created?.name, 'Field visits');
    expect(created?.description, 'Site inspection scans');
  });

  testWidgets('Cancel returns null without creating a collection', (
    tester,
  ) async {
    CollectionFixture? created = CollectionFixture(
      id: 'sentinel',
      name: 'sentinel',
    );
    await tester.pumpWidget(_wrap((value) => created = value));

    await tester.tap(find.text('Open create collection'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(created, isNull);
  });
}
