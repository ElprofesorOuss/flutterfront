class Hospitalisation {
  final String id;
  final String patientId;
  final String dateAdmission;
  final String? dateSortie;
  final String mecanisme;
  final int tbsa;
  final bool inhalation;
  final String profondeur;
  final String lit;
  final String statutClinique;

  const Hospitalisation({
    required this.id,
    required this.patientId,
    required this.dateAdmission,
    this.dateSortie,
    required this.mecanisme,
    required this.tbsa,
    required this.inhalation,
    required this.profondeur,
    required this.lit,
    required this.statutClinique,
  });
}