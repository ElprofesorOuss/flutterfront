import 'package:burning2026/core/models/app_notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getAll();
  Future<void> markAsRead(String id);
}

class FakeNotificationRepository implements NotificationRepository {
  @override
  Future<List<AppNotification>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      AppNotification(id: 'N01', title: 'Nouvelle photo J+10', description: 'Photos de greffe pour Bernard Jean disponibles', time: 'Il y a 5 min', type: 'photo'),
      AppNotification(id: 'N02', title: 'Alerte critique: Bernard Jean', description: 'Défaillance rénale suspectée', time: 'Il y a 12 min', type: 'critique'),
      AppNotification(id: 'N03', title: 'Pansement à revoir: Dubois Pierre', description: 'Pansement A-101 à renouveler dans 2h', time: 'Il y a 30 min', type: 'pansement'),
      AppNotification(id: 'N04', title: 'Alerte sévère: Moreau Sophie', description: 'Fièvre > 39.5°C persistante', time: 'Il y a 2h', type: 'critique'),
      AppNotification(id: 'N05', title: 'Rappel: Staff brûlés', description: 'Réunion d\'équipe à 14h', time: 'Il y a 3h', type: 'general'),
    ];
  }

  @override
  Future<void> markAsRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}