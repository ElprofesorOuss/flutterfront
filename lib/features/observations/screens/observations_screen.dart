import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:burning2026/core/constants/api_constants.dart';
import 'package:burning2026/core/models/clinical_observation.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:burning2026/core/theme/app_colors.dart';
import 'package:http/http.dart' as http;

class ObservationsScreen extends StatefulWidget {
  final String admissionId;

  const ObservationsScreen({super.key, required this.admissionId});

  @override
  State<ObservationsScreen> createState() => _ObservationsScreenState();
}

class _ObservationsScreenState extends State<ObservationsScreen> {
  List<ClinicalObservation> _observations = [];
  bool _loading = true;
  String _error = '';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadObservations();
  }

  Future<void> _loadObservations() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/hospitalisations/${widget.admissionId}/observations');
      final response = await http.get(uri, headers: {'Accept': 'application/json'}).timeout(ApiConstants.timeout);
      if (!mounted) return;
      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body is Map<String, dynamic> && body['data'] is List) {
        _observations = (body['data'] as List).map((e) => ClinicalObservation.fromMap(Map<String, dynamic>.from(e))).toList();
      } else {
        _error = body is Map<String, dynamic> ? (body['message']?.toString() ?? 'Erreur de chargement.') : 'Erreur de chargement.';
      }
    } catch (_) {
      _error = 'Connexion au serveur impossible.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addObservation(Map<String, dynamic> data) async {
    setState(() => _submitting = true);
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/hospitalisations/${widget.admissionId}/observations');
      final response = await http.post(
        uri,
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(ApiConstants.timeout);
      if (!mounted) return;
      final body = jsonDecode(response.body);
      if (response.statusCode == 201 && body is Map<String, dynamic> && body['data'] != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Observation ajoutée avec succès.'), backgroundColor: AppTheme.successColor, behavior: SnackBarBehavior.floating),
          );
        }
        _loadObservations();
      } else {
        final msg = body is Map<String, dynamic> ? (body['message']?.toString() ?? 'Erreur lors de l\'enregistrement.') : 'Erreur lors de l\'enregistrement.';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppTheme.errorColor, behavior: SnackBarBehavior.floating));
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connexion au serveur impossible.'), backgroundColor: AppTheme.errorColor, behavior: SnackBarBehavior.floating));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'evolution': return const Color(0xFF3B82F6);
      case 'douleur': return AppTheme.primaryColor;
      case 'pansement': return const Color(0xFF10B981);
      case 'respiration': return const Color(0xFF8B5CF6);
      case 'hemodynamique': return const Color(0xFFEC4899);
      case 'nutrition': return const Color(0xFFF59E0B);
      case 'infection': return const Color(0xFFDC2626);
      case 'chirurgie': return const Color(0xFF6B7280);
      case 'autre': return const Color(0xFF9CA3AF);
      default: return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: const Text('Observations rapides')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitting ? null : () => _showAddDialog(context),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_comment_rounded),
        label: Text(_submitting ? 'Envoi...' : 'Ajouter'),
      ),
      body: _buildBody(colors),
    );
  }

  Widget _buildBody(AppColors colors) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty && _observations.isEmpty) {
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
                onPressed: _loadObservations,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }
    if (_observations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(24)),
                child: const Icon(Icons.note_add_outlined, size: 40, color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 16),
              Text('Aucune observation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary)),
              const SizedBox(height: 8),
              Text('Ajoutez une observation avec le bouton +.', style: TextStyle(color: colors.textSecondary)),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadObservations,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: _observations.length,
        itemBuilder: (context, index) {
          final obs = _observations[index];
          final catColor = _categoryColor(obs.category);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: obs.isCritical ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)) : null,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(color: catColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                            child: Icon(_categoryIcon(obs.category), color: catColor, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: catColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                                      child: Text(obs.categoryLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: catColor)),
                                    ),
                                    const SizedBox(width: 6),
                                    if (obs.isCritical)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                                        child: const Text('CRITIQUE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.person_outline, size: 10, color: colors.textLight),
                                    const SizedBox(width: 3),
                                    Text(obs.authorName, style: TextStyle(fontSize: 10, color: colors.textLight)),
                                    const SizedBox(width: 10),
                                    Icon(Icons.access_time, size: 10, color: colors.textLight),
                                    const SizedBox(width: 3),
                                    Text(obs.formattedObservedAt, style: TextStyle(fontSize: 10, color: colors.textLight)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(obs.note, style: TextStyle(fontSize: 13, height: 1.4, color: colors.textPrimary)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'evolution': return Icons.trending_up;
      case 'douleur': return Icons.healing;
      case 'pansement': return Icons.medical_services_outlined;
      case 'respiration': return Icons.air;
      case 'hemodynamique': return Icons.favorite_border;
      case 'nutrition': return Icons.restaurant_outlined;
      case 'infection': return Icons.bug_report_outlined;
      case 'chirurgie': return Icons.biotech_outlined;
      case 'autre': return Icons.notes_rounded;
      case 'medicale': return Icons.local_hospital_outlined;
      case 'infirmiere': return Icons.medical_services_outlined;
      case 'chirurgicale': return Icons.content_cut;
      case 'transmission': return Icons.forum_outlined;
      default: return Icons.note_add_outlined;
    }
  }

  void _showAddDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String category = ClinicalObservation.categories.first;
    String note = '';
    bool isCritical = false;

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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Nouvelle observation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: InputDecoration(
                        labelText: 'Catégorie',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      items: ClinicalObservation.categories.map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(ClinicalObservation.categoryLabels[c] ?? c),
                      )).toList(),
                      onChanged: (v) => setDialogState(() => category = v!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Note clinique',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'La note est obligatoire.' : null,
                      onChanged: (v) => note = v,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Critique', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Marquer comme observation critique', style: TextStyle(fontSize: 12)),
                      value: isCritical,
                      activeColor: AppTheme.primaryColor,
                      onChanged: (v) => setDialogState(() => isCritical = v),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : () {
                          if (formKey.currentState!.validate()) {
                            Navigator.pop(ctx);
                            _addObservation({
                              'category': category,
                              'note': note,
                              'is_critical': isCritical,
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(_submitting ? 'Envoi en cours...' : 'Enregistrer'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
