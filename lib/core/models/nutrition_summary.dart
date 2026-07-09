class NutritionSummary {
  final String patientId;
  final double poids;
  final double taille;
  final int besoinsCaloriques;
  final int besoinsProteines;
  final int besoinsLipides;
  final int besoinsGlucides;
  final String voieNutritionnelle;

  const NutritionSummary({
    required this.patientId,
    required this.poids,
    required this.taille,
    required this.besoinsCaloriques,
    required this.besoinsProteines,
    required this.besoinsLipides,
    required this.besoinsGlucides,
    required this.voieNutritionnelle,
  });
}