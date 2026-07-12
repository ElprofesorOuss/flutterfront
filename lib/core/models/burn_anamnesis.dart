class BurnAnamnesis {
  final int id;
  final int admissionId;
  final String? accidentAt;
  final String? accidentAtDisplay;
  final String? accidentPlace;
  final String? burnCause;
  final String? responsibleAgent;
  final String? exposureDuration;
  final bool lossOfConsciousness;
  final bool firstAidCooling;
  final bool firstAidAntiseptics;
  final bool firstAidEmergencyDressing;
  final String? firstAidOther;
  final String? firstAidNotes;
  final String? createdAt;
  final String? updatedAt;

  const BurnAnamnesis({
    required this.id,
    required this.admissionId,
    this.accidentAt,
    this.accidentAtDisplay,
    this.accidentPlace,
    this.burnCause,
    this.responsibleAgent,
    this.exposureDuration,
    required this.lossOfConsciousness,
    required this.firstAidCooling,
    required this.firstAidAntiseptics,
    required this.firstAidEmergencyDressing,
    this.firstAidOther,
    this.firstAidNotes,
    this.createdAt,
    this.updatedAt,
  });

  factory BurnAnamnesis.fromMap(Map<String, dynamic> map) {
    return BurnAnamnesis(
      id: map['id'] as int,
      admissionId: map['admission_id'] as int,
      accidentAt: map['accident_at'] as String?,
      accidentAtDisplay: map['accident_at_display'] as String?,
      accidentPlace: map['accident_place'] as String?,
      burnCause: map['burn_cause'] as String?,
      responsibleAgent: map['responsible_agent'] as String?,
      exposureDuration: map['exposure_duration'] as String?,
      lossOfConsciousness: map['loss_of_consciousness'] == true,
      firstAidCooling: map['first_aid_cooling'] == true,
      firstAidAntiseptics: map['first_aid_antiseptics'] == true,
      firstAidEmergencyDressing: map['first_aid_emergency_dressing'] == true,
      firstAidOther: map['first_aid_other'] as String?,
      firstAidNotes: map['first_aid_notes'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (accidentAt != null) 'accident_at': accidentAt,
      if (accidentPlace != null) 'accident_place': accidentPlace,
      if (burnCause != null) 'burn_cause': burnCause,
      if (responsibleAgent != null) 'responsible_agent': responsibleAgent,
      if (exposureDuration != null) 'exposure_duration': exposureDuration,
      'loss_of_consciousness': lossOfConsciousness,
      'first_aid_cooling': firstAidCooling,
      'first_aid_antiseptics': firstAidAntiseptics,
      'first_aid_emergency_dressing': firstAidEmergencyDressing,
      if (firstAidOther != null) 'first_aid_other': firstAidOther,
      if (firstAidNotes != null) 'first_aid_notes': firstAidNotes,
    };
  }
}
