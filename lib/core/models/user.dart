class User {
  final String id;
  final String email;
  final String nom;
  final String prenom;
  final String role;
  final String? photoUrl;

  const User({
    required this.id,
    required this.email,
    required this.nom,
    required this.prenom,
    this.role = 'Médecin',
    this.photoUrl,
  });

  String get fullName => '$prenom $nom';
}