class RespiratoryEvaluation {
  final int? id;
  final int? admissionId;
  final bool? airwayBurnSigns;
  final bool? sootInNostrilsOrMouth;
  final bool? hoarsenessOrDysphonia;
  final bool? dyspnea;
  final bool? oxygenTherapyNeeded;
  final int? oxygenFlowLpm;
  final bool? sootySputumOrHemoptysis;
  final double? abgPh;
  final int? abgPco2;
  final int? abgPo2;
  final double? abgHco3;
  final String? chestXrayResults;
  final String? updatedAt;

  const RespiratoryEvaluation({
    this.id,
    this.admissionId,
    this.airwayBurnSigns,
    this.sootInNostrilsOrMouth,
    this.hoarsenessOrDysphonia,
    this.dyspnea,
    this.oxygenTherapyNeeded,
    this.oxygenFlowLpm,
    this.sootySputumOrHemoptysis,
    this.abgPh,
    this.abgPco2,
    this.abgPo2,
    this.abgHco3,
    this.chestXrayResults,
    this.updatedAt,
  });

  factory RespiratoryEvaluation.fromMap(Map<String, dynamic> map) {
    return RespiratoryEvaluation(
      id: map['id'] is int ? map['id'] : int.tryParse('${map['id']}'),
      admissionId: map['admission_id'] is int
          ? map['admission_id']
          : int.tryParse('${map['admission_id']}'),
      airwayBurnSigns: map['airway_burn_signs'] is bool
          ? map['airway_burn_signs']
          : (map['airway_burn_signs'] != null ? map['airway_burn_signs'] == true : null),
      sootInNostrilsOrMouth: map['soot_in_nostrils_or_mouth'] is bool
          ? map['soot_in_nostrils_or_mouth']
          : (map['soot_in_nostrils_or_mouth'] != null ? map['soot_in_nostrils_or_mouth'] == true : null),
      hoarsenessOrDysphonia: map['hoarseness_or_dysphonia'] is bool
          ? map['hoarseness_or_dysphonia']
          : (map['hoarseness_or_dysphonia'] != null ? map['hoarseness_or_dysphonia'] == true : null),
      dyspnea: map['dyspnea'] is bool
          ? map['dyspnea']
          : (map['dyspnea'] != null ? map['dyspnea'] == true : null),
      oxygenTherapyNeeded: map['oxygen_therapy_needed'] is bool
          ? map['oxygen_therapy_needed']
          : (map['oxygen_therapy_needed'] != null ? map['oxygen_therapy_needed'] == true : null),
      oxygenFlowLpm: map['oxygen_flow_lpm'] is int
          ? map['oxygen_flow_lpm']
          : int.tryParse('${map['oxygen_flow_lpm']}'),
      sootySputumOrHemoptysis: map['sooty_sputum_or_hemoptysis'] is bool
          ? map['sooty_sputum_or_hemoptysis']
          : (map['sooty_sputum_or_hemoptysis'] != null ? map['sooty_sputum_or_hemoptysis'] == true : null),
      abgPh: map['abg_ph'] is double
          ? map['abg_ph']
          : double.tryParse('${map['abg_ph']}'),
      abgPco2: map['abg_pco2'] is int
          ? map['abg_pco2']
          : int.tryParse('${map['abg_pco2']}'),
      abgPo2: map['abg_po2'] is int
          ? map['abg_po2']
          : int.tryParse('${map['abg_po2']}'),
      abgHco3: map['abg_hco3'] is double
          ? map['abg_hco3']
          : double.tryParse('${map['abg_hco3']}'),
      chestXrayResults: map['chest_xray_results'],
      updatedAt: map['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (airwayBurnSigns != null) 'airway_burn_signs': airwayBurnSigns,
      if (sootInNostrilsOrMouth != null) 'soot_in_nostrils_or_mouth': sootInNostrilsOrMouth,
      if (hoarsenessOrDysphonia != null) 'hoarseness_or_dysphonia': hoarsenessOrDysphonia,
      if (dyspnea != null) 'dyspnea': dyspnea,
      if (oxygenTherapyNeeded != null) 'oxygen_therapy_needed': oxygenTherapyNeeded,
      if (oxygenFlowLpm != null) 'oxygen_flow_lpm': oxygenFlowLpm,
      if (sootySputumOrHemoptysis != null) 'sooty_sputum_or_hemoptysis': sootySputumOrHemoptysis,
      if (abgPh != null) 'abg_ph': abgPh,
      if (abgPco2 != null) 'abg_pco2': abgPco2,
      if (abgPo2 != null) 'abg_po2': abgPo2,
      if (abgHco3 != null) 'abg_hco3': abgHco3,
      if (chestXrayResults != null) 'chest_xray_results': chestXrayResults,
    };
  }
}
