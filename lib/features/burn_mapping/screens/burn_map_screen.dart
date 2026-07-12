import 'dart:convert';

import 'package:burning2026/core/constants/api_constants.dart';
import 'package:burning2026/core/models/burn_injury.dart';
import 'package:burning2026/core/theme/app_colors.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:burning2026/features/burn_mapping/widgets/body_map_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BurnMapScreen extends StatefulWidget {
  final String admissionId;

  const BurnMapScreen({super.key, required this.admissionId});

  @override
  State<BurnMapScreen> createState() => _BurnMapScreenState();
}

class _BurnMapScreenState extends State<BurnMapScreen>
    with SingleTickerProviderStateMixin {
  List<BurnInjury> _zones = [];
  double _tbsa = 0;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  bool _showBack = false;
  late final TabController _tabController;

  static const List<Map<String, String>> _bodyParts = [
    {'value': 'head_front', 'label': 'Tete face'},
    {'value': 'head_back', 'label': 'Tete dos'},
    {'value': 'torso_front', 'label': 'Tronc anterieur'},
    {'value': 'torso_back', 'label': 'Tronc posterieur'},
    {'value': 'left_arm_front_upper', 'label': 'Bras gauche face'},
    {'value': 'left_arm_front_forearm', 'label': 'Avant-bras gauche face'},
    {'value': 'left_hand_front', 'label': 'Main gauche face'},
    {'value': 'left_arm_back_upper', 'label': 'Bras gauche dos'},
    {'value': 'left_arm_back_forearm', 'label': 'Avant-bras gauche dos'},
    {'value': 'left_hand_back', 'label': 'Main gauche dos'},
    {'value': 'right_arm_front_upper', 'label': 'Bras droit face'},
    {'value': 'right_arm_front_forearm', 'label': 'Avant-bras droit face'},
    {'value': 'right_hand_front', 'label': 'Main droite face'},
    {'value': 'right_arm_back_upper', 'label': 'Bras droit dos'},
    {'value': 'right_arm_back_forearm', 'label': 'Avant-bras droit dos'},
    {'value': 'right_hand_back', 'label': 'Main droite dos'},
    {'value': 'left_thigh_front', 'label': 'Cuisse gauche face'},
    {'value': 'left_leg_front_lower', 'label': 'Jambe gauche face'},
    {'value': 'left_foot_front', 'label': 'Pied gauche face'},
    {'value': 'left_thigh_back', 'label': 'Cuisse gauche dos'},
    {'value': 'left_leg_back_lower', 'label': 'Jambe gauche dos'},
    {'value': 'left_foot_back', 'label': 'Pied gauche dos'},
    {'value': 'right_thigh_front', 'label': 'Cuisse droite face'},
    {'value': 'right_leg_front_lower', 'label': 'Jambe droite face'},
    {'value': 'right_foot_front', 'label': 'Pied droit face'},
    {'value': 'right_thigh_back', 'label': 'Cuisse droite dos'},
    {'value': 'right_leg_back_lower', 'label': 'Jambe droite dos'},
    {'value': 'right_foot_back', 'label': 'Pied droit dos'},
    {'value': 'perineum', 'label': 'Perinee'},
  ];

  static const List<Map<String, String>> _degreeOptions = [
    {'value': '1st', 'label': '1er degre'},
    {'value': '2nd_superficial', 'label': '2e superficiel'},
    {'value': '2nd_deep', 'label': '2e profond'},
    {'value': '3rd', 'label': '3e degre'},
  ];

  static const List<String> _degreeCycle = [
    '',
    '1st',
    '2nd_superficial',
    '2nd_deep',
    '3rd',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadZones();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadZones() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/admissions/${widget.admissionId}/burn-injuries',
      );
      final response = await http.get(uri).timeout(ApiConstants.timeout);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>;
        final parsed = BurnInjuryResponse.fromMap(data);

        setState(() {
          _zones = parsed.zones;
          _tbsa = parsed.tbsaPercentage;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Erreur serveur (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Erreur reseau';
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/admissions/${widget.admissionId}/burn-injuries',
      );
      final payload = jsonEncode({
        'zones': _zones.map((zone) => zone.toMap()).toList(),
      });

      final response = await http
          .put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: payload,
          )
          .timeout(ApiConstants.timeout);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>;
        final parsed = BurnInjuryResponse.fromMap(data);

        setState(() {
          _zones = parsed.zones;
          _tbsa = parsed.tbsaPercentage;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cartographie enregistree'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l enregistrement'),
            backgroundColor: Color(0xFFEF5350),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur reseau'),
          backgroundColor: Color(0xFFEF5350),
        ),
      );
    }
  }

  void _tapZone(String bodyPart) {
    final existing = _zones.where((zone) => zone.bodyPart == bodyPart).toList();

    if (existing.isEmpty) {
      _showZoneForm(bodyPart: bodyPart);
      return;
    }

    final currentDegree = existing.first.degree;
    final currentIndex = _degreeCycle.indexOf(currentDegree);
    final nextIndex = (currentIndex + 1) % _degreeCycle.length;
    final nextDegree = _degreeCycle[nextIndex];

    setState(() {
      _zones.removeWhere((zone) => zone.bodyPart == bodyPart);

      if (nextDegree.isNotEmpty) {
        _zones.add(
          BurnInjury(
            bodyPart: bodyPart,
            degree: nextDegree,
            surfaceArea: _defaultArea(bodyPart),
          ),
        );
      }

      _tbsa = _computeTbsa(_zones);
    });
  }

  double _defaultArea(String bodyPart) {
    const areas = {
      'head_front': 4.5,
      'head_back': 4.5,
      'torso_front': 13.0,
      'torso_back': 13.0,
      'left_arm_front_upper': 2.0,
      'left_arm_front_forearm': 1.5,
      'left_hand_front': 1.0,
      'left_arm_back_upper': 2.0,
      'left_arm_back_forearm': 1.5,
      'left_hand_back': 1.0,
      'right_arm_front_upper': 2.0,
      'right_arm_front_forearm': 1.5,
      'right_hand_front': 1.0,
      'right_arm_back_upper': 2.0,
      'right_arm_back_forearm': 1.5,
      'right_hand_back': 1.0,
      'left_thigh_front': 4.5,
      'left_leg_front_lower': 3.0,
      'left_foot_front': 1.75,
      'left_thigh_back': 4.5,
      'left_leg_back_lower': 3.0,
      'left_foot_back': 1.75,
      'right_thigh_front': 4.5,
      'right_leg_front_lower': 3.0,
      'right_foot_front': 1.75,
      'right_thigh_back': 4.5,
      'right_leg_back_lower': 3.0,
      'right_foot_back': 1.75,
      'perineum': 1.0,
    };

    return areas[bodyPart] ?? 2.0;
  }

  void _showZoneForm({String? bodyPart, BurnInjury? existing}) {
    String selectedBodyPart = existing?.bodyPart ?? bodyPart ?? '';
    String selectedDegree = existing?.degree ?? '2nd_superficial';
    final areaController = TextEditingController(
      text: (existing?.surfaceArea ?? _defaultArea(selectedBodyPart)).toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(sheetContext).viewInsets.bottom + 16,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.edit_location_alt_rounded,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                existing == null && bodyPart == null
                                    ? 'Ajouter une zone'
                                    : 'Parametres de la zone',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'Surface, profondeur et lateralite anatomique',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (bodyPart == null && existing == null)
                      DropdownButtonFormField<String>(
                        initialValue:
                            selectedBodyPart.isNotEmpty ? selectedBodyPart : null,
                        decoration: const InputDecoration(
                          labelText: 'Zone anatomique',
                          border: OutlineInputBorder(),
                        ),
                        items: _bodyParts
                            .map(
                              (part) => DropdownMenuItem<String>(
                                value: part['value'],
                                child: Text(part['label']!),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setSheetState(() {
                            selectedBodyPart = value ?? '';
                            areaController.text =
                                _defaultArea(selectedBodyPart).toString();
                          });
                        },
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: context.appColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _labelForPart(selectedBodyPart),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedDegree,
                      decoration: const InputDecoration(
                        labelText: 'Degre',
                        border: OutlineInputBorder(),
                      ),
                      items: _degreeOptions
                          .map(
                            (degree) => DropdownMenuItem<String>(
                              value: degree['value'],
                              child: Text(degree['label']!),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setSheetState(() {
                          selectedDegree = value ?? '2nd_superficial';
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: areaController,
                      decoration: const InputDecoration(
                        labelText: 'Surface (%)',
                        suffixText: '%',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          if (selectedBodyPart.isEmpty) return;

                          final area =
                              double.tryParse(areaController.text.trim()) ?? 0;
                          if (area <= 0) return;

                          Navigator.of(sheetContext).pop();
                          setState(() {
                            _zones.removeWhere(
                              (zone) => zone.bodyPart == selectedBodyPart,
                            );
                            _zones.add(
                              BurnInjury(
                                bodyPart: selectedBodyPart,
                                degree: selectedDegree,
                                surfaceArea: area,
                              ),
                            );
                            _tbsa = _computeTbsa(_zones);
                          });
                        },
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text('Valider la zone'),
                      ),
                    ),
                    if (existing != null || bodyPart != null) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                            setState(() {
                              _zones.removeWhere(
                                (zone) => zone.bodyPart == selectedBodyPart,
                              );
                              _tbsa = _computeTbsa(_zones);
                            });
                          },
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Supprimer cette zone'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  double _computeTbsa(List<BurnInjury> zones) {
    final total = zones.fold<double>(
      0,
      (sum, zone) => sum + zone.surfaceArea,
    );

    return double.parse(total.toStringAsFixed(2));
  }

  Color _degreeColor(String degree) {
    switch (degree) {
      case '1st':
        return const Color(0xFFF59E0B);
      case '2nd_superficial':
        return const Color(0xFFEF4444);
      case '2nd_deep':
        return const Color(0xFFDC2626);
      case '3rd':
        return const Color(0xFF7F1D1D);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _labelForPart(String bodyPart) {
    return _bodyParts.firstWhere(
      (part) => part['value'] == bodyPart,
      orElse: () => {'value': bodyPart, 'label': bodyPart},
    )['label']!;
  }

  String _orientationForPart(String bodyPart) {
    if (bodyPart == 'perineum') return 'Zone critique';
    if (bodyPart.contains('left')) return 'Gauche';
    if (bodyPart.contains('right')) return 'Droite';
    if (bodyPart.contains('back')) return 'Dos';
    return 'Face';
  }

  List<BodyZone> _buildBodyZones() {
    final keys = _bodyParts
        .where((part) {
          final value = part['value']!;
          return _showBack
              ? value.contains('_back') || value == 'perineum'
              : value.contains('_front') || value == 'perineum';
        })
        .map((part) => part['value']!)
        .toList();

    return keys.map((key) {
      final existing = _zones.where((zone) => zone.bodyPart == key).toList();
      final label = _labelForPart(key);

      return BodyZone(
        key: key,
        label: label,
        degree: existing.isNotEmpty ? existing.first.degree : null,
        onTap: () => _tapZone(key),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Cartographie des lesions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: colors.textLight,
          tabs: const [
            Tab(
              text: 'Schema',
              icon: Icon(Icons.accessibility_new_rounded, size: 20),
            ),
            Tab(
              text: 'Liste',
              icon: Icon(Icons.list_alt_rounded, size: 20),
            ),
          ],
        ),
        actions: [
          if (!_isLoading && _error == null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _isSaving
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : TextButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save_rounded, size: 18),
                      label: const Text('Enregistrer'),
                    ),
            ),
        ],
      ),
      floatingActionButton: _error == null
          ? FloatingActionButton.extended(
              onPressed: () => _showZoneForm(),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Ajouter zone'),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState(colors)
              : Column(
                  children: [
                    _buildHeroHeader(colors),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildBodyMap(colors),
                          _buildListView(colors),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildErrorState(AppColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 64, color: colors.textLight),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _loadZones,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(AppColors colors) {
    final tbsaColor = _tbsa >= 20
        ? const Color(0xFFDC2626)
        : _tbsa >= 10
            ? const Color(0xFFF59E0B)
            : const Color(0xFF10B981);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC2626).withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cartographie mobile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Saisie detaillee face, dos, gauche, droite et profondeur',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (_zones.isNotEmpty)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _zones.clear();
                      _tbsa = 0;
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.14),
                  ),
                  icon: const Icon(
                    Icons.delete_sweep_rounded,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _metricCard(
                  label: 'TBSA total',
                  value: '${_tbsa.toStringAsFixed(1)}%',
                  accent: tbsaColor,
                  icon: Icons.monitor_heart_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricCard(
                  label: 'Zones',
                  value: '${_zones.length}',
                  accent: const Color(0xFF2563EB),
                  icon: Icons.grid_view_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _softPill(
                  icon: Icons.touch_app_rounded,
                  label: 'Tap pour renseigner une zone',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _softPill(
                  icon: _showBack
                      ? Icons.flip_to_back_rounded
                      : Icons.face_retouching_natural,
                  label: _showBack ? 'Vue dos active' : 'Vue face active',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _metricCard({
    required String label,
    required String value,
    required Color accent,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _softPill({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.90),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _legendChip(const Color(0xFFF59E0B), '1er'),
        const SizedBox(width: 6),
        _legendChip(const Color(0xFFEF4444), 'Sup'),
        const SizedBox(width: 6),
        _legendChip(const Color(0xFFDC2626), 'Prof'),
        const SizedBox(width: 6),
        _legendChip(const Color(0xFF7F1D1D), '3e'),
      ],
    );
  }

  Widget _legendChip(Color color, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.92),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyMap(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _viewToggle('Face', false, colors)),
                      const SizedBox(width: 8),
                      Expanded(child: _viewToggle('Dos', true, colors)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _infoMiniCard(
                        colors: colors,
                        icon: Icons.swipe_rounded,
                        title: 'Interaction',
                        value: 'Tap pour modifier',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _infoMiniCard(
                        colors: colors,
                        icon: Icons.person_pin_circle_rounded,
                        title: 'Laterality',
                        value: 'Gauche / Droite separees',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors.surface,
                          colors.card.withValues(alpha: 0.92),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: BodyMapWidget(
                      zones: _buildBodyZones(),
                      showBack: _showBack,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewToggle(String label, bool isBack, AppColors colors) {
    final selected = _showBack == isBack;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _showBack = isBack),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor : colors.card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.22),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isBack ? Icons.flip_to_back_rounded : Icons.face_rounded,
              size: 18,
              color: selected ? Colors.white : colors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoMiniCard({
    required AppColors colors,
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(AppColors colors) {
    if (_zones.isEmpty) {
      return _emptyState(colors);
    }

    final sortedZones = [..._zones]
      ..sort((first, second) => first.bodyPart.compareTo(second.bodyPart));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zones enregistrees',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vue clinique detaillee avec profondeur et surface',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: _showZoneForm,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Ajouter'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sortedZones.length,
            itemBuilder: (context, index) {
              final zone = sortedZones[index];
              final degreeColor = _degreeColor(zone.degree);

              return Dismissible(
                key: ValueKey(zone.bodyPart),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF5350),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (_) {
                  setState(() {
                    _zones.removeWhere(
                      (item) => item.bodyPart == zone.bodyPart,
                    );
                    _tbsa = _computeTbsa(_zones);
                  });
                },
                child: Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  color: colors.card,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _showZoneForm(existing: zone),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: degreeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.whatshot_rounded,
                              color: degreeColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _labelForPart(zone.bodyPart),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _listChip(
                                      colors,
                                      '${zone.surfaceArea.toStringAsFixed(1)}%',
                                    ),
                                    _listChip(
                                      colors,
                                      _orientationForPart(zone.bodyPart),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: degreeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              zone.degreeLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: degreeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _listChip(AppColors colors, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: colors.textSecondary,
        ),
      ),
    );
  }

  Widget _emptyState(AppColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF97316), Color(0xFFEF4444)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.add_chart_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Aucune zone cartographiee',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Utilise l onglet Schema ou le bouton Ajouter pour saisir la localisation, la profondeur et la surface.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => _tabController.animateTo(0),
              icon: const Icon(Icons.accessibility_new_rounded),
              label: const Text('Aller au schema'),
            ),
          ],
        ),
      ),
    );
  }
}
