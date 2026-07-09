class MockScenarios {
  MockScenarios._();

  static final List<Map<String, dynamic>> scenarios = [
    {
      'id': 'demo1',
      'nom': 'Patient stable',
      'description': 'Patient Roux Camille - TBSA 5% - Faible',
      'patientId': 'P006',
    },
    {
      'id': 'demo2',
      'nom': 'Patient sévère',
      'description': 'Patient Moreau Sophie - TBSA 18% - Sévère',
      'patientId': 'P002',
    },
    {
      'id': 'demo3',
      'nom': 'Patient critique',
      'description': 'Patient Dubois Pierre - TBSA 32% - Critique',
      'patientId': 'P001',
    },
    {
      'id': 'demo4',
      'nom': 'Patient avec inhalation',
      'description': 'Patient Bernard Jean - TBSA 45% - Critique + Inhalation',
      'patientId': 'P005',
    },
    {
      'id': 'demo5',
      'nom': 'Patient évolution photos',
      'description': 'Patient Dubois Pierre - Série photos J0 à J+10',
      'patientId': 'P001',
    },
    {
      'id': 'demo6',
      'nom': 'Patient phase greffe',
      'description': 'Patient Bernard Jean - Phase greffe/rééducation',
      'patientId': 'P005',
    },
  ];
}