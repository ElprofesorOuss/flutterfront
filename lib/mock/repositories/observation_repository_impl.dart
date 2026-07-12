import 'package:burning2026/core/models/clinical_observation.dart';

abstract class ObservationRepository {
  Future<List<ClinicalObservation>> getByAdmissionId(String admissionId);
}

class FakeObservationRepository implements ObservationRepository {
  @override
  Future<List<ClinicalObservation>> getByAdmissionId(String admissionId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final id = int.tryParse(admissionId) ?? 1;
    return [
      ClinicalObservation(id: 1, admissionId: id, userId: 1, category: 'evolution', categoryLabel: 'Évolution', note: 'Patient hypotendu (PAS 65 mmHg). Expansion volémique en cours.', isCritical: true, observedAt: '2026-07-09T08:30:00+00:00', author: {'name': 'Dr. Martin', 'role': 'reanimateur'}),
      ClinicalObservation(id: 2, admissionId: id, userId: 1, category: 'respiration', categoryLabel: 'Respiration', note: 'Toux, encombrement bronchique. Kiné respiratoire 2x/j.', isCritical: true, observedAt: '2026-07-09T08:30:00+00:00', author: {'name': 'Dr. Martin', 'role': 'reanimateur'}),
      ClinicalObservation(id: 3, admissionId: id, userId: 2, category: 'pansement', categoryLabel: 'Pansement', note: 'Pansement humide sur membre supérieur droit. Aspect propre, exsudat modéré.', isCritical: false, observedAt: '2026-07-09T06:00:00+00:00', author: {'name': 'Inf. Dubois', 'role': 'infirmier'}),
      ClinicalObservation(id: 4, admissionId: id, userId: 2, category: 'autre', categoryLabel: 'Autre', note: 'Diurèse conservée 0.8 mL/kg/h. Température 38.2°C.', isCritical: false, observedAt: '2026-07-09T04:00:00+00:00', author: {'name': 'Inf. Dubois', 'role': 'infirmier'}),
      ClinicalObservation(id: 5, admissionId: id, userId: 3, category: 'nutrition', categoryLabel: 'Nutrition', note: 'SNG bien tolérée. Apport calorique 60% des besoins.', isCritical: false, observedAt: '2026-07-08T22:00:00+00:00', author: {'name': 'Dr. Petit', 'role': 'chirurgien'}),
      ClinicalObservation(id: 6, admissionId: id, userId: 2, category: 'douleur', categoryLabel: 'Douleur', note: 'Patient algique. EVA 4/10. Paracétamol administré.', isCritical: false, observedAt: '2026-07-08T20:00:00+00:00', author: {'name': 'Inf. Dubois', 'role': 'infirmier'}),
    ];
  }
}
