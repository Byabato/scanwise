import 'result_action_fixture.dart';
import 'result_field_fixture.dart';
import 'result_fixture_kind.dart';
import 'security_assessment_fixture.dart';

/// Temporary fixture/presentation model for Milestone 002 static UI. Not an
/// authoritative domain contract — Milestone 003 defines parsing,
/// normalization, duplicate identity and persistence models separately.
///
/// Shapes one scan result for [ScanResultView] following the 10-point
/// result hierarchy in docs/design/design-system.md: type, title,
/// interpreted details, destination/identifier, risk notice, primary
/// action, secondary actions, save controls, technical details, raw
/// payload.
class ResultFixture {
  const ResultFixture({
    required this.id,
    required this.kind,
    required this.typeLabel,
    required this.title,
    required this.primaryAction,
    required this.rawPayload,
    this.subtitle,
    this.fields = const [],
    this.security,
    this.secondaryActions = const [],
    this.technicalDetails = const [],
  });

  final String id;
  final ResultFixtureKind kind;

  /// Short type badge, e.g. "Website link", "Wi-Fi network".
  final String typeLabel;

  final String title;
  final String? subtitle;

  /// Interpreted, human-readable fields shown before any technical detail.
  final List<ResultFieldFixture> fields;

  /// Present only for URL kinds.
  final SecurityAssessmentFixture? security;

  final ResultActionFixture primaryAction;
  final List<ResultActionFixture> secondaryActions;

  /// Shown inside the collapsed-by-default technical details section.
  final List<ResultFieldFixture> technicalDetails;

  /// Shown inside the collapsed-by-default raw payload viewer.
  final String rawPayload;
}
