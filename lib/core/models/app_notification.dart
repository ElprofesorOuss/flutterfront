class AppNotification {
  final String id;
  final String title;
  final String description;
  final String time;
  final String type;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}