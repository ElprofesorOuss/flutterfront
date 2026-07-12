class ClinicalObservation {
  final int id;
  final int admissionId;
  final int? userId;
  final String category;
  final String categoryLabel;
  final String note;
  final bool isCritical;
  final String? observedAt;
  final String? createdAt;
  final String? updatedAt;
  final Map<String, dynamic>? author;

  const ClinicalObservation({
    required this.id,
    required this.admissionId,
    this.userId,
    required this.category,
    required this.categoryLabel,
    required this.note,
    required this.isCritical,
    this.observedAt,
    this.createdAt,
    this.updatedAt,
    this.author,
  });

  factory ClinicalObservation.fromMap(Map<String, dynamic> map) {
    return ClinicalObservation(
      id: map['id'] as int,
      admissionId: map['admission_id'] as int,
      userId: map['user_id'] as int?,
      category: map['category'] as String? ?? 'autre',
      categoryLabel: map['category_label'] as String? ?? 'Autre',
      note: map['note'] as String? ?? '',
      isCritical: map['is_critical'] == true || map['is_critical'] == 1,
      observedAt: map['observed_at'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
      author: map['author'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'note': note,
      'is_critical': isCritical,
      if (observedAt != null) 'observed_at': observedAt,
    };
  }

  static const Map<String, String> categoryLabels = {
    'evolution': 'Évolution',
    'douleur': 'Douleur',
    'pansement': 'Pansement',
    'respiration': 'Respiration',
    'hemodynamique': 'Hémodynamique',
    'nutrition': 'Nutrition',
    'infection': 'Infection',
    'chirurgie': 'Chirurgie',
    'autre': 'Autre',
    'medicale': 'Médicale',
    'infirmiere': 'Infirmière',
    'chirurgicale': 'Chirurgicale',
    'transmission': 'Transmission',
  };

  static List<String> get categories => categoryLabels.keys.toList();

  String get authorName => author?['name'] as String? ?? 'Inconnu';
  String get authorRole => author?['role'] as String? ?? '';
  String get formattedObservedAt {
    if (observedAt == null) return '';
    try {
      final dt = DateTime.parse(observedAt!);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return observedAt!;
    }
  }
}
