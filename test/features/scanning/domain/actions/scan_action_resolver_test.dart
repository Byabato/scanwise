import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/features/scanning/domain/actions/scan_action_resolver.dart';
import 'package:scanwise/features/scanning/domain/entities/scan_payload.dart';
import 'package:scanwise/features/scanning/domain/enums/barcode_symbology.dart';
import 'package:scanwise/features/scanning/domain/enums/scan_action_type.dart';
import 'package:scanwise/features/scanning/domain/enums/scan_kind.dart';
import 'package:scanwise/features/scanning/domain/enums/wifi_security_type.dart';

void main() {
  test('exactly one action is primary, for every kind', () {
    final cases = <ScanPayload>[
      UrlPayload(
        rawUrl: 'https://example.com',
        uri: Uri.parse('https://example.com'),
        scheme: 'https',
        host: 'example.com',
        port: null,
        path: '/',
        query: '',
        fragment: '',
        hasUserInfo: false,
      ),
      const WifiPayload(
        ssid: 'Net',
        securityType: WifiSecurityType.wpa,
        securityRaw: 'WPA',
        hasPassword: true,
        password: 'pw',
        isHidden: false,
      ),
      const ContactPayload(vCardVersion: '3.0', fullName: 'Sarah'),
      const ProductPayload(
        identifier: '123',
        symbology: BarcodeSymbology.ean13,
        digits: '123',
        isCheckDigitValid: true,
      ),
      const PhonePayload(rawNumber: '123', normalizedNumber: '123'),
      const EmailPayload(recipients: ['a@example.com']),
      const SmsPayload(recipient: '123'),
      const LocationPayload(latitude: 1, longitude: 1),
      const PlainTextPayload(text: 'hi'),
      const UnknownPayload(rawValue: 'x'),
    ];

    for (final payload in cases) {
      final actions = resolveScanActions(kind: ScanKind.url, payload: payload);
      expect(
        actions.where((a) => a.isPrimary).length,
        1,
        reason: '${payload.runtimeType} should have exactly one primary action',
      );
    }
  });

  group('Wi-Fi actions', () {
    test('copy password is enabled when a password is present', () {
      const payload = WifiPayload(
        ssid: 'Net',
        securityType: WifiSecurityType.wpa,
        securityRaw: 'WPA',
        hasPassword: true,
        password: 'pw',
        isHidden: false,
      );
      final actions = resolveScanActions(kind: ScanKind.wifi, payload: payload);
      final copyPassword = actions.firstWhere((a) => a.isPrimary);
      expect(copyPassword.enabled, isTrue);
      expect(copyPassword.copyValue, 'pw');
      expect(copyPassword.isSensitive, isTrue);
    });

    test('copy password is disabled for an open network', () {
      const payload = WifiPayload(
        ssid: 'Net',
        securityType: WifiSecurityType.open,
        securityRaw: 'nopass',
        hasPassword: false,
        password: null,
        isHidden: false,
      );
      final actions = resolveScanActions(kind: ScanKind.wifi, payload: payload);
      final copyPassword = actions.firstWhere((a) => a.isPrimary);
      expect(copyPassword.enabled, isFalse);
      expect(copyPassword.disabledReason, isNotNull);
    });

    test('sharing a network with a password requires confirmation', () {
      const payload = WifiPayload(
        ssid: 'Net',
        securityType: WifiSecurityType.wpa,
        securityRaw: 'WPA',
        hasPassword: true,
        password: 'pw',
        isHidden: false,
      );
      final actions = resolveScanActions(kind: ScanKind.wifi, payload: payload);
      final share = actions.firstWhere((a) => a.type == ScanActionType.share);
      expect(share.requiresConfirmation, isTrue);
    });
  });

  group('URL actions', () {
    test('open requires confirmation and is disabled this milestone', () {
      final payload = UrlPayload(
        rawUrl: 'https://example.com',
        uri: Uri.parse('https://example.com'),
        scheme: 'https',
        host: 'example.com',
        port: null,
        path: '/',
        query: '',
        fragment: '',
        hasUserInfo: false,
      );
      final actions = resolveScanActions(kind: ScanKind.url, payload: payload);
      final open = actions.firstWhere((a) => a.type == ScanActionType.open);
      expect(open.enabled, isFalse);
      expect(open.requiresConfirmation, isTrue);
      expect(open.isPrimary, isTrue);
    });

    test('copy, share and save are always enabled', () {
      final payload = UrlPayload(
        rawUrl: 'https://example.com',
        uri: Uri.parse('https://example.com'),
        scheme: 'https',
        host: 'example.com',
        port: null,
        path: '/',
        query: '',
        fragment: '',
        hasUserInfo: false,
      );
      final actions = resolveScanActions(kind: ScanKind.url, payload: payload);
      for (final type in [
        ScanActionType.copy,
        ScanActionType.share,
        ScanActionType.save,
      ]) {
        expect(
          actions.firstWhere((a) => a.type == type).enabled,
          isTrue,
          reason: type.name,
        );
      }
    });
  });
}
