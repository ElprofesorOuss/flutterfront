import 'package:burning2026/core/models/app_notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getAll();
  Future<void> markAsRead(String id);
}

class FakeNotificationRepository implements NotificationRepository {
  @override
  Future<List<AppNotification>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      AppNotification(
        id: 'N01',
        title: 'Alerte critique',
        description:
            'Hypotension persistante et TBSA elevee, reanimation a prioriser.',
        time: 'Il y a 5 min',
        type: 'critical_alert',
        patientName: 'Bernard Jean',
        location: 'Lit B-201',
      ),
      AppNotification(
        id: 'N02',
        title: 'Nouvelle photo disponible',
        description: 'Photo de greffe J+10 ajoutee et prete pour revue clinique.',
        time: 'Il y a 12 min',
        type: 'new_photo',
        patientName: 'Sophie Moreau',
        location: 'Salle G2',
      ),
      AppNotification(
        id: 'N03',
        title: 'Observation critique',
        description: 'Dyspnee et aggravation respiratoire signalees par l equipe.',
        time: 'Il y a 22 min',
        type: 'critical_observation',
        patientName: 'Pierre Dubois',
        location: 'Lit A-101',
      ),
      AppNotification(
        id: 'N04',
        title: 'Patient a revoir',
        description: 'Pansement et reevaluation douleur a refaire avant la visite.',
        time: 'Il y a 38 min',
        type: 'patient_review',
        patientName: 'Leila Mansouri',
        location: 'Lit C-112',
      ),
      AppNotification(
        id: 'N05',
        title: 'Alerte critique',
        description: 'Suspicion de brulure d inhalation avec besoin d oxygene.',
        time: 'Il y a 1 h',
        type: 'critical_alert',
        patientName: 'Amine Benaissa',
        location: 'Lit REA-03',
      ),
      AppNotification(
        id: 'N06',
        title: 'Nouvelle photo disponible',
        description: 'Serie photo admission / J+3 completee pour comparaison.',
        time: 'Il y a 2 h',
        type: 'new_photo',
        patientName: 'Nadia Cherif',
        location: 'Salle D1',
      ),
    ];
  }

  @override
  Future<void> markAsRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
