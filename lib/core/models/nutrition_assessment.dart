class NutritionAssessment {
  final int id;
  final int admissionId;
  final int patientId;
  final String evaluationDate;
  final String? evaluationDateDisplay;
  final double weightKg;
  final double? usualWeightKg;
  final double? heightCm;
  final double? bmi;
  final double? weightVariationPercent;
  final String nutritionRoute;
  final String nutritionRouteLabel;
  final String? feedingStartedAt;
  final double energyNeedKcal;
  final double proteinNeedG;
  final double? caloriesReceivedKcal;
  final double? proteinReceivedG;
  final double? caloricCoveragePercent;
  final double? proteinCoveragePercent;
  final bool? isCaloricAlert;
  final bool? isProteinAlert;
  final bool? isWeightLossAlert;
  final bool? isLowAlbuminAlert;
  final double? albuminGL;
  final double? prealbuminMgL;
  final String? digestiveTolerance;
  final String? digestiveToleranceLabel;
  final bool? vomiting;
  final bool? diarrhea;
  final String? nutritionRiskLevel;
  final String? nutritionRiskLevelLabel;
  final String? nutritionStatus;
  final String? nutritionStatusLabel;
  final String? notes;
  final Map<String, dynamic>? createdBy;
  final String? createdAt;
  final String? updatedAt;

  const NutritionAssessment({
    required this.id,
    required this.admissionId,
    required this.patientId,
    required this.evaluationDate,
    this.evaluationDateDisplay,
    required this.weightKg,
    this.usualWeightKg,
    this.heightCm,
    this.bmi,
    this.weightVariationPercent,
    required this.nutritionRoute,
    required this.nutritionRouteLabel,
    this.feedingStartedAt,
    required this.energyNeedKcal,
    required this.proteinNeedG,
    this.caloriesReceivedKcal,
    this.proteinReceivedG,
    this.caloricCoveragePercent,
    this.proteinCoveragePercent,
    this.isCaloricAlert,
    this.isProteinAlert,
    this.isWeightLossAlert,
    this.isLowAlbuminAlert,
    this.albuminGL,
    this.prealbuminMgL,
    this.digestiveTolerance,
    this.digestiveToleranceLabel,
    this.vomiting,
    this.diarrhea,
    this.nutritionRiskLevel,
    this.nutritionRiskLevelLabel,
    this.nutritionStatus,
    this.nutritionStatusLabel,
    this.notes,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory NutritionAssessment.fromMap(Map<String, dynamic> map) {
    return NutritionAssessment(
      id: map['id'] as int,
      admissionId: map['admission_id'] as int,
      patientId: map['patient_id'] as int,
      evaluationDate: map['evaluation_date'] as String? ?? '',
      evaluationDateDisplay: map['evaluation_date_display'] as String?,
      weightKg: (map['weight_kg'] as num?)?.toDouble() ?? 0,
      usualWeightKg: (map['usual_weight_kg'] as num?)?.toDouble(),
      heightCm: (map['height_cm'] as num?)?.toDouble(),
      bmi: (map['bmi'] as num?)?.toDouble(),
      weightVariationPercent: (map['weight_variation_percent'] as num?)?.toDouble(),
      nutritionRoute: map['nutrition_route'] as String? ?? 'orale',
      nutritionRouteLabel: map['nutrition_route_label'] as String? ?? 'Orale',
      feedingStartedAt: map['feeding_started_at'] as String?,
      energyNeedKcal: (map['energy_need_kcal'] as num?)?.toDouble() ?? 0,
      proteinNeedG: (map['protein_need_g'] as num?)?.toDouble() ?? 0,
      caloriesReceivedKcal: (map['calories_received_kcal'] as num?)?.toDouble(),
      proteinReceivedG: (map['protein_received_g'] as num?)?.toDouble(),
      caloricCoveragePercent: (map['caloric_coverage_percent'] as num?)?.toDouble(),
      proteinCoveragePercent: (map['protein_coverage_percent'] as num?)?.toDouble(),
      isCaloricAlert: map['is_caloric_alert'] as bool?,
      isProteinAlert: map['is_protein_alert'] as bool?,
      isWeightLossAlert: map['is_weight_loss_alert'] as bool?,
      isLowAlbuminAlert: map['is_low_albumin_alert'] as bool?,
      albuminGL: (map['albumin_g_l'] as num?)?.toDouble(),
      prealbuminMgL: (map['prealbumin_mg_l'] as num?)?.toDouble(),
      digestiveTolerance: map['digestive_tolerance'] as String?,
      digestiveToleranceLabel: map['digestive_tolerance_label'] as String?,
      vomiting: map['vomiting'] as bool?,
      diarrhea: map['diarrhea'] as bool?,
      nutritionRiskLevel: map['nutrition_risk_level'] as String?,
      nutritionRiskLevelLabel: map['nutrition_risk_level_label'] as String?,
      nutritionStatus: map['nutrition_status'] as String?,
      nutritionStatusLabel: map['nutrition_status_label'] as String?,
      notes: map['notes'] as String?,
      createdBy: map['created_by'] as Map<String, dynamic>?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'evaluation_date': evaluationDate,
      'weight_kg': weightKg,
      if (usualWeightKg != null) 'usual_weight_kg': usualWeightKg,
      if (heightCm != null) 'height_cm': heightCm,
      if (bmi != null) 'bmi': bmi,
      'nutrition_route': nutritionRoute,
      if (feedingStartedAt != null) 'feeding_started_at': feedingStartedAt,
      'energy_need_kcal': energyNeedKcal,
      'protein_need_g': proteinNeedG,
      if (caloriesReceivedKcal != null) 'calories_received_kcal': caloriesReceivedKcal,
      if (proteinReceivedG != null) 'protein_received_g': proteinReceivedG,
      if (albuminGL != null) 'albumin_g_l': albuminGL,
      if (prealbuminMgL != null) 'prealbumin_mg_l': prealbuminMgL,
      if (digestiveTolerance != null) 'digestive_tolerance': digestiveTolerance,
      if (vomiting != null) 'vomiting': vomiting,
      if (diarrhea != null) 'diarrhea': diarrhea,
      if (nutritionRiskLevel != null) 'nutrition_risk_level': nutritionRiskLevel,
      if (nutritionStatus != null) 'nutrition_status': nutritionStatus,
      if (notes != null) 'notes': notes,
    };
  }

  String get createdByName => createdBy?['name'] as String? ?? 'Inconnu';
}
