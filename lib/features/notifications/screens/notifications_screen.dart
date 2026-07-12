import 'package:burning2026/core/constants/severity_colors.dart';
import 'package:burning2026/core/models/app_notification.dart';
import 'package:burning2026/core/theme/app_colors.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:burning2026/mock/repositories/notification_repository_impl.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _repository = FakeNotificationRepository();
  List<AppNotification> _notifications = [];
  bool _loading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await _repository.getAll();
    if (!mounted) return;
    setState(() {
      _notifications = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final visible = _filter == 'all'
        ? _notifications
        : _notifications.where((n) => n.type == _filter).toList();

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('Toutes', 'all'),
                  const SizedBox(width: 8),
                  _filterChip('Alertes critiques', 'critical_alert'),
                  const SizedBox(width: 8),
                  _filterChip('Nouvelles photos', 'new_photo'),
                  const SizedBox(width: 8),
                  _filterChip('Obs. critiques', 'critical_observation'),
                  const SizedBox(width: 8),
                  _filterChip('Patients a revoir', 'patient_review'),
                ],
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: visible.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final n = visible[i];
                      final config = _configFor(n, colors);

                      return Card(
                        margin: EdgeInsets.zero,
                        color: colors.card,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border(
                              left: BorderSide(color: config.color, width: 4),
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  config.color.withValues(alpha: 0.12),
                              child: Icon(
                                config.icon,
                                color: config.color,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              n.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  n.patientName.isNotEmpty
                                      ? '${n.patientName}${n.location != null ? ' • ${n.location}' : ''}'
                                      : (n.location ?? ''),
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: config.color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  n.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule_rounded,
                                      size: 12,
                                      color: colors.textLight,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      n.time,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: colors.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = value),
    );
  }

  _NotificationUiConfig _configFor(AppNotification n, AppColors colors) {
    switch (n.type) {
      case 'critical_alert':
        return const _NotificationUiConfig(
          icon: Icons.warning_amber_rounded,
          color: SeverityColors.critical,
        );
      case 'new_photo':
        return const _NotificationUiConfig(
          icon: Icons.camera_alt_outlined,
          color: AppTheme.primaryColor,
        );
      case 'critical_observation':
        return const _NotificationUiConfig(
          icon: Icons.assignment_late_outlined,
          color: Color(0xFF7C3AED),
        );
      case 'patient_review':
        return const _NotificationUiConfig(
          icon: Icons.visibility_outlined,
          color: Color(0xFFF59E0B),
        );
      default:
        return _NotificationUiConfig(
          icon: Icons.notifications_outlined,
          color: colors.textSecondary,
        );
    }
  }
}

class _NotificationUiConfig {
  final IconData icon;
  final Color color;

  const _NotificationUiConfig({
    required this.icon,
    required this.color,
  });
}
