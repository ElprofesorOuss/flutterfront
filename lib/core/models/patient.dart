class Patient {
  final int id;
  final String ipp;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? birthDate;
  final int? age;
  final String? gender;
  final String? medicalRecordNumber;
  final String? address;
  final String? phone;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? knownAllergies;
  final String? medicalHistory;
  final String? surgicalHistory;
  final String? createdAt;
  final String? updatedAt;
  final LatestAdmission? latestAdmission;

  const Patient({
    required this.id,
    required this.ipp,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.birthDate,
    this.age,
    this.gender,
    this.medicalRecordNumber,
    this.address,
    this.phone,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.knownAllergies,
    this.medicalHistory,
    this.surgicalHistory,
    this.createdAt,
    this.updatedAt,
    this.latestAdmission,
  });

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] as int,
      ipp: map['ipp'] as String? ?? '',
      firstName: map['first_name'] as String? ?? '',
      lastName: map['last_name'] as String? ?? '',
      fullName: map['full_name'] as String? ?? '',
      birthDate: map['birth_date'] as String?,
      age: map['age'] as int?,
      gender: map['gender'] as String?,
      medicalRecordNumber: map['medical_record_number'] as String?,
      address: map['address'] as String?,
      phone: map['phone'] as String?,
      emergencyContactName: map['emergency_contact_name'] as String?,
      emergencyContactPhone: map['emergency_contact_phone'] as String?,
      knownAllergies: map['known_allergies'] as String?,
      medicalHistory: map['medical_history'] as String?,
      surgicalHistory: map['surgical_history'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
      latestAdmission: map['latest_admission'] != null
          ? LatestAdmission.fromMap(Map<String, dynamic>.from(map['latest_admission']))
          : null,
    );
  }

  String get initials => '${lastName.isNotEmpty ? lastName[0] : ''}${firstName.isNotEmpty ? firstName[0] : ''}';
  bool get isFemale => gender?.toLowerCase().startsWith('f') == true || gender?.toLowerCase().startsWith('fem') == true;
}

class LatestAdmission {
  final int id;
  final String? visitNumber;
  final double tbsaPercentage;
  final String? status;
  final String? admittedAt;
  final bool inhalationInjury;
  final String? severityLevel;
  final String? severityLevelDisplay;
  final int? severityScore;
  final LitInfo? lit;
  final String? burnCause;

  const LatestAdmission({
    required this.id,
    this.visitNumber,
    required this.tbsaPercentage,
    this.status,
    this.admittedAt,
    required this.inhalationInjury,
    this.severityLevel,
    this.severityLevelDisplay,
    this.severityScore,
    this.lit,
    this.burnCause,
  });

  factory LatestAdmission.fromMap(Map<String, dynamic> map) {
    return LatestAdmission(
      id: map['id'] as int,
      visitNumber: map['visit_number'] as String?,
      tbsaPercentage: (map['tbsa_percentage'] as num?)?.toDouble() ?? 0,
      status: map['status'] as String?,
      admittedAt: map['admitted_at'] as String?,
      inhalationInjury: map['inhalation_injury'] == true,
      severityLevel: map['severity_level'] as String?,
      severityLevelDisplay: map['severity_level_display'] as String?,
      severityScore: map['severity_score'] as int?,
      lit: map['lit'] != null ? LitInfo.fromMap(Map<String, dynamic>.from(map['lit'])) : null,
      burnCause: map['burn_cause'] as String?,
    );
  }

  String get bedCode => lit?.code ?? 'N/A';
}

class LitInfo {
  final int id;
  final String? code;

  const LitInfo({required this.id, this.code});

  factory LitInfo.fromMap(Map<String, dynamic> map) {
    return LitInfo(
      id: map['id'] as int,
      code: map['code'] as String?,
    );
  }
}
