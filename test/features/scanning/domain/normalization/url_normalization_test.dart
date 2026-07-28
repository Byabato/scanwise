import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/features/scanning/domain/normalization/url_normalization.dart';

void main() {
  test('lowercases scheme and host', () {
    expect(
      normalizeUrl(Uri.parse('HTTPS://Example.COM/Path')),
      'https://example.com/Path',
    );
  });

  test('drops an explicit default port', () {
    expect(
      normalizeUrl(Uri.parse('https://example.com:443/a')),
      'https://example.com/a',
    );
  });

  test('keeps an explicit non-default port', () {
    expect(
      normalizeUrl(Uri.parse('https://example.com:8443/a')),
      'https://example.com:8443/a',
    );
  });

  test('preserves query and fragment', () {
    expect(
      normalizeUrl(Uri.parse('https://example.com/a?x=1#frag')),
      'https://example.com/a?x=1#frag',
    );
  });

  test('drops embedded credentials from the normalized form', () {
    expect(
      normalizeUrl(Uri.parse('https://user:pass@example.com/a')),
      'https://example.com/a',
    );
  });
}
