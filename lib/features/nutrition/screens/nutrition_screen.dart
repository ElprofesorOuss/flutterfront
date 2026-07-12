import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:burning2026/core/constants/api_constants.dart';
import 'package:burning2026/core/models/nutrition_assessment.dart';
import 'package:burning2026/core/theme/app_colors.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:http/http.dart' as http;

class NutritionScreen extends StatefulWidget {
  final String admissionId;

  const NutritionScreen({super.key, required this.admissionId});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  List<NutritionAssessment> _assessments = [];
  bool _loading = true;
  String _error = '';
  bool _submitting = false;
  NutritionAssessment? _editing;

  @override
  void initState() {
    super.initState();
    _loadAssessments();
  }

  Future<void> _loadAssessments() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/admissions/${widget.admissionId}/nutrition');
      final response = await http.get(uri, headers: {'Accept': 'application/json'}).timeout(ApiConstants.timeout);
      if (!mounted) return;
      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body is Map<String, dynamic> && body['data'] is List) {
        _assessments = (body['data'] as List)
            .map((e) => NutritionAssessment.fromMap(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        _error = body is Map<String, dynamic>
            ? (body['message']?.toString() ?? 'Erreur de chargement.')
            : 'Erreur de chargement.';
      }
    } catch (_) {
      _error = 'Connexion au serveur impossible.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveAssessment(Map<String, dynamic> data) async {
    setState(() => _submitting = true);
    try {
      final isUpdate = _editing != null;
      final uri = isUpdate
          ? Uri.parse('${ApiConstants.baseUrl}/nutrition/${_editing!.id}')
          : Uri.parse('${ApiConstants.baseUrl}/admissions/${widget.admissionId}/nutrition');
      final http.Response response;
      if (isUpdate) {
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
      if ((response.statusCode == 200 || response.statusCode == 201) && body is Map<String, dynamic> && body['data'] != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isUpdate ? 'Évaluation mise à jour.' : 'Évaluation enregistrée.'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        _editing = null;
        _loadAssessments();
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
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _deleteAssessment(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Supprimer cette évaluation nutritionnelle ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer', style: TextStyle(color: AppTheme.errorColor))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/nutrition/$id');
      await http.delete(uri, headers: {'Accept': 'application/json'}).timeout(ApiConstants.timeout);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Évaluation supprimée.'), backgroundColor: AppTheme.successColor, behavior: SnackBarBehavior.floating),
        );
        _loadAssessments();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la suppression.'), backgroundColor: AppTheme.errorColor, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Color _riskColor(String? level) {
    switch (level) {
      case 'critique': return const Color(0xFFDC2626);
      case 'eleve': return const Color(0xFFF59E0B);
      case 'modere': return const Color(0xFF3B82F6);
      case 'faible': return const Color(0xFF10B981);
      default: return const Color(0xFF9CA3AF);
    }
  }

  Color _routeColor(String route) {
    switch (route) {
      case 'orale': return AppTheme.successColor;
      case 'enterale': return const Color(0xFF3B82F6);
      case 'parenterale': return const Color(0xFFF59E0B);
      case 'mixte': return const Color(0xFF8B5CF6);
      default: return const Color(0xFF9CA3AF);
    }
  }

  String _coverageLabel(double? percent) {
    if (percent == null) return 'N/A';
    if (percent >= 100) return 'Atteint';
    if (percent >= 80) return 'Proche';
    if (percent >= 50) return 'Insuffisant';
    return 'Critique';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: const Text('Nutrition du brûlé')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitting ? null : () {
          _editing = null;
          _showForm(context);
        },
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(_submitting ? 'Envoi...' : 'Ajouter'),
      ),
      body: _buildBody(colors),
    );
  }

  Widget _buildBody(AppColors colors) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty && _assessments.isEmpty) {
      return Center(
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
                onPressed: _loadAssessments,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }
    if (_assessments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(24)),
                child: const Icon(Icons.restaurant_outlined, size: 40, color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 16),
              Text('Aucune évaluation nutritionnelle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary)),
              const SizedBox(height: 8),
              Text('Ajoutez une évaluation avec le bouton +.', style: TextStyle(color: colors.textSecondary)),
            ],
          ),
        ),
      );
    }

    final latest = _assessments.first;
    final history = _assessments.length > 1 ? _assessments.sublist(1) : <NutritionAssessment>[];

    return RefreshIndicator(
      onRefresh: _loadAssessments,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          _buildLatestCard(latest, colors),
          const SizedBox(height: 16),
          _buildNeedsIntakeCard(latest, colors),
          const SizedBox(height: 16),
          _buildBiologyCard(latest, colors),
          const SizedBox(height: 16),
          _buildToleranceCard(latest, colors),
          if (latest.notes != null && latest.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildNotesCard(latest, colors),
          ],
          if (history.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Historique', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary)),
            const SizedBox(height: 12),
            ...history.map((a) => _buildHistoryItem(a, colors)),
          ],
        ],
      ),
    );
  }

  Widget _buildLatestCard(NutritionAssessment a, AppColors colors) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: AppTheme.primaryColor),
                const SizedBox(width: 6),
                Text(a.evaluationDateDisplay ?? a.evaluationDate, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _routeColor(a.nutritionRoute).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(a.nutritionRouteLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _routeColor(a.nutritionRoute))),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                _infoChip(colors, 'Poids', '${a.weightKg.toStringAsFixed(1)} kg', Icons.monitor_weight_outlined),
                const SizedBox(width: 8),
                _infoChip(colors, 'Taille', a.heightCm != null ? '${a.heightCm!.toStringAsFixed(0)} cm' : 'N/A', Icons.height_outlined),
                const SizedBox(width: 8),
                _infoChip(colors, 'IMC', a.bmi != null ? a.bmi!.toStringAsFixed(1) : 'N/A', Icons.calculate_outlined),
              ],
            ),
            if (a.weightVariationPercent != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.trending_up, size: 14, color: a.isWeightLossAlert == true ? AppTheme.errorColor : AppTheme.successColor),
                  const SizedBox(width: 4),
                  Text(
                    'Variation: ${a.weightVariationPercent!.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: a.isWeightLossAlert == true ? AppTheme.errorColor : AppTheme.successColor),
                  ),
                ],
              ),
            ],
            if (a.feedingStartedAt != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.play_circle_outline, size: 14, color: colors.textLight),
                  const SizedBox(width: 4),
                  Text('Début alimentation: ${a.feedingStartedAt}', style: TextStyle(fontSize: 12, color: colors.textLight)),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _riskBadge(a.nutritionRiskLevelLabel ?? a.nutritionRiskLevel ?? 'N/A', _riskColor(a.nutritionRiskLevel)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _statusBadge(a.nutritionStatusLabel ?? a.nutritionStatus ?? 'N/A'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeedsIntakeCard(NutritionAssessment a, AppColors colors) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart_rounded, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 6),
                const Text('Besoins vs Apports', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(height: 20),
            _nutrientRow(
              label: 'Calories',
              need: a.energyNeedKcal,
              received: a.caloriesReceivedKcal,
              unit: 'kcal/j',
              coveragePercent: a.caloricCoveragePercent,
              isAlert: a.isCaloricAlert,
              colors: colors,
            ),
            const SizedBox(height: 12),
            _nutrientRow(
              label: 'Protéines',
              need: a.proteinNeedG,
              received: a.proteinReceivedG,
              unit: 'g/j',
              coveragePercent: a.proteinCoveragePercent,
              isAlert: a.isProteinAlert,
              colors: colors,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiologyCard(NutritionAssessment a, AppColors colors) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.science_outlined, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 6),
                const Text('Biologie', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: _bioTile(
                    colors,
                    label: 'Albumine',
                    value: a.albuminGL != null ? '${a.albuminGL!.toStringAsFixed(1)} g/L' : 'N/A',
                    alert: a.isLowAlbuminAlert,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _bioTile(
                    colors,
                    label: 'Préalbumine',
                    value: a.prealbuminMgL != null ? '${a.prealbuminMgL!.toStringAsFixed(1)} mg/L' : 'N/A',
                    alert: null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToleranceCard(NutritionAssessment a, AppColors colors) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.checklist_rounded, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 6),
                const Text('Tolérance digestive', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(height: 20),
            if (a.digestiveToleranceLabel != null) ...[
              Row(
                children: [
                  Text('Tolérance: ', style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                  Text(a.digestiveToleranceLabel!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                _boolTile(colors, 'Vomissements', a.vomiting),
                const SizedBox(width: 16),
                _boolTile(colors, 'Diarrhée', a.diarrhea),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(NutritionAssessment a, AppColors colors) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notes_rounded, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 6),
                const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(height: 16),
            Text(a.notes!, style: TextStyle(fontSize: 13, height: 1.4, color: colors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(NutritionAssessment a, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            _editing = a;
            _showForm(context);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: _riskColor(a.nutritionRiskLevel).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.restaurant_outlined, size: 20, color: _riskColor(a.nutritionRiskLevel)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(a.evaluationDateDisplay ?? a.evaluationDate, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _routeColor(a.nutritionRoute).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(a.nutritionRouteLabel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: _routeColor(a.nutritionRoute))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Poids: ${a.weightKg.toStringAsFixed(1)} kg | Calories: ${a.energyNeedKcal.toStringAsFixed(0)} kcal/j',
                        style: TextStyle(fontSize: 11, color: colors.textLight),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppTheme.errorColor.withValues(alpha: 0.6),
                  onPressed: () => _deleteAssessment(a.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoChip(AppColors colors, String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.textLight.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppTheme.primaryColor),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.textPrimary)),
            Text(label, style: TextStyle(fontSize: 10, color: colors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _nutrientRow({
    required String label,
    required double need,
    required double? received,
    required String unit,
    required double? coveragePercent,
    required bool? isAlert,
    required AppColors colors,
  }) {
    final displayReceived = received ?? 0;
    final ratio = need > 0 ? (displayReceived / need).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
            const Spacer(),
            if (isAlert == true)
              const Icon(Icons.warning_amber_rounded, size: 14, color: AppTheme.errorColor),
            Text(' $displayReceived / $need $unit', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: colors.surface,
            valueColor: AlwaysStoppedAnimation(isAlert == true ? AppTheme.errorColor : AppTheme.successColor),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Couverture: ${coveragePercent?.toStringAsFixed(1) ?? 'N/A'}% - ${_coverageLabel(coveragePercent)}',
          style: TextStyle(fontSize: 11, color: isAlert == true ? AppTheme.errorColor : colors.textSecondary),
        ),
      ],
    );
  }

  Widget _bioTile(AppColors colors, {required String label, required String value, required bool? alert}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: alert == true ? AppTheme.errorColor.withValues(alpha: 0.3) : colors.textLight.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: alert == true ? AppTheme.errorColor : colors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: colors.textSecondary)),
        ],
      ),
    );
  }

  Widget _boolTile(AppColors colors, String label, bool? value) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            value == true ? Icons.check_circle : Icons.cancel_outlined,
            size: 18,
            color: value == true ? AppTheme.errorColor : AppTheme.successColor,
          ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13, color: colors.textPrimary)),
        ],
      ),
    );
  }

  Widget _riskBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ),
    );
  }

  Widget _statusBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6B7280).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
      ),
    );
  }

  void _showForm(BuildContext context) {
    final isUpdate = _editing != null;
    final formKey = GlobalKey<FormState>();

    String evaluationDate = _editing?.evaluationDate ?? DateTime.now().toIso8601String().split('T')[0];
    String nutritionRoute = _editing?.nutritionRoute ?? 'orale';
    String? feedingStartedAt = _editing?.feedingStartedAt;
    double weightKg = _editing?.weightKg ?? 70;
    double? usualWeightKg = _editing?.usualWeightKg;
    double? heightCm = _editing?.heightCm;
    double energyNeedKcal = _editing?.energyNeedKcal ?? 2000;
    double proteinNeedG = _editing?.proteinNeedG ?? 100;
    double? caloriesReceivedKcal = _editing?.caloriesReceivedKcal;
    double? proteinReceivedG = _editing?.proteinReceivedG;
    double? albuminGL = _editing?.albuminGL;
    double? prealbuminMgL = _editing?.prealbuminMgL;
    String? digestiveTolerance = _editing?.digestiveTolerance;
    bool vomiting = _editing?.vomiting ?? false;
    bool diarrhea = _editing?.diarrhea ?? false;
    String? nutritionRiskLevel = _editing?.nutritionRiskLevel;
    String? nutritionStatus = _editing?.nutritionStatus;
    String? notes = _editing?.notes;

    final routeOptions = ['orale', 'enterale', 'parenterale', 'mixte'];
    final routeLabels = {'orale': 'Orale', 'enterale': 'Entérale', 'parenterale': 'Parentérale', 'mixte': 'Mixte'};
    final riskOptions = ['faible', 'modere', 'eleve', 'critique'];
    final riskLabels = {'faible': 'Faible', 'modere': 'Modéré', 'eleve': 'Élevé', 'critique': 'Critique'};
    final statusOptions = ['normal', 'risque_denutrition', 'denutrition_moderee', 'denutrition_severe'];
    final statusLabels = {'normal': 'Normal', 'risque_denutrition': 'Risque dénutrition', 'denutrition_moderee': 'Dénutrition modérée', 'denutrition_severe': 'Dénutrition sévère'};
    final toleranceOptions = ['bonne', 'acceptable', 'mauvaise', 'intolerance'];
    final toleranceLabels = {'bonne': 'Bonne', 'acceptable': 'Acceptable', 'mauvaise': 'Mauvaise', 'intolerance': 'Intolérance'};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isUpdate ? 'Modifier évaluation' : 'Nouvelle évaluation',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: evaluationDate,
                        decoration: InputDecoration(
                          labelText: "Date d'évaluation",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        onChanged: (v) => evaluationDate = v,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: nutritionRoute,
                        decoration: InputDecoration(
                          labelText: 'Voie nutritionnelle',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        items: routeOptions.map((r) => DropdownMenuItem(value: r, child: Text(routeLabels[r] ?? r))).toList(),
                        onChanged: (v) => setDialogState(() => nutritionRoute = v!),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: weightKg.toStringAsFixed(1),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Poids (kg)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                              onChanged: (v) => weightKg = double.tryParse(v) ?? 70,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: usualWeightKg?.toStringAsFixed(1) ?? '',
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Poids habituel (kg)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              onChanged: (v) => usualWeightKg = double.tryParse(v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: heightCm?.toStringAsFixed(0) ?? '',
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Taille (cm)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        onChanged: (v) => heightCm = double.tryParse(v),
                      ),
                      const SizedBox(height: 16),
                      const Text('Besoins', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: energyNeedKcal.toStringAsFixed(0),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Énergie (kcal/j)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              onChanged: (v) => energyNeedKcal = double.tryParse(v) ?? 0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: proteinNeedG.toStringAsFixed(0),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Protéines (g/j)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              onChanged: (v) => proteinNeedG = double.tryParse(v) ?? 0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Apports', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: caloriesReceivedKcal?.toStringAsFixed(0) ?? '',
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Calories reçues',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              onChanged: (v) => caloriesReceivedKcal = double.tryParse(v),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: proteinReceivedG?.toStringAsFixed(0) ?? '',
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Protéines reçues',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              onChanged: (v) => proteinReceivedG = double.tryParse(v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Biologie', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: albuminGL?.toStringAsFixed(1) ?? '',
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Albumine (g/L)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              onChanged: (v) => albuminGL = double.tryParse(v),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: prealbuminMgL?.toStringAsFixed(1) ?? '',
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Préalbumine (mg/L)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              onChanged: (v) => prealbuminMgL = double.tryParse(v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Tolérance digestive', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: digestiveTolerance,
                        decoration: InputDecoration(
                          labelText: 'Tolérance',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        items: toleranceOptions.map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(toleranceLabels[t] ?? t),
                        )).toList(),
                        onChanged: (v) => setDialogState(() => digestiveTolerance = v),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Vomissements', style: TextStyle(fontSize: 13)),
                              value: vomiting,
                              activeColor: AppTheme.primaryColor,
                              onChanged: (v) => setDialogState(() => vomiting = v),
                            ),
                          ),
                          Expanded(
                            child: SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Diarrhée', style: TextStyle(fontSize: 13)),
                              value: diarrhea,
                              activeColor: AppTheme.primaryColor,
                              onChanged: (v) => setDialogState(() => diarrhea = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Risque & Statut', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: nutritionRiskLevel,
                              decoration: InputDecoration(
                                labelText: 'Risque',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              items: riskOptions.map((r) => DropdownMenuItem(value: r, child: Text(riskLabels[r] ?? r))).toList(),
                              onChanged: (v) => setDialogState(() => nutritionRiskLevel = v),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: nutritionStatus,
                              decoration: InputDecoration(
                                labelText: 'Statut',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              items: statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(statusLabels[s] ?? s))).toList(),
                              onChanged: (v) => setDialogState(() => nutritionStatus = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: notes ?? '',
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Notes',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.all(14),
                        ),
                        onChanged: (v) => notes = v,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitting ? null : () {
                            if (formKey.currentState!.validate()) {
                              final data = <String, dynamic>{
                                'evaluation_date': evaluationDate,
                                'weight_kg': weightKg,
                                'nutrition_route': nutritionRoute,
                                'energy_need_kcal': energyNeedKcal,
                                'protein_need_g': proteinNeedG,
                              };
                              if (usualWeightKg != null) data['usual_weight_kg'] = usualWeightKg;
                              if (heightCm != null) data['height_cm'] = heightCm;
                              if (feedingStartedAt != null) data['feeding_started_at'] = feedingStartedAt;
                              if (caloriesReceivedKcal != null) data['calories_received_kcal'] = caloriesReceivedKcal;
                              if (proteinReceivedG != null) data['protein_received_g'] = proteinReceivedG;
                              if (albuminGL != null) data['albumin_g_l'] = albuminGL;
                              if (prealbuminMgL != null) data['prealbumin_mg_l'] = prealbuminMgL;
                              if (digestiveTolerance != null) data['digestive_tolerance'] = digestiveTolerance;
                              data['vomiting'] = vomiting;
                              data['diarrhea'] = diarrhea;
                              if (nutritionRiskLevel != null) data['nutrition_risk_level'] = nutritionRiskLevel;
                              if (nutritionStatus != null) data['nutrition_status'] = nutritionStatus;
                              if (notes != null && notes!.trim().isNotEmpty) data['notes'] = notes;

                              Navigator.pop(ctx);
                              _saveAssessment(data);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(isUpdate ? 'Mettre à jour' : 'Enregistrer'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
