import 'package:burning2026/core/models/wound_photo.dart';

abstract class WoundPhotoRepository {
  Future<List<WoundPhoto>> getByPatientId(String patientId);
}

class FakeWoundPhotoRepository implements WoundPhotoRepository {
  @override
  Future<List<WoundPhoto>> getByPatientId(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      WoundPhoto(id: '1', patientId: patientId, label: 'Admission', date: 'J0', severity: 'critique', dayIndex: 0),
      WoundPhoto(id: '2', patientId: patientId, label: 'J+3', date: '03/07', severity: 'sévère', dayIndex: 3),
      WoundPhoto(id: '3', patientId: patientId, label: 'J+7', date: '07/07', severity: 'modérée', dayIndex: 7),
      WoundPhoto(id: '4', patientId: patientId, label: 'J+10', date: '10/07', severity: 'modérée', dayIndex: 10),
      WoundPhoto(id: '5', patientId: patientId, label: 'Greffe J1', date: '14/07', severity: 'faible', dayIndex: 14),
    ];
  }
}