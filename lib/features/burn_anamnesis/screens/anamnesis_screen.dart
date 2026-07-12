import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:burning2026/core/constants/api_constants.dart';
import 'package:burning2026/core/models/burn_anamnesis.dart';
import 'package:burning2026/core/theme/app_colors.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:http/http.dart' as http;

class AnamnesisScreen extends StatefulWidget {
  final String admissionId;

  const AnamnesisScreen({super.key, required this.admissionId});

  @override
  State<AnamnesisScreen> createState() => _AnamnesisScreenState();
}

class _AnamnesisScreenState extends State<AnamnesisScreen> {
  bool _loading = true;
  bool _saving = false;
  bool _isUpdate = false;
  String _error = '';
  bool _didSave = false;

  final _formKey = GlobalKey<FormState>();

  DateTime? _accidentAt;
  final _accidentPlaceCtrl = TextEditingController();
  final _burnCauseCtrl = TextEditingController();
  final _responsibleAgentCtrl = TextEditingController();
  final _exposureDurationCtrl = TextEditingController();
  bool _lossOfConsciousness = false;
  bool _firstAidCooling = false;
  bool _firstAidAntiseptics = false;
  bool _firstAidEmergencyDressing = false;
  final _firstAidOtherCtrl = TextEditingController();
  final _firstAidNotesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAnamnesis();
  }

  @override
  void dispose() {
    _accidentPlaceCtrl.dispose();
    _burnCauseCtrl.dispose();
    _responsibleAgentCtrl.dispose();
    _exposureDurationCtrl.dispose();
    _firstAidOtherCtrl.dispose();
    _firstAidNotesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAnamnesis() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/admissions/${widget.admissionId}/anamnesis');
      final response = await http.get(uri, headers: {'Accept': 'application/json'}).timeout(ApiConstants.timeout);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic> && body['data'] != null) {
          final a = BurnAnamnesis.fromMap(Map<String, dynamic>.from(body['data']));
          _accidentAt = a.accidentAt != null ? DateTime.tryParse(a.accidentAt!) : null;
          _accidentPlaceCtrl.text = a.accidentPlace ?? '';
          _burnCauseCtrl.text = a.burnCause ?? '';
          _responsibleAgentCtrl.text = a.responsibleAgent ?? '';
          _exposureDurationCtrl.text = a.exposureDuration ?? '';
          _lossOfConsciousness = a.lossOfConsciousness;
          _firstAidCooling = a.firstAidCooling;
          _firstAidAntiseptics = a.firstAidAntiseptics;
          _firstAidEmergencyDressing = a.firstAidEmergencyDressing;
          _firstAidOtherCtrl.text = a.firstAidOther ?? '';
          _firstAidNotesCtrl.text = a.firstAidNotes ?? '';
          _isUpdate = true;
          _didSave = true;
        }
      }
    } catch (_) {
      _error = 'Connexion au serveur impossible.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final data = <String, dynamic>{
      if (_accidentAt != null) 'accident_at': _accidentAt!.toIso8601String(),
      if (_accidentPlaceCtrl.text.trim().isNotEmpty) 'accident_place': _accidentPlaceCtrl.text.trim(),
      if (_burnCauseCtrl.text.trim().isNotEmpty) 'burn_cause': _burnCauseCtrl.text.trim(),
      if (_responsibleAgentCtrl.text.trim().isNotEmpty) 'responsible_agent': _responsibleAgentCtrl.text.trim(),
      if (_exposureDurationCtrl.text.trim().isNotEmpty) 'exposure_duration': _exposureDurationCtrl.text.trim(),
      'loss_of_consciousness': _lossOfConsciousness,
      'first_aid_cooling': _firstAidCooling,
      'first_aid_antiseptics': _firstAidAntiseptics,
      'first_aid_emergency_dressing': _firstAidEmergencyDressing,
      if (_firstAidOtherCtrl.text.trim().isNotEmpty) 'first_aid_other': _firstAidOtherCtrl.text.trim(),
      if (_firstAidNotesCtrl.text.trim().isNotEmpty) 'first_aid_notes': _firstAidNotesCtrl.text.trim(),
    };

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/admissions/${widget.admissionId}/anamnesis');
      final http.Response response;
      if (_isUpdate) {
        response = await http.put(
          uri,
          headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
          body: jsonEncode(data),
        ).timeout(ApiConstants.timeout);
      } else {
        response = await http.post(
          uri,
          headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
          body: jsonEncode(data),
        ).timeout(ApiConstants.timeout);
      }
      if (!mounted) return;
      final body = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        _didSave = true;
        _isUpdate = true;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isUpdate ? 'Anamnèse mise à jour.' : 'Anamnèse enregistrée.'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
          if (body is Map<String, dynamic> && body['data'] != null) {
            final a = BurnAnamnesis.fromMap(Map<String, dynamic>.from(body['data']));
            _accidentAt = a.accidentAt != null ? DateTime.tryParse(a.accidentAt!) : null;
          }
        }
      } else {
        final msg = body is Map<String, dynamic>
            ? (body['message']?.toString() ?? 'Erreur lors de l\'enregistrement.')
            : 'Erreur lors de l\'enregistrement.';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: AppTheme.errorColor, behavior: SnackBarBehavior.floating),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connexion au serveur impossible.'), backgroundColor: AppTheme.errorColor, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _accidentAt ?? now,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 1)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_accidentAt ?? now),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;
    setState(() {
      _accidentAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (_loading) {
      return Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          title: const Text('Anamnèse'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          title: const Text('Anamnèse'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded, size: 64, color: colors.textLight.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text(_error, textAlign: TextAlign.center, style: TextStyle(color: colors.textSecondary, fontSize: 16)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadAnamnesis,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            collapsedHeight: 112,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE11D48), Color(0xFFF59E0B)],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.assignment_outlined, color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Anamnèse de la brûlure',
                                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _didSave ? 'Données cliniques enregistrées' : 'Nouvelle évaluation',
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionCard(
                      colors: colors,
                      title: 'Circonstances de l\'accident',
                      icon: Icons.info_outline_rounded,
                      color: const Color(0xFF3B82F6),
                      children: [
                        _dateTimePicker(colors),
                        const SizedBox(height: 14),
                        _textField('Lieu de l\'accident', 'Ex: Domicile, Travail, Extérieur...', _accidentPlaceCtrl, icon: Icons.location_on_outlined),
                        const SizedBox(height: 14),
                        _textField('Cause / Mécanisme', 'Ex: Thermique, Chimique, Électrique...', _burnCauseCtrl, icon: Icons.whatshot_outlined),
                        const SizedBox(height: 14),
                        _textField('Agent causal', 'Ex: Feu, Liquide chaud, Produit...', _responsibleAgentCtrl, icon: Icons.science_outlined),
                        const SizedBox(height: 14),
                        _textField('Durée d\'exposition', 'Ex: 5 min, Inconnu...', _exposureDurationCtrl, icon: Icons.timer_outlined),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sectionCard(
                      colors: colors,
                      title: 'État de conscience',
                      icon: Icons.psychology_outlined,
                      color: const Color(0xFF8B5CF6),
                      children: [
                        _switchTile(colors, 'Perte de connaissance initiale', _lossOfConsciousness, (v) {
                          setState(() => _lossOfConsciousness = v);
                        }, Icons.visibility_off_rounded),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sectionCard(
                      colors: colors,
                      title: 'Premiers secours',
                      icon: Icons.medical_services_outlined,
                      color: const Color(0xFF10B981),
                      children: [
                        _switchTile(colors, 'Refroidissement initial', _firstAidCooling, (v) {
                          setState(() => _firstAidCooling = v);
                        }, Icons.ac_unit_rounded),
                        const SizedBox(height: 4),
                        _switchTile(colors, 'Antiseptiques appliqués', _firstAidAntiseptics, (v) {
                          setState(() => _firstAidAntiseptics = v);
                        }, Icons.sanitizer_outlined),
                        const SizedBox(height: 4),
                        _switchTile(colors, 'Pansement d\'urgence', _firstAidEmergencyDressing, (v) {
                          setState(() => _firstAidEmergencyDressing = v);
                        }, Icons.medical_services_outlined),
                        const SizedBox(height: 14),
                        _textField('Autres gestes', 'Massage, Oxygène, etc.', _firstAidOtherCtrl, maxLines: 2, icon: Icons.add_circle_outline),
                        const SizedBox(height: 14),
                        _textField('Notes complémentaires', 'Observations, délai de prise en charge...', _firstAidNotesCtrl, maxLines: 3, icon: Icons.note_alt_outlined),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Icon(_isUpdate ? Icons.save_rounded : Icons.add_circle_outline, size: 22),
                        label: Text(
                          _saving ? 'Enregistrement...' : (_isUpdate ? 'Mettre à jour' : 'Créer l\'anamnèse'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required AppColors colors,
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: color, width: 3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 19),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary)),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _dateTimePicker(AppColors colors) {
    final display = _accidentAt != null
        ? '${_accidentAt!.day.toString().padLeft(2, '0')}/${_accidentAt!.month.toString().padLeft(2, '0')}/${_accidentAt!.year}  ${_accidentAt!.hour.toString().padLeft(2, '0')}:${_accidentAt!.minute.toString().padLeft(2, '0')}'
        : 'Sélectionner la date et l\'heure';
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _pickDateTime,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF3B82F6), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date et heure de l\'accident',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(display,
                        style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600,
                          color: _accidentAt != null ? colors.textPrimary : colors.textLight,
                        )),
                  ],
                ),
              ),
              Icon(Icons.edit_calendar_rounded, size: 18, color: const Color(0xFF3B82F6).withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(String label, String hint, TextEditingController ctrl, {int maxLines = 1, IconData? icon}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      inputFormatters: maxLines == 1 ? [LengthLimitingTextInputFormatter(120)] : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 16 : 14),
      ),
    );
  }

  Widget _switchTile(AppColors colors, String label, bool value, ValueChanged<bool> onChanged, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: value
                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                  : colors.textLight.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                size: 18,
                color: value ? AppTheme.primaryColor : colors.textLight),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                )),
          ),
          Switch(
            value: value,
            activeColor: AppTheme.primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
