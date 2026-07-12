import 'package:flutter/foundation.dart';
import 'package:burning2026/mock/data/mock_patients.dart';

class PatientProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _patients = [];
  Map<String, dynamic>? _selectedPatient;
  bool _loading = false;

  List<Map<String, dynamic>> get patients => _patients;
  Map<String, dynamic>? get selectedPatient => _selectedPatient;
  bool get loading => _loading;

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    _patients = List.from(MockPatients.list);
    _loading = false;
    notifyListeners();
  }

  Future<void> loadById(String id) async {
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      _selectedPatient = MockPatients.list.firstWhere((p) => p['id'] == id);
    } catch (_) {
      _selectedPatient = null;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> search(String query) async {
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _patients = MockPatients.list
        .where((p) =>
            p['nom']!.toLowerCase().contains(query.toLowerCase()) ||
            p['ipp']!.toLowerCase().contains(query.toLowerCase()))
        .toList();
    _loading = false;
    notifyListeners();
  }
}