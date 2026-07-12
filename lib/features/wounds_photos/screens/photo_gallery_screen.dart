import 'dart:convert';

import 'package:burning2026/app/router/app_router.dart';
import 'package:burning2026/core/constants/api_constants.dart';
import 'package:burning2026/core/models/wound_photo.dart';
import 'package:burning2026/core/theme/app_colors.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PhotoGalleryScreen extends StatefulWidget {
  final String admissionId;

  const PhotoGalleryScreen({super.key, required this.admissionId});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  List<WoundPhoto> _photos = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final response = await http
          .get(
            Uri.parse(
                '${ApiConstants.baseUrl}/hospitalisations/${widget.admissionId}/photos'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(ApiConstants.timeout);

      if (!mounted) return;

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final data = body['data'];
        if (data is List) {
          _photos = data
              .whereType<Map>()
              .map((e) => WoundPhoto.fromMap(Map<String, dynamic>.from(e)))
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
        title: const Text('Photos des plaies'),
        actions: [
          IconButton(
            onPressed: _loadPhotos,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.pushNamed(
            context,
            AppRoutes.photoAdd,
            arguments: {'admissionId': widget.admissionId},
          );
          if (added == true) {
            _loadPhotos();
          }
        },
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_a_photo_rounded),
        label: const Text('Ajouter'),
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
                          onPressed: _loadPhotos,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Reessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              : _photos.isEmpty
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
                                Icons.image_outlined,
                                size: 40,
                                color: colors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune photo',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Aucune photo de plaie pour cette hospitalisation.\nAjoutez-en une avec le bouton +.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPhotos,
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: _photos.length,
                        itemBuilder: (context, index) {
                          final photo = _photos[index];
                          return _PhotoCard(
                            photo: photo,
                            stageColor: _stageColor(photo.stage),
                            stageBg: _stageBg(photo.stage),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.photoDetail,
                                arguments: {
                                  'photoId': '${photo.id}',
                                  'admissionId': widget.admissionId,
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final WoundPhoto photo;
  final Color stageColor;
  final Color stageBg;
  final VoidCallback onTap;

  const _PhotoCard({
    required this.photo,
    required this.stageColor,
    required this.stageBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(18),
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
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                  child: photo.imageUrl != null
                      ? Image.network(
                          photo.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => _imagePlaceholder(colors),
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return _imagePlaceholder(colors,
                                loading: true);
                          },
                        )
                      : _imagePlaceholder(colors),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            photo.bodyPart,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: stageBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            photo.stageLabel,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: stageColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (photo.takenAt != null)
                          Text(
                            photo.takenAtFormatted,
                            style: TextStyle(
                              fontSize: 10,
                              color: colors.textSecondary,
                            ),
                          ),
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

  Widget _imagePlaceholder(AppColors colors, {bool loading = false}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: colors.card,
      child: Center(
        child: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.image_outlined,
                size: 40, color: Color(0xFFD1D5DB)),
      ),
    );
  }
}
