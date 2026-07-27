import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/app/theme/app_theme.dart';
import 'package:scanwise/core/widgets/confirmation_sheet.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(theme: AppTheme.light, home: child);

  testWidgets('confirming resolves true and cancelling resolves false', (
    tester,
  ) async {
    bool? confirmedResult;
    bool? cancelledResult;

    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) => Column(
            children: [
              TextButton(
                onPressed: () async {
                  confirmedResult = await ConfirmationSheet.show(
                    context,
                    title: 'Delete this scan?',
                    message: 'This removes it from your Library.',
                    confirmLabel: 'Delete',
                    isDestructive: true,
                  );
                },
                child: const Text('open-confirm'),
              ),
              TextButton(
                onPressed: () async {
                  cancelledResult = await ConfirmationSheet.show(
                    context,
                    title: 'Delete this scan?',
                    message: 'This removes it from your Library.',
                    confirmLabel: 'Delete',
                  );
                },
                child: const Text('open-cancel'),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-confirm'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this scan?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(confirmedResult, isTrue);

    await tester.tap(find.text('open-cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(cancelledResult, isFalse);
  });
}
