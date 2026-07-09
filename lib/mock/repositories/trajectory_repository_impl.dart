import 'package:burning2026/core/models/trajectory_step.dart';

abstract class TrajectoryRepository {
  Future<List<TrajectoryStep>> getByPatientId(String patientId);
}

class FakeTrajectoryRepository implements TrajectoryRepository {
  @override
  Future<List<TrajectoryStep>> getByPatientId(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      TrajectoryStep(id: 'T1', patientId: patientId, title: 'Admission', date: '28/06/2026', iconName: 'local_hospital', isActive: true, order: 1),
      TrajectoryStep(id: 'T2', patientId: patientId, title: 'Réanimation', subtitle: 'Protocole Parkland', date: 'J0 - J2', iconName: 'bloodtype', isActive: true, order: 2),
      TrajectoryStep(id: 'T3', patientId: patientId, title: 'Pansement initial', subtitle: 'Nettoyage + Flammacérium', date: 'J+1', iconName: 'healing', isActive: true, order: 3),
      TrajectoryStep(id: 'T4', patientId: patientId, title: 'Bloc opératoire', subtitle: 'Excision + greffe', date: 'J+5', iconName: 'biotech', isActive: false, order: 4),
      TrajectoryStep(id: 'T5', patientId: patientId, title: 'Greffe cutanée', subtitle: 'Autogreffe expansée', date: 'Prévu J+14', iconName: 'science', isActive: false, order: 5),
      TrajectoryStep(id: 'T6', patientId: patientId, title: 'Rééducation', subtitle: 'Kiné + compression', date: 'J+21', iconName: 'accessibility', isActive: false, order: 6),
      TrajectoryStep(id: 'T7', patientId: patientId, title: 'Sortie', subtitle: 'Suivi ambulatoire', date: 'Prévue J+30', iconName: 'home', isActive: false, order: 7),
    ];
  }
}