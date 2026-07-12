import 'dart:convert';

import 'package:burning2026/app/router/app_router.dart';
import 'package:burning2026/core/constants/api_constants.dart';
import 'package:burning2026/core/theme/app_colors.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:burning2026/shared/widgets/severity_badge.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HospitalisationDetailScreen extends StatefulWidget {
  final String hospitalisationId;

  const HospitalisationDetailScreen({super.key, required this.hospitalisationId});

  @override
  State<HospitalisationDetailScreen> createState() =>
      _HospitalisationDetailScreenState();
}

class _HospitalisationDetailScreenState
    extends State<HospitalisationDetailScreen> {
  Map<String, dynamic>? _item;
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final response = await http
          .get(
            Uri.parse(
              '${ApiConstants.baseUrl}/hospitalisations/${widget.hospitalisationId}',
            ),
            headers: {'Accept': 'application/json'},
          )
          .timeout(ApiConstants.timeout);
      if (!mounted) return;
      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        _item = Map<String, dynamic>.from(body['data'] ?? const {});
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

  String _initials(String? fullName, String? gender) {
    if (fullName == null || fullName.trim().isEmpty) return '?';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName[0].toUpperCase();
  }

  Color _avatarFg(String? gender) {
    return gender == 'femme'
        ? const Color(0xFFC62828)
        : const Color(0xFF1565C0);
  }

  IconData _genderIcon(String? gender) {
    return gender == 'femme' ? Icons.female : Icons.male;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final item = _item;
    final patient = Map<String, dynamic>.from(item?['patient'] ?? const {});
    final lit = Map<String, dynamic>.from(item?['lit'] ?? const {});
    final salle = Map<String, dynamic>.from(lit['salle'] ?? const {});
    final severity = item?['severity'] as Map<String, dynamic>? ?? const {};
    final fullName = patient['full_name'] as String? ?? 'Patient';
    final gender = patient['gender'] as String?;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Hospitalisation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: _loading
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
                                color: colors.textSecondary, fontSize: 16)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Reessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPatientHeader(item, fullName, gender, patient, severity),
                        const SizedBox(height: 16),
                        _buildStatsRow(item),
                        const SizedBox(height: 16),
                        _buildInfoSections(item, patient, lit, salle),
                        const SizedBox(height: 16),
                        _buildActionButtons(),
                        const SizedBox(height: 20),
                        _buildTimeline(item),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildPatientHeader(Map<String, dynamic>? item,
      String fullName, String? gender, Map<String, dynamic> patient, Map<String, dynamic> severity) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      _initials(fullName, gender),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _avatarFg(gender),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(_genderIcon(gender),
                              size: 16, color: Colors.white70),
                          const SizedBox(width: 6),
                          Text(
                            'IPP: ${patient['ipp'] ?? '-'}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SeverityBadge(
                  level: '${severity['severity_level'] ?? 'moderee'}',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _headerStat('IEP', '${item?['visit_number'] ?? '-'}'),
                _headerStat('Statut', '${item?['status'] ?? '-'}'),
                _headerStat(
                  'Inhalation',
                  (item?['inhalation_injury'] == true) ? 'Oui' : 'Non',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Map<String, dynamic>? item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _statCard(
              'TBSA', '${item?['tbsa_percentage'] ?? 0}%', Icons.local_fire_department_rounded,
              const Color(0xFFFFF3E0), const Color(0xFFE65100)),
          _statCard(
              'Jours', '${item?['days_since_burn'] ?? '-'}', Icons.calendar_today_rounded,
              const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
          _statCard(
              'Poids', '${item?['weight_kg'] ?? '-'} kg', Icons.monitor_weight_outlined,
              const Color(0xFFF3E5F5), const Color(0xFF7B1FA2)),
          _statCard(
              'Taille', '${item?['height_cm'] ?? '-'} cm', Icons.straighten_outlined,
              const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color bg, Color iconColor) {
    final colors = context.appColors;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSections(Map<String, dynamic>? item, Map<String, dynamic> patient,
      Map<String, dynamic> lit, Map<String, dynamic> salle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _infoCard(
            title: 'Admission',
            icon: Icons.local_hospital_outlined,
            iconBg: const Color(0xFFFFEBEE),
            iconColor: AppTheme.primaryColor,
            children: [
              _infoRow('IEP', '${item?['visit_number'] ?? '-'}'),
              _infoRow('Date admission', '${item?['admitted_at'] ?? '-'}'.substring(0, 10)),
              _infoRow('Date brulure', '${item?['burn_occurred_at'] ?? '-'}'.substring(0, 10)),
              _infoRow(
                'Lit',
                '${salle['code'] != null ? '[${salle['code']}] ' : ''}${lit['code'] ?? '-'}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoCard(
            title: 'Clinique',
            icon: Icons.medical_information_outlined,
            iconBg: const Color(0xFFE8F5E9),
            iconColor: const Color(0xFF2E7D32),
            children: [
              _infoRow('Statut', '${item?['status'] ?? '-'}'),
              _infoRow('Inhalation', (item?['inhalation_injury'] == true) ? 'Oui' : 'Non'),
              _infoRow('Glasgow', '${item?['glasgow_score'] ?? '-'}'),
              _infoRow('Etat general', '${item?['general_state'] ?? '-'}'),
            ],
          ),
          const SizedBox(height: 12),
          _infoCard(
            title: 'Constantes',
            icon: Icons.monitor_heart_outlined,
            iconBg: const Color(0xFFFFF3E0),
            iconColor: const Color(0xFFE65100),
            children: [
              _infoRow('TA', '${item?['systolic_bp'] ?? '-'}/${item?['diastolic_bp'] ?? '-'}'),
              _infoRow('FC (/min)', '${item?['heart_rate'] ?? '-'}'),
              _infoRow('FR (/min)', '${item?['resp_rate'] ?? '-'}'),
              _infoRow('Temperature', '${item?['temperature'] ?? '-'}'),
              _infoRow('SpO2 (%)', '${item?['spo2'] ?? '-'}'),
              _infoRow('EVA', '${item?['pain_eva'] ?? '-'}/10'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required List<Widget> children,
  }) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 18),
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
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 13,
                color: colors.textSecondary,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 90,
        child: Row(
          children: [
            Expanded(
              child: _actionCard(
                icon: Icons.assignment_outlined,
                label: 'Evaluation\ninitiale',
                color: AppTheme.primaryColor,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.initialAssessment,
                    arguments: {'admissionId': widget.hospitalisationId},
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _actionCard(
                icon: Icons.air_outlined,
                label: 'Evaluation\nrespiratoire',
                color: const Color(0xFF0EA5E9),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.respiratoryEvaluation,
                    arguments: {'admissionId': widget.hospitalisationId},
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _actionCard(
                icon: Icons.healing_outlined,
                label: 'Photos\ninitiales',
                color: const Color(0xFFF59E0B),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.photoGallery,
                    arguments: {'admissionId': widget.hospitalisationId},
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _actionCard(
                icon: Icons.note_add_outlined,
                label: 'Observations',
                color: const Color(0xFFEC4899),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.observations,
                    arguments: {'hospitalisationId': widget.hospitalisationId},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(Map<String, dynamic>? item) {
    final colors = context.appColors;
    final steps = [
      _StepData('Admission', '${item?['admitted_at'] ?? '-'}'.substring(0, 10),
          Icons.local_hospital, const Color(0xFFE11D48), true),
      _StepData('Reanimation', 'J0', Icons.bloodtype_outlined, const Color(0xFF0EA5E9), true),
      _StepData('Pansement initial', 'J+1', Icons.healing_outlined, const Color(0xFFF59E0B), true),
      _StepData('Bloc operatoire', 'J+5', Icons.biotech_outlined, const Color(0xFF8B5CF6), false),
      _StepData('Greffe', 'Prevue J+14', Icons.science_outlined, const Color(0xFF10B981), false),
      _StepData('Reeducation', 'A planifier', Icons.accessibility_new_outlined, const Color(0xFF6B7280), false),
      _StepData('Sortie', 'Prevue J+30', Icons.home_outlined, const Color(0xFF6B7280), false, isLast: true),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.timeline_rounded,
                        color: Color(0xFF8B5CF6), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Parcours de soins',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            ...List.generate(steps.length, (i) {
              final step = steps[i];
              final isLast = i == steps.length - 1;
              return _timelineStep(
                step.title,
                step.date,
                step.icon,
                step.color,
                step.active,
                isLast: isLast,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _timelineStep(String title, String date, IconData icon, Color color,
      bool active, {bool isLast = false}) {
    final colors = context.appColors;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: active ? color : color.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 14),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: active
                          ? color.withValues(alpha: 0.3)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: active
                          ? colors.textPrimary
                          : colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color: active ? color : colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepData {
  final String title;
  final String date;
  final IconData icon;
  final Color color;
  final bool active;

  const _StepData(this.title, this.date, this.icon, this.color, this.active,
      {this.isLast = false});

  final bool isLast;
}
