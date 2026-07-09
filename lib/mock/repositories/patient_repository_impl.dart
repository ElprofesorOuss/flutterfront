import 'package:burning2026/core/models/patient.dart';
import 'package:burning2026/mock/data/mock_patients.dart';

abstract class PatientRepository {
  Future<List<Patient>> getAll();
  Future<Patient?> getById(String id);
  Future<List<Patient>> search(String query);
  Future<List<Patient>> filterBySeverity(String level);
}

class FakePatientRepository implements PatientRepository {
  @override
  Future<List<Patient>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return MockPatients.list.map((m) => Patient.fromMap(m)).toList();
  }

  @override
  Future<Patient?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      final map = MockPatients.list.firstWhere((p) => p['id'] == id);
      return Patient.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Patient>> search(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final all = MockPatients.list.map((m) => Patient.fromMap(m)).toList();
    return all.where((p) =>
        p.nom.toLowerCase().contains(query.toLowerCase()) ||
        p.ipp.toLowerCase().contains(query.toLowerCase())).toList();
  }

  @override
  Future<List<Patient>> filterBySeverity(String level) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final all = MockPatients.list.map((m) => Patient.fromMap(m)).toList();
    return all.where((p) => p.severite.toLowerCase() == level.toLowerCase()).toList();
  }
}