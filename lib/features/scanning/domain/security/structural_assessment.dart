import 'risk_level.dart';
import 'structural_finding.dart';

class StructuralAssessment {
  const StructuralAssessment({
    required this.riskLevel,
    required this.headline,
    required this.explanation,
    required this.findings,
  });

  final RiskLevel riskLevel;
  final String headline;
  final String explanation;
  final List<StructuralFinding> findings;
}
