import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/features/scanning/domain/normalization/text_normalization.dart';

void main() {
  test('is the identity transform', () {
    const value = 'Booth 14B — badge pickup opens 08:00.';
    expect(normalizePlainText(value), value);
  });

  test('does not trim, lowercase or otherwise rewrite the content', () {
    expect(normalizePlainText('  Mixed CASE text  '), '  Mixed CASE text  ');
  });
}
