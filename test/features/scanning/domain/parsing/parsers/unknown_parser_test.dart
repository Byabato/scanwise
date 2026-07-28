import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/features/scanning/domain/entities/scan_payload.dart';
import 'package:scanwise/features/scanning/domain/parsing/parsers/unknown_parser.dart';
import 'package:scanwise/features/scanning/domain/parsing/scan_parse_result.dart';

import '../../../support/candidate.dart';

void main() {
  const parser = UnknownParser();

  test('always matches', () {
    expect(parser.canParse(candidate('anything at all')), isTrue);
  });

  test('always succeeds without inventing an interpretation', () {
    final result = parser.parse(candidate('bad�data')) as ScanParseSuccess;
    final payload = result.payload as UnknownPayload;
    expect(payload.rawValue, 'bad�data');
    expect(result.title, 'Content type not recognized');
  });
}
