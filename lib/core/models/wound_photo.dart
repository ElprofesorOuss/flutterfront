class WoundPhoto {
  final int? id;
  final int? admissionId;
  final String bodyPart;
  final String stage;
  final String? imageUrl;
  final String? imagePath;
  final String? notes;
  final String? takenAt;
  final String? createdAt;

  const WoundPhoto({
    this.id,
    this.admissionId,
    required this.bodyPart,
    required this.stage,
    this.imageUrl,
    this.imagePath,
    this.notes,
    this.takenAt,
    this.createdAt,
  });

  factory WoundPhoto.fromMap(Map<String, dynamic> map) {
    return WoundPhoto(
      id: map['id'] is int ? map['id'] : int.tryParse('${map['id']}'),
      admissionId: map['admission_id'] is int
          ? map['admission_id']
          : int.tryParse('${map['admission_id']}'),
      bodyPart: map['body_part'] ?? '',
      stage: map['stage'] ?? '',
      imageUrl: map['image_url'],
      imagePath: map['image_path'],
      notes: map['notes'],
      takenAt: map['taken_at'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'body_part': bodyPart,
      'stage': stage,
      if (notes != null) 'notes': notes,
      if (takenAt != null) 'taken_at': takenAt,
    };
  }

  String get stageLabel {
    switch (stage) {
      case 'J0_initial':
        return 'J0 Initial';
      case 'pre_op':
        return 'Pre-operatoire';
      case 'post_graft':
        return 'Post-greffe';
      case 'healing':
        return 'Cicatrisation';
      case 'scar':
        return 'Cicatrice';
      default:
        return stage;
    }
  }

  String get takenAtFormatted {
    if (takenAt == null) return '';
    final date = takenAt!.substring(0, 10);
    return date;
  }
}
