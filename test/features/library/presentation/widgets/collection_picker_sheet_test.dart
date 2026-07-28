import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/app/theme/app_theme.dart';
import 'package:scanwise/features/library/presentation/widgets/collection_picker_sheet.dart';
import 'package:scanwise/shared/fixtures/catalog/collection_fixtures.dart';
import 'package:scanwise/shared/fixtures/models/result_fixture_kind.dart';

Widget _wrap(ValueChanged<String?> onResult, {ResultFixtureKind? kind}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            final result = await CollectionPickerSheet.show(
              context,
              suggestedForKind: kind,
            );
            onResult(result);
          },
          child: const Text('Open picker'),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('highlights the collection suggested for the given kind', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap((_) {}, kind: ResultFixtureKind.wifi));

    await tester.tap(find.text('Open picker'));
    await tester.pumpAndSettle();

    expect(find.text('Suggested'), findsOneWidget);
    expect(
      find.descendant(
        of: find.bySemanticsLabel(
          '${wifiNetworksCollectionFixture.name}, suggested',
        ),
        matching: find.text('Suggested'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('tapping a collection returns its id', (tester) async {
    String? result;
    await tester.pumpWidget(_wrap((value) => result = value));

    await tester.tap(find.text('Open picker'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(wifiNetworksCollectionFixture.name));
    await tester.pumpAndSettle();

    expect(result, wifiNetworksCollectionFixture.id);
  });

  testWidgets('tapping None returns an explicit clear marker', (tester) async {
    String? result;
    await tester.pumpWidget(_wrap((value) => result = value));

    await tester.tap(find.text('Open picker'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('None'));
    await tester.pumpAndSettle();

    expect(result, '');
  });

  testWidgets('creating a new collection from the picker selects it', (
    tester,
  ) async {
    String? result;
    await tester.pumpWidget(_wrap((value) => result = value));

    await tester.tap(find.text('Open picker'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New collection'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Field visits');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result, isNot(''));
  });
}
