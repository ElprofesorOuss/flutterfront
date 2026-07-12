class InitialAssessment {
  final int? id;
  final int? admissionId;
  final int? glasgowScore;
  final String? generalState;
  final int? systolicBp;
  final int? diastolicBp;
  final int? heartRate;
  final int? respRate;
  final double? temperature;
  final int? spo2;
  final int? painEva;
  final String? psychologicalState;
  final String? createdAt;

  const InitialAssessment({
    this.id,
    this.admissionId,
    this.glasgowScore,
    this.generalState,
    this.systolicBp,
    this.diastolicBp,
    this.heartRate,
    this.respRate,
    this.temperature,
    this.spo2,
    this.painEva,
    this.psychologicalState,
    this.createdAt,
  });

  factory InitialAssessment.fromMap(Map<String, dynamic> map) {
    return InitialAssessment(
      id: map['id'] is int ? map['id'] : int.tryParse('${map['id']}'),
      admissionId: map['admission_id'] is int
          ? map['admission_id']
          : int.tryParse('${map['admission_id']}'),
      glasgowScore: map['glasgow_score'] is int
          ? map['glasgow_score']
          : int.tryParse('${map['glasgow_score']}'),
      generalState: map['general_state'],
      systolicBp: map['systolic_bp'] is int
          ? map['systolic_bp']
          : int.tryParse('${map['systolic_bp']}'),
      diastolicBp: map['diastolic_bp'] is int
          ? map['diastolic_bp']
          : int.tryParse('${map['diastolic_bp']}'),
      heartRate: map['heart_rate'] is int
          ? map['heart_rate']
          : int.tryParse('${map['heart_rate']}'),
      respRate: map['resp_rate'] is int
          ? map['resp_rate']
          : int.tryParse('${map['resp_rate']}'),
      temperature: map['temperature'] is double
          ? map['temperature']
          : double.tryParse('${map['temperature']}'),
      spo2: map['spo2'] is int
          ? map['spo2']
          : int.tryParse('${map['spo2']}'),
      painEva: map['pain_eva'] is int
          ? map['pain_eva']
          : int.tryParse('${map['pain_eva']}'),
      psychologicalState: map['psychological_state'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (glasgowScore != null) 'glasgow_score': glasgowScore,
      if (generalState != null) 'general_state': generalState,
      if (systolicBp != null) 'systolic_bp': systolicBp,
      if (diastolicBp != null) 'diastolic_bp': diastolicBp,
      if (heartRate != null) 'heart_rate': heartRate,
      if (respRate != null) 'resp_rate': respRate,
      if (temperature != null) 'temperature': temperature,
      if (spo2 != null) 'spo2': spo2,
      if (painEva != null) 'pain_eva': painEva,
      if (psychologicalState != null) 'psychological_state': psychologicalState,
    };
  }
}
