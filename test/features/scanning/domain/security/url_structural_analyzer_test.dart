import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/features/scanning/domain/entities/scan_payload.dart';
import 'package:scanwise/features/scanning/domain/parsing/parsers/url_parser.dart';
import 'package:scanwise/features/scanning/domain/parsing/scan_parse_result.dart';
import 'package:scanwise/features/scanning/domain/security/risk_level.dart';
import 'package:scanwise/features/scanning/domain/security/url_analysis_policy.dart';
import 'package:scanwise/features/scanning/domain/security/url_structural_analyzer.dart';

import '../../support/candidate.dart';

void main() {
  const analyzer = UrlStructuralAnalyzer();
  const parser = UrlParser();

  Set<String> codes(String value) {
    final parsed = parser.parse(candidate(value)) as ScanParseSuccess;
    return analyzer
        .analyze(parsed.payload as UrlPayload)
        .findings
        .map((finding) => finding.code)
        .toSet();
  }

  UrlPayload payloadFor(String value) =>
      (parser.parse(candidate(value)) as ScanParseSuccess).payload
          as UrlPayload;

  test('ordinary HTTPS has no structural findings', () {
    final assessment = analyzer.analyze(
      payloadFor('HTTPS://Example.COM/path?x=1#part'),
    );
    expect(assessment.riskLevel, RiskLevel.none);
    expect(assessment.findings, isEmpty);
  });

  test('scheme, credentials, and ports are deterministic', () {
    expect(codes('http://example.com'), contains('url.http_connection'));
    expect(codes('ftp://example.com'), contains('url.unsupported_scheme'));
    expect(
      codes('https://user:secret@example.com'),
      contains('url.embedded_credentials'),
    );
    expect(
      codes('https://example.com:443'),
      contains('url.explicit_default_port'),
    );
    expect(codes('https://example.com:9443'), contains('url.unusual_port'));
  });

  test('IP, local, and private hosts are contextual findings', () {
    expect(codes('https://8.8.8.8'), contains('url.ipv4_host'));
    expect(codes('https://127.0.0.1'), contains('url.localhost'));
    expect(codes('https://192.168.1.2'), contains('url.private_network_host'));
    expect(
      codes('https://[::1]'),
      containsAll(['url.ipv6_host', 'url.localhost']),
    );
  });

  test(
    'subdomains, internationalized hosts, and shorteners are recognized',
    () {
      expect(
        codes('https://a.b.c.d.e.f.example.com'),
        contains('url.excessive_subdomains'),
      );
      expect(
        codes('https://xn--bcher-kva.example'),
        contains('url.punycode_label'),
      );
      expect(
        codes('https://bit.ly/abc'),
        contains('url.shortened_destination'),
      );
      expect(
        codes('https://news.bit.ly/abc'),
        isNot(contains('url.shortened_destination')),
      );
    },
  );

  test('length thresholds have covered boundaries', () {
    final atBoundary =
        'https://example.com/${'a' * (UrlAnalysisPolicy.maximumUrlLength - 20)}';
    final overBoundary = '$atBoundary/a';
    expect(atBoundary.length, UrlAnalysisPolicy.maximumUrlLength);
    expect(codes(atBoundary), isNot(contains('url.excessive_total_length')));
    expect(codes(overBoundary), contains('url.excessive_total_length'));
  });

  test('nested destinations and malformed encoding do not expose values', () {
    final nested = analyzer.analyze(
      payloadFor(
        'https://example.com/go?next=https%3A%2F%2Fprivate.example%2Ftoken',
      ),
    );
    final finding = nested.findings.singleWhere(
      (finding) => finding.code == 'url.nested_url_parameter',
    );
    expect(finding.evidence, {'parameterNames': 'next'});
    expect(finding.evidence.toString(), isNot(contains('token')));
    expect(
      codes('https://example.com/%zz'),
      contains('url.ambiguous_encoding'),
    );
  });

  test('aggregation and ordering use highest severity then code', () {
    final payload = payloadFor('http://user:secret@127.0.0.1:9443');
    final first = analyzer.analyze(payload);
    final second = analyzer.analyze(payload);
    expect(first.riskLevel, RiskLevel.high);
    expect(
      first.findings.map((finding) => finding.code),
      second.findings.map((finding) => finding.code),
    );
    final severities = first.findings
        .map((finding) => finding.severity.index)
        .toList();
    expect(
      severities,
      orderedEquals([...severities]..sort((a, b) => b.compareTo(a))),
    );
  });

  group('host forms', () {
    test('IPv6 private/local ranges are recognized', () {
      expect(
        codes('https://[fc00::1]'),
        containsAll(['url.ipv6_host', 'url.private_network_host']),
      );
      expect(
        codes('https://[fe80::1]'),
        containsAll(['url.ipv6_host', 'url.private_network_host']),
      );
    });

    test('a public IP has no local/private finding', () {
      final found = codes('https://8.8.8.8');
      expect(found, contains('url.ipv4_host'));
      expect(found, isNot(contains('url.localhost')));
      expect(found, isNot(contains('url.private_network_host')));
    });

    test('an invalid IP-like host is treated as an ordinary hostname', () {
      expect(codes('https://999.999.999.999'), isEmpty);
    });
  });

  group('credentials', () {
    test('username only is flagged', () {
      expect(
        codes('https://user@example.com'),
        contains('url.embedded_credentials'),
      );
    });

    test('encoded user-info is flagged without breaking parsing', () {
      final found = codes('https://us%65r:pa%2442@example.com');
      expect(found, contains('url.embedded_credentials'));
      expect(found, isNot(contains('url.ambiguous_encoding')));
    });

    test(
      'misleading host-like text before @ is flagged and the real host wins',
      () {
        final payload = payloadFor(
          'https://accounts.google.com.verify@evil.example/path',
        );
        expect(payload.host, 'evil.example');
        expect(
          analyzer.analyze(payload).findings.map((f) => f.code),
          contains('url.embedded_credentials'),
        );
      },
    );
  });

  group('subdomains', () {
    test('exactly five labels is not excessive', () {
      expect(
        codes('https://a.b.c.example.com'),
        isNot(contains('url.excessive_subdomains')),
      );
    });

    test('six labels is excessive', () {
      expect(
        codes('https://a.b.c.d.example.com'),
        contains('url.excessive_subdomains'),
      );
    });
  });

  group('internationalized hosts', () {
    // Every non-ASCII character below is built from an explicit code
    // point (String.fromCharCode/fromCharCodes) rather than a literal
    // source character, so the exact code point under test is
    // unambiguous on review and in diffs, and the source file never
    // embeds a raw bidi-control or combining character.
    test('a legitimate non-ASCII single-script host is not mixed-script', () {
      // "b" + u-with-diaeresis (U+00FC) + "cher" — Latin Extended-A,
      // single script.
      final label = 'b${String.fromCharCode(0xfc)}cher';
      final found = codes('https://$label.example');
      expect(found, contains('url.unusual_unicode'));
      expect(found, isNot(contains('url.mixed_script_label')));
    });

    test('a label mixing Latin and Cyrillic characters is flagged', () {
      // Cyrillic "а" (U+0430) substituted into an otherwise-Latin label.
      final host = 'ex${String.fromCharCode(0x430)}mple.com';
      final found = codes('https://$host');
      expect(found, contains('url.mixed_script_label'));
      expect(found, contains('url.unusual_unicode'));
    });

    test('a zero-width space is flagged as malformed', () {
      final path = '/ab${String.fromCharCode(0x200b)}cd'; // ZERO WIDTH SPACE
      expect(
        codes('https://example.com$path'),
        contains('url.malformed_component'),
      );
    });

    test('a directional-override character is flagged as malformed', () {
      // U+202E RIGHT-TO-LEFT OVERRIDE, the classic filename-spoofing
      // character (e.g. making "exe.txt" display as "txt.exe").
      final path = '/file${String.fromCharCode(0x202e)}txt.exe';
      expect(
        codes('https://example.com$path'),
        contains('url.malformed_component'),
      );
    });

    test('composed and decomposed Unicode forms both flag unusual characters '
        'deterministically (no normalization or confusable comparison is '
        'attempted)', () {
      // "cafe" + precomposed e-acute (U+00E9) — NFC form.
      final composed =
          '${String.fromCharCodes([0x63, 0x61, 0x66, 0xe9])}.example';
      // "cafe" + combining acute accent (U+0301) — NFD form.
      final decomposed =
          '${String.fromCharCodes([0x63, 0x61, 0x66, 0x65, 0x301])}.example';
      expect(composed, isNot(decomposed));
      expect(codes('https://$composed'), contains('url.unusual_unicode'));
      expect(codes('https://$decomposed'), contains('url.unusual_unicode'));
    });
  });

  group('shorteners', () {
    test('an unrecognized short host is not flagged', () {
      expect(
        codes('https://short.example/abc'),
        isNot(contains('url.shortened_destination')),
      );
    });

    test('shortener matching is case-insensitive', () {
      expect(
        codes('https://BIT.LY/abc'),
        contains('url.shortened_destination'),
      );
    });
  });

  group('length boundaries', () {
    test('hostname length: at, one below, and one above the threshold', () {
      String hostOfLength(int labelTailLength) =>
          '${'a' * 60}.${'a' * 60}.${'a' * 60}.${'a' * 60}.${'a' * labelTailLength}';
      final atBoundary = hostOfLength(9); // total length 253
      final oneBelow = hostOfLength(8); // total length 252
      final oneAbove = hostOfLength(10); // total length 254
      expect(atBoundary.length, UrlAnalysisPolicy.maximumHostnameLength);
      expect(
        codes('https://$atBoundary'),
        isNot(contains('url.excessive_hostname_length')),
      );
      expect(
        codes('https://$oneBelow'),
        isNot(contains('url.excessive_hostname_length')),
      );
      expect(
        codes('https://$oneAbove'),
        contains('url.excessive_hostname_length'),
      );
    });

    test('label length: at and one above the threshold', () {
      final atBoundary = 'a' * UrlAnalysisPolicy.maximumLabelLength;
      final oneAbove = 'a' * (UrlAnalysisPolicy.maximumLabelLength + 1);
      expect(
        codes('https://$atBoundary.example.com'),
        isNot(contains('url.excessive_label_length')),
      );
      expect(
        codes('https://$oneAbove.example.com'),
        contains('url.excessive_label_length'),
      );
    });
  });

  group('malformed and missing components', () {
    test('a missing host is flagged as high severity', () {
      final assessment = analyzer.analyze(payloadFor('https:///path'));
      expect(
        assessment.findings.map((f) => f.code),
        contains('url.missing_host'),
      );
      expect(assessment.riskLevel, RiskLevel.high);
    });

    test('an unsupported scheme is flagged as high severity', () {
      final assessment = analyzer.analyze(payloadFor('ftp://example.com'));
      expect(assessment.riskLevel, RiskLevel.high);
    });
  });

  group('aggregation by isolated severity', () {
    test('no findings yields none', () {
      final assessment = analyzer.analyze(payloadFor('https://example.com'));
      expect(assessment.riskLevel, RiskLevel.none);
      expect(assessment.headline, 'No obvious structural warning detected');
    });

    test('an information-only finding yields information', () {
      final assessment = analyzer.analyze(
        payloadFor('https://example.com:443'),
      );
      expect(assessment.riskLevel, RiskLevel.information);
      expect(assessment.findings.single.code, 'url.explicit_default_port');
    });

    test('a caution-only finding yields caution', () {
      final assessment = analyzer.analyze(payloadFor('http://example.com'));
      expect(assessment.riskLevel, RiskLevel.caution);
      expect(assessment.findings.single.code, 'url.http_connection');
    });

    test('a high-only finding yields high', () {
      final assessment = analyzer.analyze(payloadFor('ftp://example.com'));
      expect(assessment.riskLevel, RiskLevel.high);
      expect(assessment.findings.single.code, 'url.unsupported_scheme');
    });
  });
}
