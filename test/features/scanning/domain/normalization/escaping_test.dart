import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/features/scanning/domain/normalization/escaping.dart';

void main() {
  group('splitUnescaped', () {
    test('splits on an unescaped delimiter', () {
      expect(splitUnescaped('a;b;c', ';'), ['a', 'b', 'c']);
    });

    test('does not split on an escaped delimiter', () {
      expect(splitUnescaped(r'a\;b;c', ';'), [r'a\;b', 'c']);
    });
  });

  group('splitKeyValue', () {
    test('splits at the first unescaped colon', () {
      expect(splitKeyValue('T:WPA'), ('T', 'WPA'));
    });

    test('returns null when there is no colon', () {
      expect(splitKeyValue('no-colon-here'), isNull);
    });
  });

  group('unescapeWifiValue', () {
    test('unescapes semicolon, comma, colon and backslash', () {
      expect(unescapeWifiValue(r'a\;b\,c\:d\\e'), r'a;b,c:d\e');
    });
  });

  group('unescapeVCardValue', () {
    test('unescapes \\n as a newline', () {
      expect(unescapeVCardValue(r'line1\nline2'), 'line1\nline2');
    });
  });

  group('unfoldLines', () {
    test('joins a folded continuation line', () {
      expect(unfoldLines('NOTE:first part\n continued part'), [
        'NOTE:first partcontinued part',
      ]);
    });

    test('normalizes CRLF line endings', () {
      expect(unfoldLines('a\r\nb\r\nc'), ['a', 'b', 'c']);
    });
  });
}
