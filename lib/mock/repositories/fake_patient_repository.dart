import 'package:burning2026/mock/data/mock_patients.dart';

class FakePatientRepository {
  Future<List<Map<String, dynamic>>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return MockPatients.list;
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      return MockPatients.list.firstWhere((p) => p['id'] == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> search(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockPatients.list
        .where((p) =>
            p['nom']!.toLowerCase().contains(query.toLowerCase()) ||
            p['ipp']!.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<List<Map<String, dynamic>>> filterBySeverity(String level) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockPatients.list
        .where((p) => p['severite']!.toLowerCase() == level.toLowerCase())
        .toList();
  }
}