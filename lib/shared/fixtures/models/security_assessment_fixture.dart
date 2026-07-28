/// Temporary fixture/presentation model for Milestone 002 static UI. Not an
/// authoritative domain contract — Milestone 003 defines parsing,
/// normalization, duplicate identity and persistence models separately.
///
/// Language on every fixture using this model must stay within
/// docs/product/non-goals.md's security limitations: structural signals
/// only, never a certainty claim about live safety or reputation.
enum ResultRiskLevel { none, information, caution, high, critical }

class SecurityFindingFixture {
  const SecurityFindingFixture({
    required this.code,
    required this.title,
    required this.explanation,
  });

  final String code;
  final String title;
  final String explanation;
}

class SecurityAssessmentFixture {
  const SecurityAssessmentFixture({
    required this.severity,
    required this.headline,
    required this.explanation,
    this.findings = const [],
  });

  final ResultRiskLevel severity;
  final String headline;
  final String explanation;
  final List<SecurityFindingFixture> findings;
}
