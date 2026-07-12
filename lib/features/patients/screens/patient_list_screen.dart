import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:burning2026/app/router/app_router.dart';
import 'package:burning2026/core/constants/api_constants.dart';
import 'package:burning2026/core/models/patient.dart';
import 'package:burning2026/core/theme/app_colors.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:http/http.dart' as http;

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final _searchController = TextEditingController();
  List<Patient> _allPatients = [];
  List<Patient> _filteredPatients = [];
  bool _loading = true;
  String _error = '';
  String? _severityFilter;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/patients');
      final response = await http.get(uri, headers: {'Accept': 'application/json'}).timeout(ApiConstants.timeout);
      if (!mounted) return;
      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body is Map<String, dynamic> && body['data'] is List) {
        _allPatients = (body['data'] as List)
            .map((e) => Patient.fromMap(Map<String, dynamic>.from(e)))
            .toList();
        _applyFilters();
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

  void _applyFilters() {
    setState(() {
      _filteredPatients = _allPatients.where((p) {
        final q = _searchController.text.toLowerCase();
        final matchesQuery = q.isEmpty
            || p.lastName.toLowerCase().contains(q)
            || p.firstName.toLowerCase().contains(q)
            || p.fullName.toLowerCase().contains(q)
            || p.ipp.toLowerCase().contains(q);
        final severity = p.latestAdmission?.severityLevel;
        final matchesFilter = _severityFilter == null || severity == _severityFilter;
        return matchesQuery && matchesFilter;
      }).toList();
    });
  }

  Color _severityColor(String? level) {
    switch (level) {
      case 'critique': return const Color(0xFFDC2626);
      case 'severe': return const Color(0xFFEA580C);
      case 'moderee': return const Color(0xFFF59E0B);
      case 'legere': return const Color(0xFF10B981);
      default: return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (_loading) {
      return Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(title: const Text('Patients hospitalises')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error.isNotEmpty && _allPatients.isEmpty) {
      return Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(title: const Text('Patients hospitalises')),
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
                  onPressed: _loadPatients,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final critCount = _allPatients.where((p) => p.latestAdmission?.severityLevel == 'critique').length;
    final sevCount = _allPatients.where((p) => p.latestAdmission?.severityLevel == 'severe').length;
    final modCount = _allPatients.where((p) => p.latestAdmission?.severityLevel == 'moderee').length;
    final faibleCount = _allPatients.where((p) => p.latestAdmission?.severityLevel == 'legere' || p.latestAdmission == null).length;

    return Scaffold(
      backgroundColor: colors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 170,
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
                    colors: [Color(0xFFE11D48), Color(0xFFBE123C), Color(0xFF881337)],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text('Patients hospitalises', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
                              onPressed: () => Navigator.pushNamed(context, AppRoutes.patientCreate),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => _applyFilters(),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'IPP ou nom du patient...',
                              hintStyle: const TextStyle(color: Colors.white60),
                              prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      onPressed: () { _searchController.clear(); _applyFilters(); },
                                      icon: const Icon(Icons.clear_rounded, color: Colors.white70),
                                    )
                                  : null,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              filled: false,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  _StatChip(label: 'Critique', count: critCount, color: _severityColor('critique')),
                  const SizedBox(width: 6),
                  _StatChip(label: 'Severe', count: sevCount, color: _severityColor('severe')),
                  const SizedBox(width: 6),
                  _StatChip(label: 'Moderee', count: modCount, color: _severityColor('moderee')),
                  const SizedBox(width: 6),
                  _StatChip(label: 'Faible', count: faibleCount, color: _severityColor('legere')),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _SeverityChip(label: 'Tous', selected: _severityFilter == null, onTap: () { setState(() => _severityFilter = null); _applyFilters(); }),
                  const SizedBox(width: 6),
                  _SeverityChip(label: 'Critique', selected: _severityFilter == 'critique', onTap: () { setState(() => _severityFilter = 'critique'); _applyFilters(); }),
                  const SizedBox(width: 6),
                  _SeverityChip(label: 'Severe', selected: _severityFilter == 'severe', onTap: () { setState(() => _severityFilter = 'severe'); _applyFilters(); }),
                  const SizedBox(width: 6),
                  _SeverityChip(label: 'Moderee', selected: _severityFilter == 'moderee', onTap: () { setState(() => _severityFilter = 'moderee'); _applyFilters(); }),
                  const SizedBox(width: 6),
                  _SeverityChip(label: 'Faible', selected: _severityFilter == 'legere', onTap: () { setState(() => _severityFilter = 'legere'); _applyFilters(); }),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          _filteredPatients.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(24)),
                          child: Icon(Icons.people_outline, size: 40, color: colors.textLight),
                        ),
                        const SizedBox(height: 16),
                        Text('Aucun patient trouve', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                        const SizedBox(height: 6),
                        Text('Essayez de modifier votre recherche.', style: TextStyle(color: colors.textSecondary)),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final p = _filteredPatients[index];
                      return Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
                        child: _PatientCard(
                          patient: p,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.patientDetail, arguments: {'patientId': p.id.toString()}),
                        ),
                      );
                    },
                    childCount: _filteredPatients.length,
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.patientCreate),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Ajouter patient'),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.2))),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

class _SeverityChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SeverityChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor : context.appColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppTheme.primaryColor : context.appColors.textLight.withValues(alpha: 0.3)),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : context.appColors.textSecondary)),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback? onTap;

  const _PatientCard({required this.patient, this.onTap});

  Color get _severityColor {
    switch (patient.latestAdmission?.severityLevel) {
      case 'critique': return const Color(0xFFDC2626);
      case 'severe': return const Color(0xFFEA580C);
      case 'moderee': return const Color(0xFFF59E0B);
      case 'legere': return const Color(0xFF10B981);
      default: return const Color(0xFF6B7280);
    }
  }

  Color get _tbsaColor {
    final tbsa = patient.latestAdmission?.tbsaPercentage ?? 0;
    if (tbsa < 10) return const Color(0xFF10B981);
    if (tbsa < 30) return const Color(0xFFF59E0B);
    return AppTheme.primaryColor;
  }

  Color get _avatarColor => patient.isFemale ? const Color(0xFFC62828) : const Color(0xFF1565C0);
  Color get _avatarBg => patient.isFemale ? const Color(0xFFFFEBEE) : const Color(0xFFE3F2FD);
  String get _severityLabel => patient.latestAdmission?.severityLevelDisplay ?? 'N/A';
  String get _bedCode => patient.latestAdmission?.bedCode ?? 'N/A';
  String get _burnCause => patient.latestAdmission?.burnCause ?? 'N/A';
  bool get _inhalation => patient.latestAdmission?.inhalationInjury ?? false;
  int get _tbsa => patient.latestAdmission?.tbsaPercentage.round() ?? 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: _avatarBg, borderRadius: BorderRadius.circular(16)),
                child: Center(child: Text(patient.initials, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _avatarColor))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(
                          '${patient.lastName} ${patient.firstName}${patient.age != null ? ', ${patient.age} ans' : ''}',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        )),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: _severityColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                          child: Text(_severityLabel.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _severityColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.badge_outlined, size: 12, color: colors.textSecondary),
                        const SizedBox(width: 3),
                        Text(patient.ipp, style: TextStyle(fontSize: 11, color: colors.textSecondary)),
                        const SizedBox(width: 14),
                        Icon(Icons.bed_outlined, size: 12, color: colors.textSecondary),
                        const SizedBox(width: 3),
                        Text(_bedCode, style: TextStyle(fontSize: 11, color: colors.textSecondary)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: _tbsaColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text('TBSA $_tbsa%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _tbsaColor)),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right_rounded, size: 18, color: colors.textSecondary),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.local_fire_department_rounded, size: 11, color: colors.textLight),
                        const SizedBox(width: 3),
                        Expanded(child: Text(_burnCause, style: TextStyle(fontSize: 10, color: colors.textLight), overflow: TextOverflow.ellipsis)),
                        if (_inhalation) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(color: AppTheme.warningColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text('Inhalation', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.warningColor)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
