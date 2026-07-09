class TrajectoryStep {
  final String id;
  final String patientId;
  final String title;
  final String? subtitle;
  final String date;
  final String iconName;
  final bool isActive;
  final int order;

  const TrajectoryStep({
    required this.id,
    required this.patientId,
    required this.title,
    this.subtitle,
    required this.date,
    required this.iconName,
    required this.isActive,
    required this.order,
  });
}