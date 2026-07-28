import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/features/scanning/domain/entities/scan_payload.dart';
import 'package:scanwise/features/scanning/domain/enums/wifi_security_type.dart';
import 'package:scanwise/features/scanning/domain/parsing/parsers/wifi_parser.dart';
import 'package:scanwise/features/scanning/domain/parsing/scan_parse_result.dart';

import '../../../support/candidate.dart';

void main() {
  const parser = WifiParser();

  group('WifiParser.canParse', () {
    test('accepts a WIFI: prefix', () {
      expect(parser.canParse(candidate('WIFI:T:WPA;S:Net;P:pass;;')), isTrue);
    });

    test('declines unrelated text', () {
      expect(parser.canParse(candidate('Hello world')), isFalse);
    });
  });

  group('WifiParser.parse', () {
    test('parses WPA', () {
      final result =
          parser.parse(candidate('WIFI:T:WPA;S:OfficeNet;P:example123;;'))
              as ScanParseSuccess;
      final payload = result.payload as WifiPayload;
      expect(payload.ssid, 'OfficeNet');
      expect(payload.securityType, WifiSecurityType.wpa);
      expect(payload.hasPassword, isTrue);
      expect(payload.password, 'example123');
      expect(payload.isHidden, isFalse);
    });

    test('parses WEP', () {
      final result =
          parser.parse(candidate('WIFI:T:WEP;S:OldNet;P:12345;;'))
              as ScanParseSuccess;
      final payload = result.payload as WifiPayload;
      expect(payload.securityType, WifiSecurityType.wep);
    });

    test('parses an open network (nopass)', () {
      final result =
          parser.parse(candidate('WIFI:T:nopass;S:CafeWifi;;'))
              as ScanParseSuccess;
      final payload = result.payload as WifiPayload;
      expect(payload.securityType, WifiSecurityType.open);
      expect(payload.hasPassword, isFalse);
      expect(payload.password, isNull);
    });

    test('parses a hidden network', () {
      final result =
          parser.parse(candidate('WIFI:T:WPA;S:Hidden;P:pw;H:true;;'))
              as ScanParseSuccess;
      final payload = result.payload as WifiPayload;
      expect(payload.isHidden, isTrue);
    });

    test('unescapes an escaped semicolon in the SSID', () {
      final result =
          parser.parse(candidate(r'WIFI:T:WPA;S:Office\;Net;P:pw;;'))
              as ScanParseSuccess;
      final payload = result.payload as WifiPayload;
      expect(payload.ssid, 'Office;Net');
    });

    test('unescapes an escaped colon in the password', () {
      final result =
          parser.parse(candidate(r'WIFI:T:WPA;S:Net;P:pa\:ss;;'))
              as ScanParseSuccess;
      final payload = result.payload as WifiPayload;
      expect(payload.password, 'pa:ss');
    });

    test('unescapes an escaped backslash', () {
      final result =
          parser.parse(candidate(r'WIFI:T:WPA;S:Net;P:pa\\ss;;'))
              as ScanParseSuccess;
      final payload = result.payload as WifiPayload;
      expect(payload.password, r'pa\ss');
    });

    test('handles a missing ;; terminator', () {
      final result = parser.parse(candidate('WIFI:T:WPA;S:Net;P:pw'));
      expect(result, isA<ScanParseSuccess>());
      final payload = (result as ScanParseSuccess).payload as WifiPayload;
      expect(payload.ssid, 'Net');
    });

    test('fails safely on an empty SSID', () {
      final result = parser.parse(candidate('WIFI:T:WPA;S:;P:pw;;'));
      expect(result, isA<ScanParseFailed>());
    });

    test('degrades a malformed field safely instead of throwing', () {
      final result = parser.parse(candidate('WIFI:T:WPA;S:Net;garbage;P:pw;;'));
      expect(result, isA<ScanParseSuccess>());
      final payload = (result as ScanParseSuccess).payload as WifiPayload;
      expect(payload.ssid, 'Net');
      expect(payload.password, 'pw');
    });

    test('degrades an unknown security type instead of failing', () {
      final result =
          parser.parse(candidate('WIFI:T:WPA2-EAP;S:Net;P:pw;;'))
              as ScanParseSuccess;
      final payload = result.payload as WifiPayload;
      expect(payload.securityType, WifiSecurityType.unknown);
      expect(payload.securityRaw, 'WPA2-EAP');
    });
  });
}
