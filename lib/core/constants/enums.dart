enum SeverityLevel { faible, moderee, severe, critique }

enum Gender { male, female }

enum PatientStatus { hospitalise, sorti, decede, transfere }

enum BurnMechanism {
  flamme,
  liquideChaud,
  contact,
  eauChaude,
  produitChimique,
  electricite,
}

enum BurnDepth { superficiel, intermediaire, profond }

enum NutritionRoute { orale, enterale, parenterale, mixte }

enum ObservationCategory {
  clinique,
  pansement,
  parametres,
  nutrition,
  inhalation,
  general,
}

enum TrajectoryStepType {
  admission,
  reanimation,
  pansementInitial,
  blocOperatoire,
  greffe,
  reeducation,
  sortie,
  suiviAmbulatoire,
}