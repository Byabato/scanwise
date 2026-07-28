import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/features/scanning/domain/normalization/phone_normalization.dart';

void main() {
  test('preserves a leading plus', () {
    expect(normalizePhoneNumber('+255 22 241 0500'), '+255222410500');
  });

  test('strips punctuation without a leading plus', () {
    expect(normalizePhoneNumber('(022) 241-0500'), '0222410500');
  });

  test('does not add a plus that was never present', () {
    expect(normalizePhoneNumber('0222410500').startsWith('+'), isFalse);
  });
}
