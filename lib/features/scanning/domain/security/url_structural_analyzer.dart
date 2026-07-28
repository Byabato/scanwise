import 'dart:io';

import '../entities/scan_payload.dart';
import 'risk_level.dart';
import 'structural_assessment.dart';
import 'structural_finding.dart';
import 'url_analysis_policy.dart';

class UrlStructuralAnalyzer {
  const UrlStructuralAnalyzer();

  StructuralAssessment analyze(UrlPayload payload) {
    final findings = <StructuralFinding>[];
    void add(
      String code,
      RiskLevel severity,
      String headline,
      String explanation,
      String recommendation, {
      Map<String, String> evidence = const {},
    }) => findings.add(
      StructuralFinding(
        code: code,
        severity: severity,
        headline: headline,
        explanation: explanation,
        recommendation: recommendation,
        evidence: evidence,
      ),
    );

    final scheme = payload.scheme.toLowerCase();
    final host = payload.host?.toLowerCase() ?? '';
    if (!UrlAnalysisPolicy.supportedSchemes.contains(scheme)) {
      add(
        'url.unsupported_scheme',
        RiskLevel.high,
        'Unsupported link type',
        'ScanWise does not open links that use the ${scheme.isEmpty ? 'missing' : scheme} scheme.',
        'Use only a destination you expected and can verify.',
        evidence: {'scheme': scheme.isEmpty ? 'missing' : scheme},
      );
    } else if (scheme == 'http') {
      add(
        'url.http_connection',
        RiskLevel.caution,
        'Connection is not encrypted',
        'This URL uses HTTP, so information exchanged with the destination may not be encrypted.',
        'Avoid entering sensitive information unless you can verify the destination.',
      );
    }
    if (host.isEmpty) {
      add(
        'url.missing_host',
        RiskLevel.high,
        'Destination host is missing',
        'This URL does not identify a website host.',
        'Do not open it as a website link.',
      );
    }
    if (payload.hasMalformedEncoding) {
      add(
        'url.ambiguous_encoding',
        RiskLevel.high,
        'Ambiguous URL encoding',
        'The URL contains malformed or repeated percent encoding that can be interpreted inconsistently.',
        'Verify the original source before continuing.',
      );
    }
    if (payload.hasControlCharacters) {
      add(
        'url.malformed_component',
        RiskLevel.high,
        'Malformed URL component',
        'The URL contains control or invisible formatting characters.',
        'Do not continue unless you can verify the exact destination.',
      );
    }
    if (payload.hasUserInfo) {
      add(
        'url.embedded_credentials',
        RiskLevel.high,
        'Embedded credentials',
        'Text before the @ sign can make a URL look like it points somewhere other than its actual host.',
        'Check the destination host carefully before continuing.',
      );
    }
    if (payload.hasExplicitPort) {
      final defaultPort =
          (scheme == 'https' && payload.port == 443) ||
          (scheme == 'http' && payload.port == 80);
      if (defaultPort) {
        add(
          'url.explicit_default_port',
          RiskLevel.information,
          'Default port is written explicitly',
          'This URL explicitly specifies the usual ${scheme.toUpperCase()} port.',
          'No action is required, but the detail is shown for transparency.',
          evidence: {'port': '${payload.port}'},
        );
      } else if (!UrlAnalysisPolicy.commonPorts.contains(payload.port)) {
        add(
          'url.unusual_port',
          RiskLevel.caution,
          'Unusual network port',
          'This URL uses port ${payload.port} instead of the usual ${scheme == 'https' ? 'HTTPS' : 'HTTP'} port.',
          'Confirm that this port is expected for the service.',
          evidence: {'port': '${payload.port}'},
        );
      }
    }

    final address = InternetAddress.tryParse(host);
    if (address != null) {
      add(
        address.type == InternetAddressType.IPv4
            ? 'url.ipv4_host'
            : 'url.ipv6_host',
        RiskLevel.information,
        'IP-address destination',
        'This link points directly to an IP address rather than a named public host.',
        'Confirm that this numeric destination is expected.',
      );
      if (_isLoopback(address)) {
        add(
          'url.localhost',
          RiskLevel.caution,
          'Local-device destination',
          'This link points back to the current device.',
          'Open it only if you expected a local service.',
        );
      } else if (_isPrivate(address)) {
        add(
          'url.private_network_host',
          RiskLevel.caution,
          'Private-network destination',
          'This destination is reachable only on a local or private network.',
          'Confirm that you trust the current network and expected this service.',
        );
      }
    } else if (host == 'localhost' || host.endsWith('.localhost')) {
      add(
        'url.localhost',
        RiskLevel.caution,
        'Local-device destination',
        'This hostname points back to the current device.',
        'Open it only if you expected a local service.',
      );
    }

    final labels = host.split('.').where((label) => label.isNotEmpty).toList();
    if (labels.length > UrlAnalysisPolicy.maximumHostLabels) {
      add(
        'url.excessive_subdomains',
        RiskLevel.caution,
        'Deep subdomain structure',
        'The hostname has many left-side labels, which can make the actual destination harder to recognize.',
        'Review the complete destination host carefully.',
        evidence: {'labelCount': '${labels.length}'},
      );
    }
    if (labels.any((label) => label.startsWith('xn--'))) {
      add(
        'url.punycode_label',
        RiskLevel.caution,
        'Internationalized hostname',
        'This hostname contains an encoded internationalized label. It may be legitimate, but characters can look alike.',
        'Review the destination carefully.',
      );
    }
    if (host.runes.any((rune) => rune > 127)) {
      add(
        'url.unusual_unicode',
        RiskLevel.caution,
        'Unusual hostname characters',
        'This internationalized hostname contains non-ASCII characters. It may be legitimate, but review it carefully.',
        'Compare the hostname with the destination you expected.',
      );
      if (labels.any(_hasMixedScript)) {
        add(
          'url.mixed_script_label',
          RiskLevel.high,
          'Mixed writing systems',
          'A hostname label mixes writing systems, which can make characters visually misleading.',
          'Verify the hostname through a trusted source.',
        );
      }
    }
    if (UrlAnalysisPolicy.shortenerHosts.contains(host)) {
      add(
        'url.shortened_destination',
        RiskLevel.caution,
        'Shortened destination',
        'This shortened link hides its final destination until it is opened.',
        'Only continue if you trust the source of the link.',
      );
    }
    if (payload.rawUrl.length > UrlAnalysisPolicy.maximumUrlLength) {
      add(
        'url.excessive_total_length',
        RiskLevel.caution,
        'Unusually long URL',
        'This URL is longer than the conservative local-analysis threshold.',
        'Review its source and destination before continuing.',
      );
    }
    if (host.length > UrlAnalysisPolicy.maximumHostnameLength) {
      add(
        'url.excessive_hostname_length',
        RiskLevel.caution,
        'Unusually long hostname',
        'The destination hostname exceeds the normal DNS length limit.',
        'Treat the destination as malformed.',
      );
    }
    if (labels.any(
      (label) => label.length > UrlAnalysisPolicy.maximumLabelLength,
    )) {
      add(
        'url.excessive_label_length',
        RiskLevel.caution,
        'Unusually long hostname label',
        'One part of the hostname exceeds the normal DNS label length limit.',
        'Treat the destination as malformed.',
      );
    }
    if (payload.nestedUrlParameterNames.isNotEmpty) {
      add(
        'url.nested_url_parameter',
        RiskLevel.information,
        'Another URL is embedded',
        'A query parameter contains another destination URL.',
        'Review both destinations before continuing.',
        evidence: {
          'parameterNames': payload.nestedUrlParameterNames.join(', '),
        },
      );
    }

    findings.sort((a, b) {
      final severity = b.severity.index.compareTo(a.severity.index);
      return severity != 0 ? severity : a.code.compareTo(b.code);
    });
    final risk = findings.fold(
      RiskLevel.none,
      (current, finding) =>
          finding.severity.index > current.index ? finding.severity : current,
    );
    return StructuralAssessment(
      riskLevel: risk,
      headline: switch (risk) {
        RiskLevel.none => 'No obvious structural warning detected',
        RiskLevel.information => 'Review this destination',
        RiskLevel.caution => 'Review this destination',
        RiskLevel.high => 'This destination contains unusual characteristics',
      },
      explanation: risk == RiskLevel.none
          ? 'The URL has no obvious warning in ScanWise’s offline structural checks.'
          : 'ScanWise found structural details worth reviewing before you continue.',
      findings: List.unmodifiable(findings),
    );
  }

  bool _isLoopback(InternetAddress a) => a.isLoopback;
  bool _isPrivate(InternetAddress a) {
    final bytes = a.rawAddress;
    if (a.type == InternetAddressType.IPv4) {
      return bytes[0] == 10 ||
          bytes[0] == 127 ||
          (bytes[0] == 172 && bytes[1] >= 16 && bytes[1] <= 31) ||
          (bytes[0] == 192 && bytes[1] == 168) ||
          (bytes[0] == 169 && bytes[1] == 254);
    }
    return a.isLoopback ||
        (bytes[0] & 0xfe) == 0xfc ||
        (bytes[0] == 0xfe && (bytes[1] & 0xc0) == 0x80);
  }

  bool _hasMixedScript(String label) {
    var latin = false;
    var cyrillic = false;
    var greek = false;
    for (final rune in label.runes) {
      latin |=
          (rune >= 0x41 && rune <= 0x7a) || (rune >= 0xc0 && rune <= 0x24f);
      greek |= rune >= 0x370 && rune <= 0x3ff;
      cyrillic |= rune >= 0x400 && rune <= 0x52f;
    }
    return [latin, greek, cyrillic].where((present) => present).length > 1;
  }
}
