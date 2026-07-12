import 'package:flutter/material.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:burning2026/core/theme/app_colors.dart';
import 'package:burning2026/app/router/app_router.dart';
import 'package:burning2026/shared/widgets/severity_badge.dart';
import 'package:burning2026/mock/data/mock_patients.dart';

class PatientDetailScreen extends StatelessWidget {
  final String patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final patient = MockPatients.list.firstWhere(
      (p) => p['id'] == patientId,
      orElse: () {
        final idx = int.tryParse(patientId);
        if (idx != null && idx > 0 && idx <= MockPatients.list.length) {
          return MockPatients.list[idx - 1];
        }
        return MockPatients.list.first;
      },
    );
    final nom = patient['nom']! as String;
    final prenom = patient['prenom']! as String;
    final severite = patient['severite']! as String;
    final mecanisme = patient['mecanisme']! as String;
    final profondeur = patient['profondeur']! as String;
    final inhalation = patient['inhalation'] as bool;

    return Scaffold(
      backgroundColor: colors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 240,
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
                      children: [
                        const Spacer(flex: 2),
                        Row(
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                              ),
                              child: Center(
                                child: Text('$nom[0]$prenom[0]', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$nom $prenom, ${patient['age']} ans', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                                        child: Text('IPP: ${patient['ipp']}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                                        child: Text('Lit: ${patient['lit']}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SeverityBadge(level: severite, fontSize: 12),
                          ],
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              _HeaderInfo(value: '${patient['tbsa']}%', label: 'TBSA'),
                              const SizedBox(width: 12),
                              _HeaderInfo(value: mecanisme, label: 'Mecanisme'),
                              const SizedBox(width: 12),
                              _HeaderInfo(value: profondeur, label: 'Profondeur'),
                              const SizedBox(width: 12),
                              _HeaderInfo(value: inhalation ? 'Oui' : 'Non', label: 'Inhalation'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text('Modules patient', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _ModuleCard(icon: Icons.camera_alt_outlined, label: 'Photos', color: const Color(0xFF3B82F6), onTap: () => Navigator.pushNamed(context, AppRoutes.photoGallery, arguments: {'admissionId': '1'}))),
                  const SizedBox(width: 10),
                  Expanded(child: _ModuleCard(icon: Icons.timeline_outlined, label: 'Trajectoire', color: const Color(0xFF8B5CF6), onTap: () => Navigator.pushNamed(context, AppRoutes.trajectory, arguments: {'patientId': patientId}))),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _ModuleCard(icon: Icons.restaurant_outlined, label: 'Nutrition', color: const Color(0xFF10B981), onTap: () => Navigator.pushNamed(context, AppRoutes.nutrition, arguments: {'admissionId': '1'}))),
                  const SizedBox(width: 10),
                  Expanded(child: _ModuleCard(icon: Icons.description_outlined, label: 'Observations', color: const Color(0xFFEC4899), onTap: () => Navigator.pushNamed(context, AppRoutes.observations, arguments: {'hospitalisationId': '1'}))),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _ModuleCard(icon: Icons.local_hospital_outlined, label: 'Hospitalisations', color: AppTheme.primaryColor, onTap: () => Navigator.pushNamed(context, AppRoutes.hospitalisationList))),
                  const SizedBox(width: 10),
                  Expanded(child: _ModuleCard(icon: Icons.assignment_outlined, label: 'Anamnese', color: const Color(0xFF6366F1), onTap: () => Navigator.pushNamed(context, AppRoutes.anamnesis, arguments: {'admissionId': '1'}))),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ModuleCard(
                icon: Icons.analytics_rounded,
                label: 'Classification',
                color: const Color(0xFF0EA5E9),
                onTap: () => Navigator.pushNamed(context, AppRoutes.classification, arguments: {'admissionId': '1'}),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Photos recentes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.photoGallery, arguments: {'admissionId': '1'}),
                    child: const Text('Voir tout', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _PhotoThumb(label: 'Admission', date: 'J0', color: const Color(0xFF3B82F6), onTap: () => Navigator.pushNamed(context, AppRoutes.photoDetail, arguments: {'photoId': '1'})),
                  const SizedBox(width: 10),
                  _PhotoThumb(label: 'J+3', date: '03/07', color: AppTheme.successColor, onTap: () => Navigator.pushNamed(context, AppRoutes.photoDetail, arguments: {'photoId': '3'})),
                  const SizedBox(width: 10),
                  _PhotoThumb(label: 'J+7', date: '07/07', color: const Color(0xFF8B5CF6), onTap: () => Navigator.pushNamed(context, AppRoutes.photoDetail, arguments: {'photoId': '7'})),
                  const SizedBox(width: 10),
                  _PhotoThumb(label: 'J+10', date: '10/07', color: const Color(0xFFF59E0B), onTap: () => Navigator.pushNamed(context, AppRoutes.photoDetail, arguments: {'photoId': '10'})),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Alertes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary)),
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
              child: _AlertItem(
                icon: Icons.warning_amber_rounded,
                title: 'Score ABSI eleve',
                subtitle: 'Patient $nom - Score ${patient['tbsa']}',
                color: AppTheme.primaryColor,
                onTap: () => Navigator.pushNamed(context, AppRoutes.alerts),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _HeaderInfo extends StatelessWidget {
  final String value;
  final String label;
  const _HeaderInfo({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ModuleCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary))),
              Icon(Icons.chevron_right_rounded, size: 18, color: colors.textLight),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  final String label;
  final String date;
  final Color color;
  final VoidCallback onTap;
  const _PhotoThumb({required this.label, required this.date, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 88,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.appColors.card,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.image_outlined, color: color, size: 22),
              ),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.appColors.textPrimary)),
              Text(date, style: TextStyle(fontSize: 9, color: context.appColors.textLight)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _AlertItem({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
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
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 22),
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
              Icon(Icons.chevron_right_rounded, size: 20, color: colors.textLight),
            ],
          ),
        ),
      ),
    );
  }
}
