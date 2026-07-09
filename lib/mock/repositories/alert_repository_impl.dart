import 'package:burning2026/core/models/burn_severity_alert.dart';

abstract class AlertRepository {
  Future<List<BurnSeverityAlert>> getAll();
  Future<List<BurnSeverityAlert>> getByPatientId(String patientId);
}

class FakeAlertRepository implements AlertRepository {
  final List<BurnSeverityAlert> _alerts = [
    BurnSeverityAlert(id: 'A01', patientId: 'P005', title: 'Défaillance rénale suspectée', description: 'Créatinine > 200 µmol/L', severity: 'critique', time: 'Il y a 12 min', createdAt: DateTime.now()),
    BurnSeverityAlert(id: 'A02', patientId: 'P001', title: 'Hypotension sévère', description: 'PAS < 70 mmHg', severity: 'critique', time: 'Il y a 35 min', createdAt: DateTime.now().subtract(const Duration(minutes: 35))),
    BurnSeverityAlert(id: 'A03', patientId: 'P002', title: 'Hyperthermie', description: 'Température > 39.5°C', severity: 'sévère', time: 'Il y a 2h', createdAt: DateTime.now().subtract(const Duration(hours: 2))),
    BurnSeverityAlert(id: 'A04', patientId: 'P004', title: 'Douleur non contrôlée', description: 'EVA > 7/10', severity: 'sévère', time: 'Il y a 3h', createdAt: DateTime.now().subtract(const Duration(hours: 3))),
    BurnSeverityAlert(id: 'A05', patientId: 'P003', title: 'Apport nutritionnel insuffisant', description: '40% des besoins', severity: 'modérée', time: 'Il y a 4h', createdAt: DateTime.now().subtract(const Duration(hours: 4))),
  ];

  @override
  Future<List<BurnSeverityAlert>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _alerts;
  }

  @override
  Future<List<BurnSeverityAlert>> getByPatientId(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _alerts.where((a) => a.patientId == patientId).toList();
  }
}