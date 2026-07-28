import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/features/scanning/domain/entities/scan_payload.dart';
import 'package:scanwise/features/scanning/domain/enums/barcode_symbology.dart';
import 'package:scanwise/features/scanning/domain/enums/scan_kind.dart';
import 'package:scanwise/features/scanning/domain/enums/wifi_security_type.dart';
import 'package:scanwise/features/scanning/domain/identity/content_identity_builder.dart';

void main() {
  group('general rules', () {
    test('does not expose the raw or normalized value directly', () {
      const secret = 'super-secret-wifi-password-value';
      final identity = buildContentIdentity(
        kind: ScanKind.plainText,
        payload: const PlainTextPayload(text: secret),
        normalizedValue: secret,
      );
      expect(identity.value.contains(secret), isFalse);
    });

    test('is deterministic for the same input', () {
      identityFor(String value) => buildContentIdentity(
        kind: ScanKind.plainText,
        payload: PlainTextPayload(text: value),
        normalizedValue: value,
      );
      final a = identityFor('hello');
      final b = identityFor('hello');
      expect(a, equals(b));
    });

    test('different content produces different identity', () {
      final a = buildContentIdentity(
        kind: ScanKind.plainText,
        payload: const PlainTextPayload(text: 'hello'),
        normalizedValue: 'hello',
      );
      final b = buildContentIdentity(
        kind: ScanKind.plainText,
        payload: const PlainTextPayload(text: 'goodbye'),
        normalizedValue: 'goodbye',
      );
      expect(a, isNot(equals(b)));
    });

    test('different kinds with the same normalized value do not collide', () {
      final a = buildContentIdentity(
        kind: ScanKind.plainText,
        payload: const PlainTextPayload(text: '123'),
        normalizedValue: '123',
      );
      final b = buildContentIdentity(
        kind: ScanKind.phone,
        payload: const PhonePayload(rawNumber: '123', normalizedNumber: '123'),
        normalizedValue: '123',
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('URL identity', () {
    test('same normalized URL produces the same identity', () {
      identityFor(String normalized) => buildContentIdentity(
        kind: ScanKind.url,
        payload: UrlPayload(
          rawUrl: normalized,
          uri: Uri.parse(normalized),
          scheme: 'https',
          host: 'example.com',
          port: null,
          path: '/a',
          query: '',
          fragment: '',
          hasUserInfo: false,
        ),
        normalizedValue: normalized,
      );
      expect(
        identityFor('https://example.com/a'),
        equals(identityFor('https://example.com/a')),
      );
    });

    test('a different path produces a different identity', () {
      UrlPayload payloadFor(String path) => UrlPayload(
        rawUrl: 'https://example.com$path',
        uri: Uri.parse('https://example.com$path'),
        scheme: 'https',
        host: 'example.com',
        port: null,
        path: path,
        query: '',
        fragment: '',
        hasUserInfo: false,
      );
      final a = buildContentIdentity(
        kind: ScanKind.url,
        payload: payloadFor('/a'),
        normalizedValue: 'https://example.com/a',
      );
      final b = buildContentIdentity(
        kind: ScanKind.url,
        payload: payloadFor('/b'),
        normalizedValue: 'https://example.com/b',
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('Wi-Fi identity', () {
    WifiPayload wifi({
      required String ssid,
      WifiSecurityType securityType = WifiSecurityType.wpa,
      bool hasPassword = true,
      String? password = 'pw',
      bool isHidden = false,
    }) => WifiPayload(
      ssid: ssid,
      securityType: securityType,
      securityRaw: 'WPA',
      hasPassword: hasPassword,
      password: password,
      isHidden: isHidden,
    );

    test(
      'same SSID/security/hidden collide even with a different password',
      () {
        final a = buildContentIdentity(
          kind: ScanKind.wifi,
          payload: wifi(ssid: 'Net', password: 'old-password'),
          normalizedValue: 'Net|wpa|hidden=false',
        );
        final b = buildContentIdentity(
          kind: ScanKind.wifi,
          payload: wifi(ssid: 'Net', password: 'new-password'),
          normalizedValue: 'Net|wpa|hidden=false',
        );
        expect(a, equals(b));
      },
    );

    test('a different SSID does not collide', () {
      final a = buildContentIdentity(
        kind: ScanKind.wifi,
        payload: wifi(ssid: 'NetA'),
        normalizedValue: 'NetA|wpa|hidden=false',
      );
      final b = buildContentIdentity(
        kind: ScanKind.wifi,
        payload: wifi(ssid: 'NetB'),
        normalizedValue: 'NetB|wpa|hidden=false',
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('contact identity (conservative)', () {
    test('same name and phone collide', () {
      const payload = ContactPayload(
        vCardVersion: '3.0',
        fullName: 'Sarah Jenkins',
        phones: ['+14155550142'],
      );
      final a = buildContentIdentity(
        kind: ScanKind.contact,
        payload: payload,
        normalizedValue: 'Sarah Jenkins',
      );
      final b = buildContentIdentity(
        kind: ScanKind.contact,
        payload: payload,
        normalizedValue: 'Sarah Jenkins',
      );
      expect(a, equals(b));
    });

    test(
      'two name-only contacts with the same name still collide (documented limitation)',
      () {
        const payload = ContactPayload(
          vCardVersion: '3.0',
          fullName: 'Sarah Jenkins',
        );
        final a = buildContentIdentity(
          kind: ScanKind.contact,
          payload: payload,
          normalizedValue: 'Sarah Jenkins',
        );
        final b = buildContentIdentity(
          kind: ScanKind.contact,
          payload: payload,
          normalizedValue: 'Sarah Jenkins',
        );
        expect(a, equals(b));
      },
    );

    test('same name with a different phone does not collide', () {
      final a = buildContentIdentity(
        kind: ScanKind.contact,
        payload: const ContactPayload(
          vCardVersion: '3.0',
          fullName: 'Sarah Jenkins',
          phones: ['+14155550142'],
        ),
        normalizedValue: 'Sarah Jenkins',
      );
      final b = buildContentIdentity(
        kind: ScanKind.contact,
        payload: const ContactPayload(
          vCardVersion: '3.0',
          fullName: 'Sarah Jenkins',
          phones: ['+14155559999'],
        ),
        normalizedValue: 'Sarah Jenkins',
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('product identity', () {
    test('same symbology and digits collide', () {
      const payload = ProductPayload(
        identifier: '4006381333931',
        symbology: BarcodeSymbology.ean13,
        digits: '4006381333931',
        isCheckDigitValid: true,
      );
      final a = buildContentIdentity(
        kind: ScanKind.product,
        payload: payload,
        normalizedValue: '4006381333931',
      );
      final b = buildContentIdentity(
        kind: ScanKind.product,
        payload: payload,
        normalizedValue: '4006381333931',
      );
      expect(a, equals(b));
    });
  });
}
