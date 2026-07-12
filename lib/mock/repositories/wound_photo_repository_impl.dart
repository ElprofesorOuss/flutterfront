import 'package:burning2026/core/models/wound_photo.dart';

abstract class WoundPhotoRepository {
  Future<List<WoundPhoto>> getByAdmissionId(String admissionId);
}

class FakeWoundPhotoRepository implements WoundPhotoRepository {
  @override
  Future<List<WoundPhoto>> getByAdmissionId(String admissionId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      WoundPhoto(id: 1, admissionId: int.tryParse(admissionId), bodyPart: 'Membre superieur droit', stage: 'J0_initial', notes: 'Photo d\'admission', takenAt: '2026-07-01T10:00:00+00:00'),
      WoundPhoto(id: 2, admissionId: int.tryParse(admissionId), bodyPart: 'Tronc anterieur', stage: 'pre_op', notes: 'Avant debridement', takenAt: '2026-07-04T14:30:00+00:00'),
      WoundPhoto(id: 3, admissionId: int.tryParse(admissionId), bodyPart: 'Membre superieur droit', stage: 'post_graft', notes: 'J+7 post-greffe', takenAt: '2026-07-08T09:15:00+00:00'),
      WoundPhoto(id: 4, admissionId: int.tryParse(admissionId), bodyPart: 'Main droite', stage: 'healing', notes: 'Bonne evolution', takenAt: '2026-07-11T11:00:00+00:00'),
      WoundPhoto(id: 5, admissionId: int.tryParse(admissionId), bodyPart: 'Membre superieur droit', stage: 'healing', notes: 'Cicatrisation en cours', takenAt: '2026-07-15T08:45:00+00:00'),
    ];
  }
}
