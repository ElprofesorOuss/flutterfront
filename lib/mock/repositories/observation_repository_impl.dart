import 'package:burning2026/core/models/clinical_observation.dart';

abstract class ObservationRepository {
  Future<List<ClinicalObservation>> getByPatientId(String patientId);
}

class FakeObservationRepository implements ObservationRepository {
  @override
  Future<List<ClinicalObservation>> getByPatientId(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      ClinicalObservation(id: 'O01', patientId: patientId, auteur: 'Dr. Martin', heure: '08:30', date: '09/07', categorie: 'Clinique', criticite: 'critique', note: 'Patient hypotendu (PAS 65 mmHg). Expansion volémique en cours.'),
      ClinicalObservation(id: 'O02', patientId: patientId, auteur: 'Dr. Martin', heure: '08:30', date: '09/07', categorie: 'Inhalation', criticite: 'critique', note: 'Toux, encombrement bronchique. Kiné respiratoire 2x/j.'),
      ClinicalObservation(id: 'O03', patientId: patientId, auteur: 'Inf. Dubois', heure: '06:00', date: '09/07', categorie: 'Pansement', criticite: 'sévère', note: 'Pansement humide sur MSD. Aspect propre, exsudat modéré.'),
      ClinicalObservation(id: 'O04', patientId: patientId, auteur: 'Inf. Dubois', heure: '04:00', date: '09/07', categorie: 'Paramètres', criticite: 'modérée', note: 'Diurèse conservée 0.8 mL/kg/h. Température 38.2°C.'),
      ClinicalObservation(id: 'O05', patientId: patientId, auteur: 'Dr. Petit', heure: '22:00', date: '08/07', categorie: 'Nutrition', criticite: 'modérée', note: 'SNG bien tolérée. Apport calorique 60% des besoins.'),
      ClinicalObservation(id: 'O06', patientId: patientId, auteur: 'Inf. Dubois', heure: '20:00', date: '08/07', categorie: 'Général', criticite: 'faible', note: 'Patient algique. EVA 4/10. Paracétamol administré.'),
    ];
  }
}