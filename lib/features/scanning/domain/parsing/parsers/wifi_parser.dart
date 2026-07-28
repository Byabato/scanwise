import '../../entities/scan_candidate.dart';
import '../../entities/scan_payload.dart';
import '../../enums/scan_kind.dart';
import '../../enums/wifi_security_type.dart';
import '../../failures/scan_parse_failure.dart';
import '../../normalization/escaping.dart';
import '../scan_parse_result.dart';
import '../scan_payload_parser.dart';

/// Parses the standard `WIFI:T:…;S:…;P:…;H:…;;` QR payload.
///
/// Fields are split on unescaped `;` and each `KEY:value` pair on the
/// first unescaped `:`, so escaped delimiters inside a value (an SSID or
/// password containing `;`, `,`, `:` or `\`) survive intact. An unknown
/// `T:` value degrades to [WifiSecurityType.unknown] rather than
/// failing — [WifiPayload.securityRaw] preserves it for display. Missing
/// `H:`/`P:` default to "not hidden"/"no password" rather than failing;
/// only a missing SSID is treated as malformed, since a Wi-Fi result
/// without a network name isn't meaningfully usable.
class WifiParser implements ScanPayloadParser {
  const WifiParser();

  @override
  bool canParse(ScanCandidate candidate) {
    return candidate.rawValue.trim().toUpperCase().startsWith('WIFI:');
  }

  @override
  ScanParseResult parse(ScanCandidate candidate) {
    final raw = candidate.rawValue.trim();
    final body = raw.substring('WIFI:'.length);
    final rawFields = splitUnescaped(
      body,
      ';',
    ).where((field) => field.isNotEmpty);

    String? ssid;
    String securityRaw = '';
    bool hasPassword = false;
    String? password;
    bool isHidden = false;

    for (final field in rawFields) {
      final keyValue = splitKeyValue(field);
      if (keyValue == null) continue;
      final key = keyValue.$1.trim().toUpperCase();
      final value = unescapeWifiValue(keyValue.$2);
      switch (key) {
        case 'S':
          ssid = value;
        case 'T':
          securityRaw = value;
        case 'P':
          password = value;
          hasPassword = value.isNotEmpty;
        case 'H':
          isHidden = value.trim().toLowerCase() == 'true';
      }
    }

    if (ssid == null || ssid.isEmpty) {
      return const ScanParseFailed(MalformedWifiFailure('missing SSID'));
    }

    final securityType = switch (securityRaw.toUpperCase()) {
      'NOPASS' || '' => WifiSecurityType.open,
      'WEP' => WifiSecurityType.wep,
      'WPA' || 'WPA2' => WifiSecurityType.wpa,
      _ => WifiSecurityType.unknown,
    };

    if (securityType == WifiSecurityType.open) {
      hasPassword = false;
      password = null;
    }

    return ScanParseSuccess(
      kind: ScanKind.wifi,
      payload: WifiPayload(
        ssid: ssid,
        securityType: securityType,
        securityRaw: securityRaw.isEmpty ? 'nopass' : securityRaw,
        hasPassword: hasPassword,
        password: password,
        isHidden: isHidden,
      ),
      title: ssid,
      normalizedValue: '$ssid|${securityType.name}|hidden=$isHidden',
    );
  }
}
