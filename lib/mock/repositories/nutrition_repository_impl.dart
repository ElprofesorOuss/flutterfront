import 'package:burning2026/core/models/nutrition_summary.dart';

abstract class NutritionRepository {
  Future<NutritionSummary?> getByPatientId(String patientId);
}

class FakeNutritionRepository implements NutritionRepository {
  @override
  Future<NutritionSummary?> getByPatientId(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const NutritionSummary(
      patientId: 'test',
      poids: 72,
      taille: 175,
      besoinsCaloriques: 2600,
      besoinsProteines: 120,
      besoinsLipides: 75,
      besoinsGlucides: 320,
      voieNutritionnelle: 'Nutrition entérale + orale',
    );
  }
}