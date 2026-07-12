import 'dart:convert';

import 'package:burning2026/core/constants/api_constants.dart';
import 'package:burning2026/core/models/initial_assessment.dart';
import 'package:burning2026/core/theme/app_colors.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InitialAssessmentScreen extends StatefulWidget {
  final String admissionId;
  final InitialAssessment? existingAssessment;

  const InitialAssessmentScreen({
    super.key,
    required this.admissionId,
    this.existingAssessment,
  });

  @override
  State<InitialAssessmentScreen> createState() => _InitialAssessmentScreenState();
}

class _InitialAssessmentScreenState extends State<InitialAssessmentScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _glasgowController;
  late TextEditingController _systolicBpController;
  late TextEditingController _diastolicBpController;
  late TextEditingController _heartRateController;
  late TextEditingController _respRateController;
  late TextEditingController _temperatureController;
  late TextEditingController _spo2Controller;
  late TextEditingController _painEvaController;

  @override
  void initState() {
    super.initState();
    _glasgowController = TextEditingController(
      text: widget.existingAssessment?.glasgowScore?.toString() ?? '',
    );
    _systolicBpController = TextEditingController(
      text: widget.existingAssessment?.systolicBp?.toString() ?? '',
    );
    _diastolicBpController = TextEditingController(
      text: widget.existingAssessment?.diastolicBp?.toString() ?? '',
    );
    _heartRateController = TextEditingController(
      text: widget.existingAssessment?.heartRate?.toString() ?? '',
    );
    _respRateController = TextEditingController(
      text: widget.existingAssessment?.respRate?.toString() ?? '',
    );
    _temperatureController = TextEditingController(
      text: widget.existingAssessment?.temperature?.toString() ?? '',
    );
    _spo2Controller = TextEditingController(
      text: widget.existingAssessment?.spo2?.toString() ?? '',
    );
    _painEvaController = TextEditingController(
      text: widget.existingAssessment?.painEva?.toString() ?? '',
    );

    if (widget.existingAssessment != null) {
      _hasExistingData = true;
    } else {
      _loadExistingAssessment();
    }
  }

  @override
  void dispose() {
    _glasgowController.dispose();
    _systolicBpController.dispose();
    _diastolicBpController.dispose();
    _heartRateController.dispose();
    _respRateController.dispose();
    _temperatureController.dispose();
    _spo2Controller.dispose();
    _painEvaController.dispose();
    super.dispose();
  }

  String _generalState = '';
  String _psychologicalState = '';
  bool _submitting = false;
  bool _isLoading = false;
  bool _hasExistingData = false;

  final List<Map<String, dynamic>> _generalStateOptions = [
    {'label': 'Stable', 'value': 'stable'},
    {'label': 'Serieux', 'value': 'serious'},
    {'label': 'Critique', 'value': 'critical'},
  ];

  final List<Map<String, dynamic>> _psychologicalStateOptions = [
    {'label': 'Calme', 'value': 'calm'},
    {'label': 'Anxieux', 'value': 'anxious'},
    {'label': 'Confus', 'value': 'confused'},
    {'label': 'Agite', 'value': 'agitated'},
    {'label': 'Sedate', 'value': 'sedated'},
  ];

  Future<void> _loadExistingAssessment() async {
    if (widget.existingAssessment != null) return;

    setState(() => _isLoading = true);

    try {
      final response = await http
          .get(
            Uri.parse(
                '${ApiConstants.baseUrl}/admissions/${widget.admissionId}/initial-assessment'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(ApiConstants.timeout);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];
        if (data != null) {
          final assessment = InitialAssessment.fromMap(data);
          _glasgowController.text = assessment.glasgowScore?.toString() ?? '';
          _systolicBpController.text = assessment.systolicBp?.toString() ?? '';
          _diastolicBpController.text = assessment.diastolicBp?.toString() ?? '';
          _heartRateController.text = assessment.heartRate?.toString() ?? '';
          _respRateController.text = assessment.respRate?.toString() ?? '';
          _temperatureController.text = assessment.temperature?.toString() ?? '';
          _spo2Controller.text = assessment.spo2?.toString() ?? '';
          _painEvaController.text = assessment.painEva?.toString() ?? '';
          _generalState = assessment.generalState ?? '';
          _psychologicalState = assessment.psychologicalState ?? '';
          _hasExistingData = true;
          setState(() {});
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      final body = {
        if (_glasgowController.text.trim().isNotEmpty)
          'glasgow_score': int.tryParse(_glasgowController.text.trim()),
        if (_generalState.isNotEmpty) 'general_state': _generalState,
        if (_systolicBpController.text.trim().isNotEmpty)
          'systolic_bp': int.tryParse(_systolicBpController.text.trim()),
        if (_diastolicBpController.text.trim().isNotEmpty)
          'diastolic_bp': int.tryParse(_diastolicBpController.text.trim()),
        if (_heartRateController.text.trim().isNotEmpty)
          'heart_rate': int.tryParse(_heartRateController.text.trim()),
        if (_respRateController.text.trim().isNotEmpty)
          'resp_rate': int.tryParse(_respRateController.text.trim()),
        if (_temperatureController.text.trim().isNotEmpty)
          'temperature': double.tryParse(_temperatureController.text.trim()),
        if (_spo2Controller.text.trim().isNotEmpty)
          'spo2': int.tryParse(_spo2Controller.text.trim()),
        if (_painEvaController.text.trim().isNotEmpty)
          'pain_eva': int.tryParse(_painEvaController.text.trim()),
        if (_psychologicalState.isNotEmpty)
          'psychological_state': _psychologicalState,
      };

      final http.Response response;
      if (_hasExistingData) {
        response = await http
            .put(
              Uri.parse(
                  '${ApiConstants.baseUrl}/admissions/${widget.admissionId}/initial-assessment'),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(body),
            )
            .timeout(ApiConstants.timeout);
      } else {
        response = await http
            .post(
              Uri.parse(
                  '${ApiConstants.baseUrl}/admissions/${widget.admissionId}/initial-assessment'),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(body),
            )
            .timeout(ApiConstants.timeout);
      }

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evaluation initiale enregistree avec succes.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
        return;
      }

      String message = 'Erreur lors de l\'enregistrement.';
      try {
        final respBody = jsonDecode(response.body);
        if (respBody is Map<String, dynamic>) {
          message = respBody['message']?.toString() ?? message;
          final errors = respBody['errors'];
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
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Evaluation initiale'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionCard(
                      title: 'Etat neurologique',
                      icon: Icons.psychology_outlined,
                      child: _LabeledField(
                        label: 'Score de Glasgow (3-15)',
                        child: DropdownButtonFormField<int>(
                          value: int.tryParse(_glasgowController.text),
                          items: List.generate(13, (i) => i + 3).map((score) {
                            return DropdownMenuItem(
                              value: score,
                              child: Text('$score'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(
                                () => _glasgowController.text = value.toString());
                          },
                          decoration: _inputDecoration('Selectionnez le score'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Etat general',
                      icon: Icons.person_outlined,
                      child: _LabeledField(
                        label: 'Etat general',
                        child: DropdownButtonFormField<String>(
                          value: _generalState.isNotEmpty ? _generalState : null,
                          items: _generalStateOptions.map((opt) {
                            return DropdownMenuItem<String>(
                              value: opt['value'] as String,
                              child: Text(opt['label'] as String),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _generalState = value);
                          },
                          decoration: _inputDecoration('Selectionnez'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Signes vitaux',
                      icon: Icons.monitor_heart_outlined,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _LabeledField(
                                  label: 'PAS (mmHg)',
                                  child: TextFormField(
                                    controller: _systolicBpController,
                                    decoration: _inputDecoration('120'),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _LabeledField(
                                  label: 'PAD (mmHg)',
                                  child: TextFormField(
                                    controller: _diastolicBpController,
                                    decoration: _inputDecoration('80'),
                                    keyboardType: TextInputType.number,
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
                                  label: 'Freq. cardiaque (/min)',
                                  child: TextFormField(
                                    controller: _heartRateController,
                                    decoration: _inputDecoration('72'),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _LabeledField(
                                  label: 'Freq. respiratoire (/min)',
                                  child: TextFormField(
                                    controller: _respRateController,
                                    decoration: _inputDecoration('16'),
                                    keyboardType: TextInputType.number,
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
                                  label: 'Temperature (°C)',
                                  child: TextFormField(
                                    controller: _temperatureController,
                                    decoration: _inputDecoration('37.0'),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _LabeledField(
                                  label: 'SpO2 (%)',
                                  child: TextFormField(
                                    controller: _spo2Controller,
                                    decoration: _inputDecoration('98'),
                                    keyboardType: TextInputType.number,
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
                      title: 'Evaluation de la douleur',
                      icon: Icons.healing_outlined,
                      child: _LabeledField(
                        label: 'EVA (0-10)',
                        child: DropdownButtonFormField<int>(
                          value: int.tryParse(_painEvaController.text),
                          items: List.generate(11, (i) => i).map((score) {
                            return DropdownMenuItem(
                              value: score,
                              child: Text('$score'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(
                                () => _painEvaController.text = value.toString());
                          },
                          decoration: _inputDecoration('Selectionnez'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Etat psychologique',
                      icon: Icons.emoji_people_outlined,
                      child: _LabeledField(
                        label: 'Etat psychologique',
                        child: DropdownButtonFormField<String>(
                          value: _psychologicalState.isNotEmpty
                              ? _psychologicalState
                              : null,
                          items: _psychologicalStateOptions.map((opt) {
                            return DropdownMenuItem<String>(
                              value: opt['value'] as String,
                              child: Text(opt['label'] as String),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _psychologicalState = value);
                          },
                          decoration: _inputDecoration('Selectionnez'),
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
                              : const Icon(Icons.save_rounded),
                          label: Text(
                            _submitting
                                ? 'Enregistrement...'
                                : (widget.existingAssessment != null
                                    ? 'Mettre a jour'
                                    : 'Enregistrer'),
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
