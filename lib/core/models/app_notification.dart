class AppNotification {
  final String id;
  final String title;
  final String description;
  final String time;
  final String type;
  final bool isRead;
  final String patientName;
  final String? location;

  const AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.type,
    this.isRead = false,
    this.patientName = '',
    this.location,
  });
}
