class BurnSeverityAlert {
  final String id;
  final String patientId;
  final String title;
  final String description;
  final String severity;
  final String time;
  final DateTime createdAt;

  const BurnSeverityAlert({
    required this.id,
    required this.patientId,
    required this.title,
    required this.description,
    required this.severity,
    required this.time,
    required this.createdAt,
  });
}