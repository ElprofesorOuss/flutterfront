import 'package:flutter/material.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:burning2026/app/router/app_router.dart';
import 'package:burning2026/shared/widgets/patient_card.dart';
import 'package:burning2026/shared/widgets/filter_search_bar.dart';
import 'package:burning2026/mock/data/mock_patients.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _patients = MockPatients.list;
  String? _severityFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _patients = MockPatients.list.where((p) {
        final q = _searchController.text;
        final matchesQuery = q.isEmpty ||
            p['nom']!.toLowerCase().contains(q.toLowerCase()) ||
            p['ipp']!.toLowerCase().contains(q.toLowerCase());
        final matchesFilter = _severityFilter == null ||
            p['severite'] == _severityFilter;
        return matchesQuery && matchesFilter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Patients hospitalisés'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: Column(
        children: [
          FilterSearchBar(
            controller: _searchController,
            hintText: 'Rechercher un patient...',
            onChanged: (_) => _applyFilters(),
            resultCount: _patients.length,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _filterChip('Tous', null),
                const SizedBox(width: 6),
                _filterChip('Critique', 'critique'),
                const SizedBox(width: 6),
                _filterChip('Sévère', 'sévère'),
                const SizedBox(width: 6),
                _filterChip('Modérée', 'modérée'),
                const SizedBox(width: 6),
                _filterChip('Faible', 'faible'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _patients.length,
              itemBuilder: (ctx, i) {
                final p = _patients[i];
                return PatientCard(
                  nom: p['nom']!,
                  prenom: p['prenom']!,
                  age: p['age'] as int,
                  ipp: p['ipp']!,
                  lit: p['lit']!,
                  tbsa: p['tbsa'] as int,
                  severite: p['severite']!,
                  statut: p['statut']!,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.patientDetail, arguments: {'patientId': p['id']}),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String? severity) {
    final selected = _severityFilter == severity;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _severityFilter = selected ? null : severity;
        });
        _applyFilters();
      },
    );
  }
}