import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:burning2026/core/constants/api_constants.dart';
import 'package:burning2026/core/models/trajectory_step.dart';
import 'package:burning2026/core/theme/app_colors.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:burning2026/shared/widgets/timeline_item.dart';

const _monthNames = [
  '', 'Janvier', 'Fevrier', 'Mars', 'Avril', 'Mai', 'Juin',
  'Juillet', 'Aout', 'Septembre', 'Octobre', 'Novembre', 'Decembre'
];

class TrajectoryScreen extends StatefulWidget {
  final String patientId;

  const TrajectoryScreen({super.key, required this.patientId});

  @override
  State<TrajectoryScreen> createState() => _TrajectoryScreenState();
}

class _TrajectoryScreenState extends State<TrajectoryScreen> {
  TrajectoryResponse? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTrajectory();
  }

  Future<void> _fetchTrajectory() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/patients/${widget.patientId}/trajectory');
      final response = await http.get(uri).timeout(ApiConstants.timeout);

      if (response.statusCode != 200) {
        throw Exception('Erreur serveur ${response.statusCode}');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        throw Exception(body['message'] as String? ?? 'Erreur inconnue');
      }

      setState(() {
        _data = TrajectoryResponse.fromMap(body['data'] as Map<String, dynamic>);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Color _severityColor() {
    final tbsa = _data?.admissionSummary?.tbsaPercentage ?? 0;
    if (tbsa >= 40) return const Color(0xFFE53935);
    if (tbsa >= 20) return const Color(0xFFFF6D00);
    if (tbsa >= 10) return const Color(0xFFFDD835);
    return const Color(0xFF43A047);
  }

  IconData _iconForType(String iconName) {
    switch (iconName) {
      case 'local_hospital': return Icons.local_hospital;
      case 'bloodtype': return Icons.bloodtype;
      case 'healing': return Icons.healing;
      case 'biotech': return Icons.biotech;
      case 'science': return Icons.science;
      case 'accessibility_new': return Icons.accessibility_new;
      case 'home': return Icons.home;
      case 'warning': return Icons.warning_amber;
      case 'monitor_heart': return Icons.monitor_heart_outlined;
      case 'air': return Icons.air;
      case 'injection': return Icons.vaccines_outlined;
      case 'psychology': return Icons.psychology_outlined;
      case 'diet': return Icons.restaurant_outlined;
      case 'surgical': return Icons.biotech_outlined;
      case 'follow_up': return Icons.timeline_outlined;
      default: return Icons.circle_outlined;
    }
  }

  Color _parseColor(String hex) {
    final c = hex.replaceFirst('#', '');
    return Color(int.parse('FF$c', radix: 16));
  }

  String _monthKey(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      return '${_monthNames[d.month]} ${d.year}';
    } catch (_) {
      return dateStr;
    }
  }

  bool _sameMonth(String a, String b) {
    try {
      final da = DateTime.parse(a);
      final db = DateTime.parse(b);
      return da.year == db.year && da.month == db.month;
    } catch (_) {
      return false;
    }
  }

  Widget _buildHeader() {
    final patient = _data!.patient;
    final summary = _data!.admissionSummary;
    final color = _severityColor();

    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withValues(alpha: 0.6)],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (patient != null)
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white70, size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${patient.lastName} ${patient.firstName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (patient.age != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${patient.age} ans',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 8),
              if (summary != null)
                Row(
                  children: [
                    _infoChip(Icons.local_fire_department, 'TBSA ${summary.tbsaPercentage.toStringAsFixed(0)}%'),
                    const SizedBox(width: 8),
                    if (summary.highestDegreeLabel != null)
                      _infoChip(Icons.whatshot, summary.highestDegreeLabel!),
                    if (summary.burnCause != null) ...[
                      const SizedBox(width: 8),
                      Flexible(child: _infoChip(Icons.category, summary.burnCause!)),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final s = _data!.summary;

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 100,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            _statCard('Total', '${s.totalSteps}', Icons.timeline, AppTheme.primaryColor),
            _statCard('Réalisées', '${s.completed}', Icons.check_circle, const Color(0xFF43A047)),
            _statCard('Planifiées', '${s.planned}', Icons.schedule, const Color(0xFFFF6D00)),
            if (s.complications > 0)
              _statCard('Complications', '${s.complications}', Icons.warning, const Color(0xFFE53935)),
            if (s.totalDurationDays != null)
              _statCard('Durée', '${s.totalDurationDays}j', Icons.date_range, const Color(0xFF5C6BC0)),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: context.appColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appColors.textLight.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.appColors.textPrimary)),
          Text(label, style: TextStyle(fontSize: 11, color: context.appColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildCurrentStepCard() {
    final current = _data!.summary.currentStep;
    if (current == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.15),
              AppTheme.primaryColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconForType(current.stepTypeIcon),
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Étape en cours',
                          style: TextStyle(fontSize: 11, color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: _parseColor(current.statusColor).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(current.statusLabel,
                            style: TextStyle(fontSize: 10, color: _parseColor(current.statusColor))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(current.title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  if (current.summary != null)
                    Text(current.summary!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    final steps = _data!.steps;
    if (steps.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timeline, size: 48, color: context.appColors.textLight.withValues(alpha: 0.4)),
              const SizedBox(height: 12),
              Text('Aucune étape de trajectoire',
                  style: TextStyle(color: context.appColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final step = steps[index];
          final currMonth = _monthKey(step.stepDate ?? '');
          final showMonth = index == 0 || !_sameMonth(steps[index - 1].stepDate ?? '', step.stepDate ?? '');

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showMonth)
                Padding(
                  padding: EdgeInsets.fromLTRB(16, index == 0 ? 0 : 12, 16, 4),
                  child: Text(
                    currMonth,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.appColors.textPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              if (step.complicationFlag)
                _complicationBanner(step),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TimelineItem(
                  title: step.title,
                  subtitle: step.summary,
                  date: step.stepDateShort,
                  icon: _iconForType(step.stepTypeIcon),
                  isActive: step.isCurrent,
                  isFirst: index == 0,
                  isLast: index == steps.length - 1,
                ),
              ),
            ],
          );
        },
        childCount: steps.length,
      ),
    );
  }

  Widget _complicationBanner(TrajectoryStep step) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE53935).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFE53935)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              step.complicationType ?? 'Complication',
              style: const TextStyle(fontSize: 11, color: Color(0xFFE53935), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _severityColor()),
            const SizedBox(height: 16),
            Text('Chargement de la trajectoire...',
                style: TextStyle(color: context.appColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 48, color: context.appColors.textLight.withValues(alpha: 0.4)),
              const SizedBox(height: 12),
              Text('Impossible de charger la trajectoire',
                  style: TextStyle(color: context.appColors.textSecondary)),
              const SizedBox(height: 4),
              Text(_error ?? '', style: TextStyle(fontSize: 12, color: context.appColors.textLight)),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _fetchTrajectory,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        onRefresh: _fetchTrajectory,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildHeader(),
            if (_loading)
              _buildLoading()
            else if (_error != null)
              _buildError()
            else ...[
              _buildSummaryCards(),
              _buildCurrentStepCard(),
              _buildTimeline(),
            ],
          ],
        ),
      ),
    );
  }
}
