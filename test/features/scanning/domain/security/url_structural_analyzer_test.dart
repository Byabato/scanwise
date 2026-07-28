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

  test('ordinary HTTPS has no structural findings', () {
    final assessment = analyzer.analyze(
      (parser.parse(candidate('HTTPS://Example.COM/path?x=1#part'))
                  as ScanParseSuccess)
              .payload
          as UrlPayload,
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
      (parser.parse(
                    candidate(
                      'https://example.com/go?next=https%3A%2F%2Fprivate.example%2Ftoken',
                    ),
                  )
                  as ScanParseSuccess)
              .payload
          as UrlPayload,
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
    final payload =
        (parser.parse(candidate('http://user:secret@127.0.0.1:9443'))
                    as ScanParseSuccess)
                .payload
            as UrlPayload;
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
}
