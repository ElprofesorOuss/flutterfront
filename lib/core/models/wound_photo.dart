class WoundPhoto {
  final String id;
  final String patientId;
  final String label;
  final String date;
  final String? description;
  final String severity;
  final int dayIndex;

  const WoundPhoto({
    required this.id,
    required this.patientId,
    required this.label,
    required this.date,
    this.description,
    required this.severity,
    required this.dayIndex,
  });
}