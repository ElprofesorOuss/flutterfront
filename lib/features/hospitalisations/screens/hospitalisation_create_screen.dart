import 'dart:convert';

import 'package:burning2026/core/constants/api_constants.dart';
import 'package:burning2026/core/theme/app_colors.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HospitalisationCreateScreen extends StatefulWidget {
  const HospitalisationCreateScreen({super.key});

  @override
  State<HospitalisationCreateScreen> createState() =>
      _HospitalisationCreateScreenState();
}

class _HospitalisationCreateScreenState
    extends State<HospitalisationCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _visitNumberController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _burnOccurredAtController = TextEditingController();
  final _admittedAtController = TextEditingController();
  final _tbsaController = TextEditingController();

  List<Map<String, dynamic>> _patients = [];
  List<Map<String, dynamic>> _lits = [];
  List<String> _statuses = const [];
  String? _selectedPatientId;
  String? _selectedLitId;
  String _selectedStatus = 'urgences';
  bool _inhalationInjury = false;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  @override
  void dispose() {
    _visitNumberController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _burnOccurredAtController.dispose();
    _admittedAtController.dispose();
    _tbsaController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    setState(() => _loading = true);

    try {
      final response = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}/hospitalisations/options'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(ApiConstants.timeout);

      if (!mounted) return;

      final body = jsonDecode(response.body);
      final data = body['data'];
      if (response.statusCode == 200 && data is Map<String, dynamic>) {
        _patients = (data['patients'] as List? ?? [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _lits = (data['lits'] as List? ?? [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _statuses = (data['statuses'] as List? ?? [])
            .map((e) => e.toString())
            .toList();
        if (_statuses.isNotEmpty) {
          _selectedStatus = _statuses.first;
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de charger les options.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatientId == null || _selectedLitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selectionnez un patient et un lit.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}/hospitalisations'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'patient_id': int.parse(_selectedPatientId!),
              'lit_id': int.parse(_selectedLitId!),
              'visit_number': _visitNumberController.text.trim(),
              'weight_kg': double.parse(_weightController.text.trim()),
              'height_cm': int.parse(_heightController.text.trim()),
              'burn_occurred_at': _burnOccurredAtController.text.trim(),
              'admitted_at': _admittedAtController.text.trim(),
              'tbsa_percentage': double.parse(_tbsaController.text.trim()),
              'inhalation_injury': _inhalationInjury,
              'status': _selectedStatus,
            }),
          )
          .timeout(ApiConstants.timeout);

      if (!mounted) return;

      final body = jsonDecode(response.body);
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hospitalisation creee avec succes.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
        return;
      }

      String message = 'Erreur lors de la creation.';
      if (body is Map<String, dynamic>) {
        message = body['message']?.toString() ?? message;
        final errors = body['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            message = firstError.first.toString();
          }
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connexion au serveur impossible.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: const Text('Nouvelle hospitalisation')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _dropdownCard(
                      label: 'Patient',
                      value: _selectedPatientId,
                      items: _patients
                          .map(
                            (p) => DropdownMenuItem<String>(
                              value: '${p['id']}',
                              child: Text('${p['full_name']} (${p['ipp']})'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedPatientId = value),
                    ),
                    const SizedBox(height: 14),
                    _dropdownCard(
                      label: 'Lit disponible',
                      value: _selectedLitId,
                      items: _lits
                          .map(
                            (l) => DropdownMenuItem<String>(
                              value: '${l['id']}',
                              child: Text('${l['label']}'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedLitId = value),
                    ),
                    const SizedBox(height: 14),
                    _textField(_visitNumberController, 'Numero de sejour (IEP)',
                        'V-2026-001'),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _textField(
                            _weightController,
                            'Poids (kg)',
                            '70',
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _textField(
                            _heightController,
                            'Taille (cm)',
                            '175',
                            isNumber: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _textField(_burnOccurredAtController,
                        'Date/heure de la brulure', '2026-07-09 08:00:00'),
                    const SizedBox(height: 14),
                    _textField(_admittedAtController, 'Date/heure admission',
                        '2026-07-09 09:00:00'),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _textField(
                            _tbsaController,
                            'TBSA (%)',
                            '25',
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _dropdownCard(
                            label: 'Statut',
                            value: _selectedStatus,
                            items: _statuses
                                .map(
                                  (s) => DropdownMenuItem<String>(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _selectedStatus = value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile.adaptive(
                      value: _inhalationInjury,
                      activeThumbColor: AppTheme.primaryColor,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Brulure d inhalation'),
                      onChanged: (value) =>
                          setState(() => _inhalationInjury = value),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Creer l hospitalisation'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isNumber = false,
  }) {
    final colors = context.appColors;
    return TextFormField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      validator: (value) =>
          (value == null || value.trim().isEmpty) ? 'Champ requis' : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: colors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
    );
  }

  Widget _dropdownCard({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    final colors = context.appColors;
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: colors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      items: items,
      onChanged: onChanged,
      validator: (value) =>
          value == null || value.isEmpty ? 'Champ requis' : null,
    );
  }
}
