class BurnInjury {
  final int? id;
  final String bodyPart;
  final String degree;
  final double surfaceArea;

  BurnInjury({
    this.id,
    required this.bodyPart,
    required this.degree,
    required this.surfaceArea,
  });

  factory BurnInjury.fromMap(Map<String, dynamic> map) {
    return BurnInjury(
      id: map['id'] as int?,
      bodyPart: map['body_part'] as String,
      degree: map['degree'] as String,
      surfaceArea: (map['surface_area'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'body_part': bodyPart,
        'degree': degree,
        'surface_area': surfaceArea,
      };

  BurnInjury copyWith({
    int? id,
    String? bodyPart,
    String? degree,
    double? surfaceArea,
  }) {
    return BurnInjury(
      id: id ?? this.id,
      bodyPart: bodyPart ?? this.bodyPart,
      degree: degree ?? this.degree,
      surfaceArea: surfaceArea ?? this.surfaceArea,
    );
  }

  String get degreeLabel {
    switch (degree) {
      case '1st':
        return '1er degré';
      case '2nd_superficial':
        return '2e superficiel';
      case '2nd_deep':
        return '2e profond';
      case '3rd':
        return '3e degré';
      default:
        return degree;
    }
  }
}

class BurnInjuryResponse {
  final List<BurnInjury> zones;
  final double tbsaPercentage;

  BurnInjuryResponse({
    required this.zones,
    required this.tbsaPercentage,
  });

  factory BurnInjuryResponse.fromMap(Map<String, dynamic> map) {
    return BurnInjuryResponse(
      zones: (map['zones'] as List<dynamic>)
          .map((e) => BurnInjury.fromMap(e as Map<String, dynamic>))
          .toList(),
      tbsaPercentage: (map['tbsa_percentage'] as num).toDouble(),
    );
  }
}
