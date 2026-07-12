import 'package:flutter/material.dart';
import 'package:burning2026/app/app.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:burning2026/core/theme/app_colors.dart';
import 'package:burning2026/core/theme/theme_controller.dart';
import 'package:burning2026/app/router/app_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = BurnCenterApp.themeControllerOf(context);
    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: CustomScrollView(
        slivers: [
          _ProfileHeaderSliver(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: _CompletionCard(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: const _SectionLabel(label: 'Compte'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _MenuCard(items: [
                _MenuItem(icon: Icons.person_outline, label: 'Mon profil', trailing: 'Medecin chef'),
                _MenuItem(icon: Icons.shield_outlined, label: 'Securite', trailing: '••••••'),
                _MenuItem(icon: Icons.notifications_outlined, label: 'Notifications'),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: const _SectionLabel(label: 'Preferences'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _MenuCard(items: [
                _MenuItem(icon: Icons.palette_outlined, label: 'Theme', trailing: 'Clair'),
                _MenuItem(icon: Icons.language_outlined, label: 'Langue', trailing: 'Francais'),
                _MenuItem(icon: Icons.settings_outlined, label: 'Parametres avances'),
              ],
              onTapItem: (item) async {
                if (item.label == 'Theme') {
                  await _showThemePicker(context, themeController);
                }
              }),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: const _SectionLabel(label: 'Support'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _MenuCard(items: [
                _MenuItem(icon: Icons.help_outline, label: 'Aide et tutoriels'),
                _MenuItem(icon: Icons.info_outline, label: 'A propos', trailing: 'v2.1.0'),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: context.appColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: AppTheme.primaryColor, size: 20),
                        const SizedBox(width: 10),
                        const Text('Deconnexion', style: TextStyle(color: AppTheme.primaryColor, fontSize: 15, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showThemePicker(
    BuildContext context,
    ThemeController themeController,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.appColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final current = themeController.themeMode;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choisir le theme',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _themeOption(
                  context,
                  label: 'Systeme',
                  icon: Icons.phone_android_rounded,
                  selected: current == ThemeMode.system,
                  onTap: () async {
                    await themeController.setThemeMode(ThemeMode.system);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                _themeOption(
                  context,
                  label: 'Clair',
                  icon: Icons.light_mode_outlined,
                  selected: current == ThemeMode.light,
                  onTap: () async {
                    await themeController.setThemeMode(ThemeMode.light);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                _themeOption(
                  context,
                  label: 'Sombre',
                  icon: Icons.dark_mode_outlined,
                  selected: current == ThemeMode.dark,
                  onTap: () async {
                    await themeController.setThemeMode(ThemeMode.dark);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _themeOption(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        label,
        style: TextStyle(color: context.appColors.textPrimary),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle, color: AppTheme.primaryColor)
          : null,
      onTap: onTap,
    );
  }
}

class _ProfileHeaderSliver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 260,
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
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white24,
                      child: Text('DM', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Dr. Sarah Martin', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Medecin chef - Centre des Brules', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                  const SizedBox(height: 3),
                  Text('sarah.martin@burn.center', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        _ProfileStat(label: 'Patients', value: '186'),
                        _ProfileStat(label: 'Experience', value: '12 ans'),
                        _ProfileStat(label: 'Equipe', value: '14'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 1),
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profil complete', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: 0.75,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFF3F4F6),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                  ),
                ),
                const SizedBox(height: 4),
                Text('75% - Ajoutez votre photo et signature', style: TextStyle(fontSize: 11, color: colors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.task_alt_rounded, color: Color(0xFF10B981), size: 24),
          ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary)),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? trailing;
  const _MenuItem({required this.icon, required this.label, this.trailing});
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  final void Function(_MenuItem item)? onTapItem;
  const _MenuCard({required this.items, this.onTapItem});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: isLast
                      ? const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))
                      : BorderRadius.zero,
                  onTap: () => onTapItem?.call(item),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(item.icon, color: AppTheme.primaryColor, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(item.label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                        ),
                        if (item.trailing != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(item.trailing!, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                          ),
                        Icon(Icons.chevron_right_rounded, size: 20, color: colors.textLight),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isLast) Padding(
                padding: const EdgeInsets.only(left: 68, right: 16),
                child: Divider(height: 1, color: Colors.grey.withValues(alpha: 0.12)),
              ),
            ],
          );
        }),
      ),
    );
  }
}
