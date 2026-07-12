class BurnClassification {
  final int admissionId;
  final String burnDegreeSummary;
  final String burnDepthSummary;
  final double tbsaPercentage;
  final List<CriticalArea> criticalAreas;
  final bool inhalationInjury;
  final bool deepBurnPresent;
  final String? highestDegree;
  final String severityLevel;
  final int severityScore;
  final String classificationNotes;
  final List<TriggeredRule> triggeredRules;

  BurnClassification({
    required this.admissionId,
    required this.burnDegreeSummary,
    required this.burnDepthSummary,
    required this.tbsaPercentage,
    required this.criticalAreas,
    required this.inhalationInjury,
    required this.deepBurnPresent,
    this.highestDegree,
    required this.severityLevel,
    required this.severityScore,
    required this.classificationNotes,
    required this.triggeredRules,
  });

  factory BurnClassification.fromMap(Map<String, dynamic> map) {
    return BurnClassification(
      admissionId: map['admission_id'] as int,
      burnDegreeSummary: map['burn_degree_summary'] as String,
      burnDepthSummary: map['burn_depth_summary'] as String,
      tbsaPercentage: (map['tbsa_percentage'] as num).toDouble(),
      criticalAreas: (map['critical_areas'] as List<dynamic>?)
              ?.map((e) => CriticalArea.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      inhalationInjury: map['inhalation_injury'] as bool,
      deepBurnPresent: map['deep_burn_present'] as bool,
      highestDegree: map['highest_degree'] as String?,
      severityLevel: map['severity_level'] as String,
      severityScore: map['severity_score'] as int,
      classificationNotes: map['classification_notes'] as String,
      triggeredRules: (map['triggered_rules'] as List<dynamic>?)
              ?.map((e) => TriggeredRule.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() => {
        'admission_id': admissionId,
        'burn_degree_summary': burnDegreeSummary,
        'burn_depth_summary': burnDepthSummary,
        'tbsa_percentage': tbsaPercentage,
        'critical_areas': criticalAreas.map((e) => e.toMap()).toList(),
        'inhalation_injury': inhalationInjury,
        'deep_burn_present': deepBurnPresent,
        'highest_degree': highestDegree,
        'severity_level': severityLevel,
        'severity_score': severityScore,
        'classification_notes': classificationNotes,
        'triggered_rules': triggeredRules.map((e) => e.toMap()).toList(),
      };

  String get severityLabel {
    switch (severityLevel) {
      case 'legere':
        return 'Légère';
      case 'moderee':
        return 'Modérée';
      case 'severe':
        return 'Sévère';
      case 'critique':
        return 'Critique';
      default:
        return severityLevel;
    }
  }
}

class CriticalArea {
  final String key;
  final String label;
  final List<String> bodyParts;
  final String maxDegree;
  final String maxDegreeLabel;

  CriticalArea({
    required this.key,
    required this.label,
    required this.bodyParts,
    required this.maxDegree,
    required this.maxDegreeLabel,
  });

  factory CriticalArea.fromMap(Map<String, dynamic> map) {
    return CriticalArea(
      key: map['key'] as String,
      label: map['label'] as String,
      bodyParts: (map['body_parts'] as List<dynamic>).cast<String>(),
      maxDegree: map['max_degree'] as String,
      maxDegreeLabel: map['max_degree_label'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'key': key,
        'label': label,
        'body_parts': bodyParts,
        'max_degree': maxDegree,
        'max_degree_label': maxDegreeLabel,
      };
}

class TriggeredRule {
  final String rule;
  final int points;
  final String detail;

  TriggeredRule({
    required this.rule,
    required this.points,
    required this.detail,
  });

  factory TriggeredRule.fromMap(Map<String, dynamic> map) {
    return TriggeredRule(
      rule: map['rule'] as String,
      points: map['points'] as int,
      detail: map['detail'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'rule': rule,
        'points': points,
        'detail': detail,
      };
}
