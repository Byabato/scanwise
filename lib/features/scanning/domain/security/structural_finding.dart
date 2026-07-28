import 'risk_level.dart';

class StructuralFinding {
  const StructuralFinding({
    required this.code,
    required this.severity,
    required this.headline,
    required this.explanation,
    required this.recommendation,
    this.technicalDetail,
    this.evidence = const {},
  });

  final String code;
  final RiskLevel severity;
  final String headline;
  final String explanation;
  final String recommendation;
  final String? technicalDetail;
  final Map<String, String> evidence;
}
