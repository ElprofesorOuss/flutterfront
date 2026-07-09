class Patient {
  final String id;
  final String ipp;
  final String nom;
  final String prenom;
  final int age;
  final String sexe;
  final String lit;
  final int tbsa;
  final String severite;
  final String statut;
  final String dateAdmission;
  final String mecanisme;
  final bool inhalation;
  final String profondeur;

  const Patient({
    required this.id,
    required this.ipp,
    required this.nom,
    required this.prenom,
    required this.age,
    required this.sexe,
    required this.lit,
    required this.tbsa,
    required this.severite,
    required this.statut,
    required this.dateAdmission,
    required this.mecanisme,
    required this.inhalation,
    required this.profondeur,
  });

  String get fullName => '$nom $prenom';
  String get initials => '${nom[0]}${prenom[0]}';

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] ?? '',
      ipp: map['ipp'] ?? '',
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      age: map['age'] ?? 0,
      sexe: map['sexe'] ?? '',
      lit: map['lit'] ?? '',
      tbsa: map['tbsa'] ?? 0,
      severite: map['severite'] ?? '',
      statut: map['statut'] ?? '',
      dateAdmission: map['date_admission'] ?? '',
      mecanisme: map['mecanisme'] ?? '',
      inhalation: map['inhalation'] ?? false,
      profondeur: map['profondeur'] ?? '',
    );
  }
}