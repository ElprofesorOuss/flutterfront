import 'package:flutter/material.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:burning2026/core/theme/app_colors.dart';
import 'package:burning2026/app/router/app_router.dart';
import 'package:burning2026/mock/data/mock_patients.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patients = MockPatients.list;
    final criticalCount = patients.where((p) => p['severite'] == 'critique').length;
    final severeCount = patients.where((p) => p['severite'] == 'sévère').length;

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: CustomScrollView(
        slivers: [
          _HeaderSliver(severeCount: severeCount, criticalCount: criticalCount),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: _MetricsRow(activeCount: patients.length, criticalCount: criticalCount, todayCount: patients.where((p) => p['date_admission'] == '2026-07-05').length),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: _SectionLabel(label: 'Acces rapide'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
              child: _QuickActionsGrid(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: const _AdmissionPromptCard(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionLabel(label: 'Alertes critiques'),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.alerts),
                    child: const Text('Voir tout', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _AlertTile(
                    title: 'Defaillance renale suspectee',
                    subtitle: 'Patient Bernard Jean - B-201 - TBSA 45%',
                    severity: 'critique',
                    time: 'Il y a 12 min',
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  _AlertTile(
                    title: 'Hypotension severe',
                    subtitle: 'Patient Dubois Pierre - A-101 - TBSA 32%',
                    severity: 'critique',
                    time: 'Il y a 35 min',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionLabel(label: 'Patients a surveiller'),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.patientList),
                    child: const Text('Voir tout', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final p = patients.where((p) => p['severite'] == 'sévère' || p['severite'] == 'critique').toList()[index];
                return Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 12, top: index == 0 ? 0 : 0),
                  child: _DashboardPatientCard(
                    nom: p['nom']!,
                    prenom: p['prenom']!,
                    age: p['age'] as int,
                    ipp: p['ipp']!,
                    lit: p['lit']!,
                    tbsa: p['tbsa'] as int,
                    severite: p['severite']!,
                    statut: p['statut']!,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.patientDetail, arguments: {'patientId': p['id']}),
                  ),
                );
              },
              childCount: patients.where((p) => p['severite'] == 'sévère' || p['severite'] == 'critique').length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _HeaderSliver extends StatelessWidget {
  final int severeCount;
  final int criticalCount;
  const _HeaderSliver({required this.severeCount, required this.criticalCount});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
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
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Bonjour,', style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w500)),
                            const Text('Dr. Martin', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _IconBtn(Icons.notifications_outlined, () => Navigator.pushNamed(context, AppRoutes.notifications), severityCount: 3),
                            const SizedBox(width: 4),
                            _IconBtn(Icons.person_outline, () => Navigator.pushNamed(context, AppRoutes.profile)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _HeaderStat(label: 'Patients', value: '${severeCount + criticalCount}', icon: Icons.people_outline),
                      const SizedBox(width: 16),
                      _HeaderStat(label: 'Severes', value: '$severeCount', icon: Icons.warning_amber_rounded),
                      const SizedBox(width: 16),
                      _HeaderStat(label: 'Critiques', value: '$criticalCount', icon: Icons.error_outline),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int? severityCount;
  const _IconBtn(this.icon, this.onTap, {this.severityCount});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(icon: Icon(icon, color: Colors.white70), onPressed: onTap),
        if (severityCount != null && severityCount! > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle),
              child: Center(child: Text('$severityCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))),
            ),
          ),
      ],
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _HeaderStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, height: 1.1)),
                Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  final int activeCount;
  final int criticalCount;
  final int todayCount;
  const _MetricsRow({required this.activeCount, required this.criticalCount, required this.todayCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _MetricCard(label: 'Hospitalises', value: '$activeCount', icon: Icons.bed_outlined, color: const Color(0xFF3B82F6))),
        const SizedBox(width: 10),
        Expanded(child: _MetricCard(label: 'Critiques', value: '$criticalCount', icon: Icons.warning_amber_rounded, color: AppTheme.primaryColor)),
        const SizedBox(width: 10),
        Expanded(child: _MetricCard(label: "Aujourd'hui", value: '$todayCount', icon: Icons.trending_up, color: const Color(0xFF10B981))),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _MetricCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color, height: 1)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 13, color: colors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary));
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final actions = [
      _ActionItem(icon: Icons.people_outline, label: 'Patients', color: const Color(0xFF3B82F6), route: AppRoutes.patientList),
      _ActionItem(icon: Icons.local_hospital_outlined, label: 'Hospitalisations', color: AppTheme.primaryColor, route: AppRoutes.hospitalisationList),
      _ActionItem(icon: Icons.warning_amber_rounded, label: 'Alertes', color: const Color(0xFFF59E0B), route: AppRoutes.alerts),
      _ActionItem(icon: Icons.timeline_outlined, label: 'Trajectoire', color: const Color(0xFF8B5CF6), route: AppRoutes.trajectory, args: {'patientId': 'P001'}),
      _ActionItem(icon: Icons.restaurant_outlined, label: 'Nutrition', color: const Color(0xFF10B981), route: AppRoutes.nutrition, args: {'admissionId': '1'}),
      _ActionItem(icon: Icons.description_outlined, label: 'Observations', color: const Color(0xFFEC4899), route: AppRoutes.observations, args: {'patientId': 'P001'}),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final a = actions[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              if (a.args != null) {
                Navigator.pushNamed(context, a.route, arguments: a.args);
              } else {
                Navigator.pushNamed(context, a.route);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: a.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(a.icon, color: a.color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      a.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  final Map<String, dynamic>? args;
  const _ActionItem({required this.icon, required this.label, required this.color, required this.route, this.args});
}

class _AdmissionPromptCard extends StatelessWidget {
  const _AdmissionPromptCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.pushNamed(context, AppRoutes.hospitalisationCreate),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFBE123C)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.add_home_work_outlined, color: Colors.white),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Creer une hospitalisation', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    SizedBox(height: 3),
                    Text('Associer patient, lit et donnees initiales.', style: TextStyle(color: Colors.white70, fontSize: 12.5)),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String severity;
  final String time;
  final VoidCallback onTap;
  const _AlertTile({required this.title, required this.subtitle, required this.severity, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isCritical = severity == 'critique';
    final color = isCritical ? AppTheme.primaryColor : const Color(0xFFF59E0B);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(isCritical ? Icons.error_outline : Icons.warning_amber_rounded, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(time, style: TextStyle(fontSize: 10, color: colors.textSecondary, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardPatientCard extends StatelessWidget {
  final String nom;
  final String prenom;
  final int age;
  final String ipp;
  final String lit;
  final int tbsa;
  final String severite;
  final String statut;
  final VoidCallback? onTap;

  const _DashboardPatientCard({
    required this.nom,
    required this.prenom,
    required this.age,
    required this.ipp,
    required this.lit,
    required this.tbsa,
    required this.severite,
    required this.statut,
    this.onTap,
  });

  Color get _severityColor {
    switch (severite) {
      case 'critique': return const Color(0xFFDC2626);
      case 'sévère': return const Color(0xFFEA580C);
      case 'modérée': return const Color(0xFFF59E0B);
      case 'faible': return const Color(0xFF10B981);
      default: return const Color(0xFF6B7280);
    }
  }

  Color get _tbsaColor {
    if (tbsa < 10) return const Color(0xFF10B981);
    if (tbsa < 30) return const Color(0xFFF59E0B);
    return AppTheme.primaryColor;
  }

  String get _statusLabel {
    switch (statut) {
      case 'hospitalisé': return 'Hospitalise';
      case 'urgences': return 'Urgences';
      case 'sortie': return 'Sortie';
      default: return statut;
    }
  }

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
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: const [Color(0xFFE11D48), Color(0xFFBE123C)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '${nom[0]}${prenom[0]}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
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
                          child: Text('$nom $prenom, $age ans', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary), overflow: TextOverflow.ellipsis),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: _severityColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                          child: Text(severite.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _severityColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.badge_outlined, size: 12, color: colors.textSecondary),
                        const SizedBox(width: 3),
                        Text(ipp, style: TextStyle(fontSize: 11, color: colors.textSecondary)),
                        const SizedBox(width: 14),
                        Icon(Icons.bed_outlined, size: 12, color: colors.textSecondary),
                        const SizedBox(width: 3),
                        Text(lit, style: TextStyle(fontSize: 11, color: colors.textSecondary)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: _tbsaColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text('TBSA $tbsa%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _tbsaColor)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(_statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: colors.textSecondary)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, size: 20, color: colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
