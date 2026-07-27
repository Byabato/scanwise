import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/app/scanwise_app.dart';

import 'support/app_harness.dart';

void main() {
  testWidgets('the app renders without overflow at a large text scale', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: ProviderScope(child: ScanWiseApp()),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await completeOnboarding(tester);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('the app renders without overflow on a narrow Android screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpScanWiseApp(tester);
    expect(tester.takeException(), isNull);

    await completeOnboarding(tester);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
