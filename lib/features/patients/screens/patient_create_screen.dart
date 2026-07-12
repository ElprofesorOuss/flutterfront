import 'dart:convert';

import 'package:burning2026/core/constants/api_constants.dart';
import 'package:burning2026/core/theme/app_colors.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PatientCreateScreen extends StatefulWidget {
  const PatientCreateScreen({super.key});

  @override
  State<PatientCreateScreen> createState() => _PatientCreateScreenState();
}

class _PatientCreateScreenState extends State<PatientCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ippController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _allergiesController = TextEditingController();
  String _gender = 'homme';
  bool _submitting = false;

  @override
  void dispose() {
    _ippController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}/patients'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'ipp': _ippController.text.trim(),
              'first_name': _firstNameController.text.trim(),
              'last_name': _lastNameController.text.trim(),
              'birth_date': _birthDateController.text.trim(),
              'gender': _gender,
              'phone': _phoneController.text.trim(),
              'address': _addressController.text.trim(),
              'known_allergies': _allergiesController.text.trim(),
            }),
          )
          .timeout(ApiConstants.timeout);

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient ajoute avec succes.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
        return;
      }

      String message = 'Erreur lors de la creation du patient.';
      try {
        final body = jsonDecode(response.body);
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
      } catch (_) {}

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
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Ajouter un patient'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionCard(
                title: 'Identite du patient',
                icon: Icons.badge_outlined,
                child: Column(
                  children: [
                    _LabeledField(
                      label: 'IPP',
                      child: TextFormField(
                        controller: _ippController,
                        decoration: _inputDecoration('Ex: 2026-0045'),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'IPP requis'
                                : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _LabeledField(
                            label: 'Prenom',
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: _inputDecoration('Sara'),
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                      ? 'Prenom requis'
                                      : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _LabeledField(
                            label: 'Nom',
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: _inputDecoration('Benali'),
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                      ? 'Nom requis'
                                      : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _LabeledField(
                            label: 'Date de naissance',
                            child: TextFormField(
                              controller: _birthDateController,
                              decoration: _inputDecoration('1998-05-12'),
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                      ? 'Date requise'
                                      : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _LabeledField(
                            label: 'Genre',
                            child: DropdownButtonFormField<String>(
                              initialValue: _gender,
                              items: const [
                                DropdownMenuItem(
                                  value: 'homme',
                                  child: Text('Homme'),
                                ),
                                DropdownMenuItem(
                                  value: 'femme',
                                  child: Text('Femme'),
                                ),
                                DropdownMenuItem(
                                  value: 'autre',
                                  child: Text('Autre'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _gender = value);
                              },
                              decoration: _inputDecoration(''),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Coordonnees',
                icon: Icons.call_outlined,
                child: Column(
                  children: [
                    _LabeledField(
                      label: 'Telephone',
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: _inputDecoration('0550123456'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _LabeledField(
                      label: 'Adresse',
                      child: TextFormField(
                        controller: _addressController,
                        decoration: _inputDecoration('Oran'),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Informations medicales',
                icon: Icons.medical_information_outlined,
                child: _LabeledField(
                  label: 'Allergies connues',
                  child: TextFormField(
                    controller: _allergiesController,
                    decoration: _inputDecoration('Aucune'),
                    maxLines: 3,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE11D48), Color(0xFFF59E0B)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33E11D48),
                        blurRadius: 16,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.person_add_alt_1_rounded),
                    label: Text(
                      _submitting
                          ? 'Enregistrement...'
                          : 'Enregistrer le patient',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    final colors = context.appColors;
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: colors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.4),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D111827),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFE4E6), Color(0xFFFFF7ED)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
