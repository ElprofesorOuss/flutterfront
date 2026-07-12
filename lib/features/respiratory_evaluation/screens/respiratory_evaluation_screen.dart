import 'dart:convert';

import 'package:burning2026/core/constants/api_constants.dart';
import 'package:burning2026/core/models/respiratory_evaluation.dart';
import 'package:burning2026/core/theme/app_colors.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RespiratoryEvaluationScreen extends StatefulWidget {
  final String admissionId;

  const RespiratoryEvaluationScreen({
    super.key,
    required this.admissionId,
  });

  @override
  State<RespiratoryEvaluationScreen> createState() => _RespiratoryEvaluationScreenState();
}

class _RespiratoryEvaluationScreenState extends State<RespiratoryEvaluationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  bool _isLoading = true;

  late TextEditingController _oxygenFlowController;
  late TextEditingController _abgPhController;
  late TextEditingController _abgPco2Controller;
  late TextEditingController _abgPo2Controller;
  late TextEditingController _abgHco3Controller;
  late TextEditingController _chestXrayController;

  bool _airwayBurnSigns = false;
  bool _sootInNostrilsOrMouth = false;
  bool _hoarsenessOrDysphonia = false;
  bool _dyspnea = false;
  bool _oxygenTherapyNeeded = false;
  bool _sootySputumOrHemoptysis = false;

  @override
  void initState() {
    super.initState();
    _oxygenFlowController = TextEditingController();
    _abgPhController = TextEditingController();
    _abgPco2Controller = TextEditingController();
    _abgPo2Controller = TextEditingController();
    _abgHco3Controller = TextEditingController();
    _chestXrayController = TextEditingController();
    _loadData();
  }

  @override
  void dispose() {
    _oxygenFlowController.dispose();
    _abgPhController.dispose();
    _abgPco2Controller.dispose();
    _abgPo2Controller.dispose();
    _abgHco3Controller.dispose();
    _chestXrayController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final response = await http
          .get(
            Uri.parse(
                '${ApiConstants.baseUrl}/admissions/${widget.admissionId}/respiratory-evaluation'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(ApiConstants.timeout);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];
        if (data != null) {
          final eval = RespiratoryEvaluation.fromMap(data);
          _airwayBurnSigns = eval.airwayBurnSigns ?? false;
          _sootInNostrilsOrMouth = eval.sootInNostrilsOrMouth ?? false;
          _hoarsenessOrDysphonia = eval.hoarsenessOrDysphonia ?? false;
          _dyspnea = eval.dyspnea ?? false;
          _oxygenTherapyNeeded = eval.oxygenTherapyNeeded ?? false;
          _sootySputumOrHemoptysis = eval.sootySputumOrHemoptysis ?? false;
          _oxygenFlowController.text = eval.oxygenFlowLpm?.toString() ?? '';
          _abgPhController.text = eval.abgPh?.toString() ?? '';
          _abgPco2Controller.text = eval.abgPco2?.toString() ?? '';
          _abgPo2Controller.text = eval.abgPo2?.toString() ?? '';
          _abgHco3Controller.text = eval.abgHco3?.toString() ?? '';
          _chestXrayController.text = eval.chestXrayResults ?? '';
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
      final Map<String, dynamic> body = {
        'airway_burn_signs': _airwayBurnSigns,
        'soot_in_nostrils_or_mouth': _sootInNostrilsOrMouth,
        'hoarseness_or_dysphonia': _hoarsenessOrDysphonia,
        'dyspnea': _dyspnea,
        'oxygen_therapy_needed': _oxygenTherapyNeeded,
        'sooty_sputum_or_hemoptysis': _sootySputumOrHemoptysis,
      };

      if (_oxygenTherapyNeeded && _oxygenFlowController.text.trim().isNotEmpty) {
        body['oxygen_flow_lpm'] = int.tryParse(_oxygenFlowController.text.trim());
      }

      if (_abgPhController.text.trim().isNotEmpty) {
        body['abg_ph'] = double.tryParse(_abgPhController.text.trim());
      }
      if (_abgPco2Controller.text.trim().isNotEmpty) {
        body['abg_pco2'] = int.tryParse(_abgPco2Controller.text.trim());
      }
      if (_abgPo2Controller.text.trim().isNotEmpty) {
        body['abg_po2'] = int.tryParse(_abgPo2Controller.text.trim());
      }
      if (_abgHco3Controller.text.trim().isNotEmpty) {
        body['abg_hco3'] = double.tryParse(_abgHco3Controller.text.trim());
      }
      if (_chestXrayController.text.trim().isNotEmpty) {
        body['chest_xray_results'] = _chestXrayController.text.trim();
      }

      final response = await http
          .put(
            Uri.parse(
                '${ApiConstants.baseUrl}/admissions/${widget.admissionId}/respiratory-evaluation'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(ApiConstants.timeout);

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evaluation respiratoire mise a jour avec succes.'),
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
        title: const Text('Evaluation respiratoire'),
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
                      title: 'Signes d\'inhalation',
                      icon: Icons.air_outlined,
                      child: Column(
                        children: [
                          _ToggleField(
                            label: 'Brulure des voies aeriennes',
                            value: _airwayBurnSigns,
                            onChanged: (v) => setState(() => _airwayBurnSigns = v),
                          ),
                          const Divider(height: 1),
                          _ToggleField(
                            label: 'Suie dans narines/bouche',
                            value: _sootInNostrilsOrMouth,
                            onChanged: (v) => setState(() => _sootInNostrilsOrMouth = v),
                          ),
                          const Divider(height: 1),
                          _ToggleField(
                            label: 'Enrouement / dysphonie',
                            value: _hoarsenessOrDysphonia,
                            onChanged: (v) => setState(() => _hoarsenessOrDysphonia = v),
                          ),
                          const Divider(height: 1),
                          _ToggleField(
                            label: 'Dyspnee',
                            value: _dyspnea,
                            onChanged: (v) => setState(() => _dyspnea = v),
                          ),
                          const Divider(height: 1),
                          _ToggleField(
                            label: 'Crachats noirâtres / hemoptysie',
                            value: _sootySputumOrHemoptysis,
                            onChanged: (v) => setState(() => _sootySputumOrHemoptysis = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Oxygenotherapie',
                      icon: Icons.air_outlined,
                      child: Column(
                        children: [
                          _ToggleField(
                            label: 'Oxygenotherapie necessaire',
                            value: _oxygenTherapyNeeded,
                            onChanged: (v) => setState(() => _oxygenTherapyNeeded = v),
                          ),
                          if (_oxygenTherapyNeeded) ...[
                            const SizedBox(height: 14),
                            _LabeledField(
                              label: 'Debit O2 (L/min)',
                              child: TextFormField(
                                controller: _oxygenFlowController,
                                decoration: _inputDecoration('Ex: 5'),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Gaz du sang (ABG)',
                      icon: Icons.science_outlined,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _LabeledField(
                                  label: 'pH (6.50 - 8.00)',
                                  child: TextFormField(
                                    controller: _abgPhController,
                                    decoration: _inputDecoration('7.35 - 7.45'),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    validator: (v) {
                                      if (v != null && v.trim().isNotEmpty) {
                                        final val = double.tryParse(v.trim());
                                        if (val != null && (val < 6.5 || val > 8.0)) {
                                          return 'Valeur hors plage';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _LabeledField(
                                  label: 'pCO2 (mmHg)',
                                  child: TextFormField(
                                    controller: _abgPco2Controller,
                                    decoration: _inputDecoration('35 - 45'),
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      if (v != null && v.trim().isNotEmpty) {
                                        final val = int.tryParse(v.trim());
                                        if (val != null && (val < 0 || val > 200)) {
                                          return 'Hors plage';
                                        }
                                      }
                                      return null;
                                    },
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
                                  label: 'pO2 (mmHg)',
                                  child: TextFormField(
                                    controller: _abgPo2Controller,
                                    decoration: _inputDecoration('80 - 100'),
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      if (v != null && v.trim().isNotEmpty) {
                                        final val = int.tryParse(v.trim());
                                        if (val != null && (val < 0 || val > 600)) {
                                          return 'Hors plage';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _LabeledField(
                                  label: 'HCO3 (mmol/L)',
                                  child: TextFormField(
                                    controller: _abgHco3Controller,
                                    decoration: _inputDecoration('22 - 26'),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    validator: (v) {
                                      if (v != null && v.trim().isNotEmpty) {
                                        final val = double.tryParse(v.trim());
                                        if (val != null && (val < 0 || val > 80)) {
                                          return 'Hors plage';
                                        }
                                      }
                                      return null;
                                    },
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
                      title: 'Radiographie thoracique',
                      icon: Icons.medical_services_outlined,
                      child: _LabeledField(
                        label: 'Resultats',
                        child: TextFormField(
                          controller: _chestXrayController,
                          decoration: _inputDecoration(
                              'Description des resultats radiologiques...'),
                          maxLines: 5,
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
                            _submitting ? 'Enregistrement...' : 'Enregistrer',
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

class _ToggleField extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch.adaptive(
              value: value,
              activeTrackColor: AppTheme.primaryColor,
              onChanged: onChanged,
            ),
          ),
        ],
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
