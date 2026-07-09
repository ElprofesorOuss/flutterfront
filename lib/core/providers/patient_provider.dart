import 'package:flutter/foundation.dart';
import 'package:burning2026/core/models/patient.dart';
import 'package:burning2026/mock/repositories/patient_repository_impl.dart';

class PatientProvider extends ChangeNotifier {
  final FakePatientRepository _repository = FakePatientRepository();
  List<Patient> _patients = [];
  Patient? _selectedPatient;
  bool _loading = false;

  List<Patient> get patients => _patients;
  Patient? get selectedPatient => _selectedPatient;
  bool get loading => _loading;

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();
    _patients = await _repository.getAll();
    _loading = false;
    notifyListeners();
  }

  Future<void> loadById(String id) async {
    _loading = true;
    notifyListeners();
    _selectedPatient = await _repository.getById(id);
    _loading = false;
    notifyListeners();
  }

  Future<void> search(String query) async {
    _loading = true;
    notifyListeners();
    _patients = await _repository.search(query);
    _loading = false;
    notifyListeners();
  }
}