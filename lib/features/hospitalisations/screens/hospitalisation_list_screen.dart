import 'dart:convert';

import 'package:burning2026/app/router/app_router.dart';
import 'package:burning2026/core/constants/api_constants.dart';
import 'package:burning2026/core/theme/app_colors.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HospitalisationListScreen extends StatefulWidget {
  const HospitalisationListScreen({super.key});

  @override
  State<HospitalisationListScreen> createState() =>
      _HospitalisationListScreenState();
}

class _HospitalisationListScreenState extends State<HospitalisationListScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadHospitalisations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHospitalisations() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final query = _searchController.text.trim();
      final uri = Uri.parse('${ApiConstants.baseUrl}/hospitalisations')
          .replace(queryParameters: query.isEmpty ? null : {'search': query});

      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(ApiConstants.timeout);

      if (!mounted) return;

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final data = body['data'];
        if (data is List) {
          _items = data
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      } else {
        _error = body is Map<String, dynamic>
            ? (body['message']?.toString() ?? 'Erreur de chargement.')
            : 'Erreur de chargement.';
      }
    } catch (_) {
      _error = 'Connexion au serveur impossible.';
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _initials(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return '?';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName[0].toUpperCase();
  }

  Color _avatarBg(String? gender) {
    return gender == 'femme'
        ? const Color(0xFFFFEBEE)
        : const Color(0xFFE3F2FD);
  }

  Color _avatarFg(String? gender) {
    return gender == 'femme'
        ? const Color(0xFFC62828)
        : const Color(0xFF1565C0);
  }

  Color _severityColor(String? level) {
    switch (level) {
      case 'critique':
        return const Color(0xFFDC2626);
      case 'severe':
        return const Color(0xFFEA580C);
      case 'moderee':
        return const Color(0xFFF59E0B);
      case 'legere':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'urgences':
        return 'Urgences';
      case 'rea':
        return 'Reanimation';
      case 'bloc':
        return 'Bloc';
      case 'sortie':
        return 'Sortie';
      default:
        return status ?? '-';
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'urgences':
        return const Color(0xFFF59E0B);
      case 'rea':
        return AppTheme.primaryColor;
      case 'bloc':
        return const Color(0xFF8B5CF6);
      case 'sortie':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _statusBg(String? status) {
    switch (status) {
      case 'urgences':
        return const Color(0xFFFFF3E0);
      case 'rea':
        return const Color(0xFFFFEBEE);
      case 'bloc':
        return const Color(0xFFF3E8FF);
      case 'sortie':
        return const Color(0xFFE8F5E9);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final reaCount = _items.where((i) => i['status'] == 'rea').length;
    final urgCount = _items.where((i) => i['status'] == 'urgences').length;
    final blocCount = _items.where((i) => i['status'] == 'bloc').length;
    final sortieCount = _items.where((i) => i['status'] == 'sortie').length;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Hospitalisations'),
        actions: [
          IconButton(
            onPressed: _loadHospitalisations,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _loadHospitalisations(),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'IPP, IEP ou nom du patient...',
                      hintStyle: const TextStyle(color: Colors.white60),
                      prefixIcon:
                          const Icon(Icons.search_rounded, color: Colors.white70),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _loadHospitalisations();
                              },
                              icon: const Icon(Icons.clear_rounded,
                                  color: Colors.white70),
                            )
                          : null,
                      filled: false,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _statChip(Icons.local_hospital_rounded, 'Rea', '$reaCount',
                        const Color(0xFFFFEBEE), AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    _statChip(Icons.emergency_rounded, 'Urgences', '$urgCount',
                        const Color(0xFFFFF3E0), const Color(0xFFF59E0B)),
                    const SizedBox(width: 8),
                    _statChip(Icons.biotech_rounded, 'Bloc', '$blocCount',
                        const Color(0xFFF3E8FF), const Color(0xFF8B5CF6)),
                    const SizedBox(width: 8),
                    _statChip(Icons.home_rounded, 'Sortie', '$sortieCount',
                        const Color(0xFFE8F5E9), const Color(0xFF10B981)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.cloud_off_rounded,
                                  size: 64, color: colors.textSecondary),
                              const SizedBox(height: 16),
                              Text(_error,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: colors.textSecondary,
                                      fontSize: 16)),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _loadHospitalisations,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Reessayer'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _items.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFEBEE),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Icon(
                                      Icons.local_hospital_outlined,
                                      size: 40,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucune hospitalisation',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Aucune hospitalisation trouvee.\nAjoutez-en une avec le bouton +.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadHospitalisations,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                              itemCount: _items.length,
                              itemBuilder: (context, index) {
                                final item = _items[index];
                                final patient =
                                    Map<String, dynamic>.from(item['patient'] ?? const {});
                                final lit = Map<String, dynamic>.from(item['lit'] ?? const {});
                                final salle =
                                    Map<String, dynamic>.from(lit['salle'] ?? const {});
                                final fullName =
                                    patient['full_name']?.toString() ?? 'Patient inconnu';
                                final gender = patient['gender'] as String?;
                                final severity = item['severity'] as Map<String, dynamic>?;
                                final sevLevel = severity?['severity_level'] as String?;
                                final tbsa = (item['tbsa_percentage'] as num?)?.toDouble() ?? 0;
                                final status = item['status'] as String?;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _PatientCard(
                                    initials: _initials(fullName),
                                    avatarBg: _avatarBg(gender),
                                    avatarFg: _avatarFg(gender),
                                    fullName: fullName,
                                    ipp: patient['ipp']?.toString() ?? '-',
                                    iep: item['visit_number']?.toString() ?? '-',
                                    litCode: salle['code'] != null
                                        ? '[${salle['code']}] ${lit['code'] ?? '-'}'
                                        : '${lit['code'] ?? '-'}',
                                    tbsa: tbsa,
                                    severityLevel: sevLevel,
                                    severityColor: _severityColor(sevLevel),
                                    status: status,
                                    statusLabel: _statusLabel(status),
                                    statusColor: _statusColor(status),
                                    statusBg: _statusBg(status),
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.hospitalisationDetail,
                                      arguments: {
                                        'hospitalisationId': '${item['id']}',
                                      },
                                    ).then((_) => _loadHospitalisations()),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.pushNamed(
            context,
            AppRoutes.hospitalisationCreate,
          );
          if (created == true) {
            _loadHospitalisations();
          }
        },
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_home_work_outlined),
        label: const Text('Nouvelle'),
      ),
    );
  }

  Widget _statChip(IconData icon, String label, String count, Color bg, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final String initials;
  final Color avatarBg;
  final Color avatarFg;
  final String fullName;
  final String ipp;
  final String iep;
  final String litCode;
  final double tbsa;
  final String? severityLevel;
  final Color severityColor;
  final String? status;
  final String statusLabel;
  final Color statusColor;
  final Color statusBg;
  final VoidCallback onTap;

  const _PatientCard({
    required this.initials,
    required this.avatarBg,
    required this.avatarFg,
    required this.fullName,
    required this.ipp,
    required this.iep,
    required this.litCode,
    required this.tbsa,
    required this.severityLevel,
    required this.severityColor,
    required this.status,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBg,
    required this.onTap,
  });

  Color get _tbsaColor {
    if (tbsa < 10) return const Color(0xFF10B981);
    if (tbsa < 30) return const Color(0xFFF59E0B);
    return AppTheme.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: avatarBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: avatarFg,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            fullName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (severityLevel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: severityColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              severityLevel!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: severityColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _infoBadge(colors, Icons.badge_outlined, 'IPP: $ipp'),
                        const SizedBox(width: 12),
                        _infoBadge(colors,
                            Icons.numbers_rounded, 'IEP: $iep'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.local_fire_department_rounded,
                            size: 14, color: _tbsaColor),
                        const SizedBox(width: 4),
                        Text(
                          'TBSA: ${tbsa.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _tbsaColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.bed_outlined,
                            size: 14, color: colors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          litCode,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded,
                            size: 20, color: colors.textSecondary),
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

  Widget _infoBadge(AppColors colors, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: colors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
