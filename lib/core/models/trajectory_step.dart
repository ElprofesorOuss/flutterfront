class TrajectoryStep {
  final int id;
  final int? patientId;
  final int? admissionId;
  final String stepType;
  final String stepTypeLabel;
  final String stepTypeColor;
  final String stepTypeIcon;
  final String? stepDate;
  final String stepDateDisplay;
  final String stepDateShort;
  final String status;
  final String statusLabel;
  final String statusColor;
  final String? unitName;
  final String title;
  final String? summary;
  final String? details;
  final bool isCurrent;
  final bool complicationFlag;
  final String? complicationType;
  final String? nextAction;
  final String? nextActionDate;
  final String? outcome;
  final int sortOrder;
  final PerformedBy? performedBy;
  final AdmissionRef? admission;

  TrajectoryStep({
    required this.id,
    this.patientId,
    this.admissionId,
    required this.stepType,
    required this.stepTypeLabel,
    required this.stepTypeColor,
    required this.stepTypeIcon,
    this.stepDate,
    required this.stepDateDisplay,
    required this.stepDateShort,
    required this.status,
    required this.statusLabel,
    required this.statusColor,
    this.unitName,
    required this.title,
    this.summary,
    this.details,
    required this.isCurrent,
    required this.complicationFlag,
    this.complicationType,
    this.nextAction,
    this.nextActionDate,
    this.outcome,
    required this.sortOrder,
    this.performedBy,
    this.admission,
  });

  factory TrajectoryStep.fromMap(Map<String, dynamic> map) {
    return TrajectoryStep(
      id: map['id'] as int,
      patientId: map['patient_id'] as int?,
      admissionId: map['admission_id'] as int?,
      stepType: map['step_type'] as String,
      stepTypeLabel: map['step_type_label'] as String,
      stepTypeColor: map['step_type_color'] as String,
      stepTypeIcon: map['step_type_icon'] as String,
      stepDate: map['step_date'] as String?,
      stepDateDisplay: map['step_date_display'] as String,
      stepDateShort: map['step_date_short'] as String,
      status: map['status'] as String,
      statusLabel: map['status_label'] as String,
      statusColor: map['status_color'] as String,
      unitName: map['unit_name'] as String?,
      title: map['title'] as String,
      summary: map['summary'] as String?,
      details: map['details'] as String?,
      isCurrent: map['is_current'] as bool,
      complicationFlag: map['complication_flag'] as bool,
      complicationType: map['complication_type'] as String?,
      nextAction: map['next_action'] as String?,
      nextActionDate: map['next_action_date'] as String?,
      outcome: map['outcome'] as String?,
      sortOrder: map['sort_order'] as int,
      performedBy: map['performed_by'] != null
          ? PerformedBy.fromMap(map['performed_by'] as Map<String, dynamic>)
          : null,
      admission: map['admission'] != null
          ? AdmissionRef.fromMap(map['admission'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PerformedBy {
  final int id;
  final String name;

  PerformedBy({required this.id, required this.name});

  factory PerformedBy.fromMap(Map<String, dynamic> map) {
    return PerformedBy(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }
}

class AdmissionRef {
  final int id;
  final double tbsaPercentage;
  final String status;

  AdmissionRef({
    required this.id,
    required this.tbsaPercentage,
    required this.status,
  });

  factory AdmissionRef.fromMap(Map<String, dynamic> map) {
    return AdmissionRef(
      id: map['id'] as int,
      tbsaPercentage: (map['tbsa_percentage'] as num).toDouble(),
      status: map['status'] as String,
    );
  }
}

class TrajectorySummary {
  final int totalSteps;
  final int completed;
  final int planned;
  final int complications;
  final int? totalDurationDays;
  final TrajectoryStep? currentStep;

  TrajectorySummary({
    required this.totalSteps,
    required this.completed,
    required this.planned,
    required this.complications,
    this.totalDurationDays,
    this.currentStep,
  });

  factory TrajectorySummary.fromMap(Map<String, dynamic> map) {
    return TrajectorySummary(
      totalSteps: map['total_steps'] as int,
      completed: map['completed'] as int,
      planned: map['planned'] as int,
      complications: map['complications'] as int,
      totalDurationDays: map['total_duration_days'] as int?,
      currentStep: map['current_step'] != null
          ? TrajectoryStep.fromMap(map['current_step'] as Map<String, dynamic>)
          : null,
    );
  }
}

class TrajectoryResponse {
  final PatientInfo? patient;
  final AdmissionSummary? admissionSummary;
  final List<TrajectoryStep> steps;
  final TrajectorySummary summary;

  TrajectoryResponse({
    this.patient,
    this.admissionSummary,
    required this.steps,
    required this.summary,
  });

  factory TrajectoryResponse.fromMap(Map<String, dynamic> map) {
    return TrajectoryResponse(
      patient: map['patient'] != null
          ? PatientInfo.fromMap(map['patient'] as Map<String, dynamic>)
          : null,
      admissionSummary: map['admission_summary'] != null
          ? AdmissionSummary.fromMap(
              map['admission_summary'] as Map<String, dynamic>)
          : null,
      steps: (map['steps'] as List<dynamic>)
          .map((e) => TrajectoryStep.fromMap(e as Map<String, dynamic>))
          .toList(),
      summary:
          TrajectorySummary.fromMap(map['summary'] as Map<String, dynamic>),
    );
  }
}

class PatientInfo {
  final int id;
  final String ipp;
  final String firstName;
  final String lastName;
  final String gender;
  final int? age;

  PatientInfo({
    required this.id,
    required this.ipp,
    required this.firstName,
    required this.lastName,
    required this.gender,
    this.age,
  });

  factory PatientInfo.fromMap(Map<String, dynamic> map) {
    return PatientInfo(
      id: map['id'] as int,
      ipp: map['ipp'] as String,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      gender: map['gender'] as String,
      age: map['age'] as int?,
    );
  }
}

class AdmissionSummary {
  final double tbsaPercentage;
  final String? burnCause;
  final String? highestDegree;
  final String? highestDegreeLabel;

  AdmissionSummary({
    required this.tbsaPercentage,
    this.burnCause,
    this.highestDegree,
    this.highestDegreeLabel,
  });

  factory AdmissionSummary.fromMap(Map<String, dynamic> map) {
    return AdmissionSummary(
      tbsaPercentage: (map['tbsa_percentage'] as num).toDouble(),
      burnCause: map['burn_cause'] as String?,
      highestDegree: map['highest_degree'] as String?,
      highestDegreeLabel: map['highest_degree_label'] as String?,
    );
  }
}
