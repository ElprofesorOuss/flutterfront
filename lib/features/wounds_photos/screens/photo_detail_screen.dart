import 'dart:convert';

import 'package:burning2026/core/constants/api_constants.dart';
import 'package:burning2026/core/models/wound_photo.dart';
import 'package:burning2026/core/theme/app_colors.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PhotoDetailScreen extends StatefulWidget {
  final String photoId;

  const PhotoDetailScreen({super.key, required this.photoId});

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  WoundPhoto? _photo;
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadPhoto();
  }

  Future<void> _loadPhoto() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final response = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}/photos/${widget.photoId}'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(ApiConstants.timeout);

      if (!mounted) return;

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final data = body['data'];
        if (data is Map<String, dynamic>) {
          _photo = WoundPhoto.fromMap(data);
        }
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

  Color _stageColor(String stage) {
    switch (stage) {
      case 'J0_initial':
        return AppTheme.primaryColor;
      case 'pre_op':
        return const Color(0xFFF59E0B);
      case 'post_graft':
        return const Color(0xFF10B981);
      case 'healing':
        return const Color(0xFF3B82F6);
      case 'scar':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _stageBg(String stage) {
    switch (stage) {
      case 'J0_initial':
        return const Color(0xFFFFEBEE);
      case 'pre_op':
        return const Color(0xFFFFF3E0);
      case 'post_graft':
        return const Color(0xFFE8F5E9);
      case 'healing':
        return const Color(0xFFE3F2FD);
      case 'scar':
        return const Color(0xFFF3E8FF);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Detail photo'),
        actions: [
          IconButton(
            onPressed: _loadPhoto,
            icon: const Icon(Icons.refresh_rounded),
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
                          onPressed: _loadPhoto,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Reessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              : _photo == null
                  ? const Center(child: Text('Photo introuvable.'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: _photo!.imageUrl != null
                                ? Image.network(
                                    _photo!.imageUrl!,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _imagePlaceholder(),
                                    loadingBuilder: (_, child, progress) {
                                      if (progress == null) return child;
                                      return _imagePlaceholder(loading: true);
                                    },
                                  )
                                : _imagePlaceholder(),
                          ),
                          const SizedBox(height: 16),
                          _metaCard(_photo!),
                        ],
                      ),
                    ),
    );
  }

  Widget _imagePlaceholder({bool loading = false}) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: loading
            ? const CircularProgressIndicator()
            : const Icon(Icons.image_outlined,
                size: 64, color: Color(0xFFD1D5DB)),
      ),
    );
  }

  Widget _metaCard(WoundPhoto photo) {
    final colors = context.appColors;
    final stageColor = _stageColor(photo.stage);
    final stageBg = _stageBg(photo.stage);

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
          Text(
            'Informations',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const Divider(height: 24),
          _metaRow('Zone anatomique', photo.bodyPart,
              Icons.sensors_outlined),
          const SizedBox(height: 10),
          _metaRow('Stade', photo.stageLabel,
              Icons.timeline_outlined,
              badge: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: stageBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  photo.stageLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: stageColor,
                  ),
                ),
              )),
          const SizedBox(height: 10),
          _metaRow(
              'Date', photo.takenAtFormatted, Icons.calendar_today_outlined),
          if (photo.notes != null && photo.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _metaRow('Notes', photo.notes!, Icons.note_outlined),
          ],
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value, IconData icon, {Widget? badge}) {
    final colors = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colors.textSecondary),
        const SizedBox(width: 10),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: colors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: badge ?? Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
