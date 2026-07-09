class ClinicalObservation {
  final String id;
  final String patientId;
  final String auteur;
  final String heure;
  final String date;
  final String categorie;
  final String criticite;
  final String note;

  const ClinicalObservation({
    required this.id,
    required this.patientId,
    required this.auteur,
    required this.heure,
    required this.date,
    required this.categorie,
    required this.criticite,
    required this.note,
  });
}