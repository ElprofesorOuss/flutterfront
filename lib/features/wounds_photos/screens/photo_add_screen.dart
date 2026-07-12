import 'dart:convert';
import 'dart:io';

import 'package:burning2026/core/constants/api_constants.dart';
import 'package:burning2026/core/theme/app_colors.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class PhotoAddScreen extends StatefulWidget {
  final String admissionId;

  const PhotoAddScreen({super.key, required this.admissionId});

  @override
  State<PhotoAddScreen> createState() => _PhotoAddScreenState();
}

class _PhotoAddScreenState extends State<PhotoAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  File? _imageFile;
  String? _imageSource;
  bool _submitting = false;

  String _bodyPart = '';
  String _stage = 'J0_initial';
  String _takenAt = '';

  final List<Map<String, String>> _bodyPartOptions = [
    {'label': 'Visage', 'value': 'Visage'},
    {'label': 'Cou', 'value': 'Cou'},
    {'label': 'Tronc anterieur', 'value': 'Tronc anterieur'},
    {'label': 'Tronc posterieur', 'value': 'Tronc posterieur'},
    {'label': 'Membre superieur droit', 'value': 'Membre superieur droit'},
    {'label': 'Membre superieur gauche', 'value': 'Membre superieur gauche'},
    {'label': 'Main droite', 'value': 'Main droite'},
    {'label': 'Main gauche', 'value': 'Main gauche'},
    {'label': 'Membre inferieur droit', 'value': 'Membre inferieur droit'},
    {'label': 'Membre inferieur gauche', 'value': 'Membre inferieur gauche'},
    {'label': 'Pied droit', 'value': 'Pied droit'},
    {'label': 'Pied gauche', 'value': 'Pied gauche'},
    {'label': 'Perinee', 'value': 'Perinee'},
    {'label': 'Siege', 'value': 'Siege'},
    {'label': 'Autre', 'value': 'Autre'},
  ];

  final List<Map<String, String>> _stageOptions = [
    {'label': 'J0 Initial', 'value': 'J0_initial'},
    {'label': 'Pre-operatoire', 'value': 'pre_op'},
    {'label': 'Post-greffe', 'value': 'post_graft'},
    {'label': 'Cicatrisation', 'value': 'healing'},
    {'label': 'Cicatrice', 'value': 'scar'},
  ];

  @override
  void initState() {
    super.initState();
    _takenAt = DateTime.now().toIso8601String().substring(0, 16);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _imageSource = source == ImageSource.camera ? 'Camera' : 'Galerie';
      });
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ajouter une photo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _pickerOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Appareil photo',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _pickerOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Galerie',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez selectionner une image.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '${ApiConstants.baseUrl}/hospitalisations/${widget.admissionId}/photos'),
      );

      request.headers['Accept'] = 'application/json';
      request.fields['body_part'] = _bodyPart;
      request.fields['stage'] = _stage;
      request.fields['taken_at'] = _takenAt;
      if (_notesController.text.trim().isNotEmpty) {
        request.fields['notes'] = _notesController.text.trim();
      }
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _imageFile!.path,
      ));

      final streamed = await request.send().timeout(ApiConstants.timeout);
      final response = await http.Response.fromStream(streamed);

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo ajoutee avec succes.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
        return;
      }

      String message = 'Erreur lors de l\'ajout.';
      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          message = body['message']?.toString() ?? message;
          final errors = body['errors'];
          if (errors is Map && errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              message = firstError.first.toString();
            }
          }
        }
      } catch (_) {}

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connexion au serveur impossible.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Ajouter une photo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionCard(
                title: 'Photo',
                icon: Icons.image_outlined,
                child: GestureDetector(
                  onTap: _showImagePicker,
                  child: Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      color: _imageFile != null
                          ? null
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.add_a_photo_rounded,
                                  color: AppTheme.primaryColor,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tapez pour ajouter une photo',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _imageSource != null
                                    ? 'Source: $_imageSource'
                                    : 'JPEG, PNG, WebP (max 10 Mo)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Informations cliniques',
                icon: Icons.medical_information_outlined,
                child: Column(
                  children: [
                    _LabeledField(
                      label: 'Zone anatomique',
                      child: DropdownButtonFormField<String>(
                        value: _bodyPart.isNotEmpty ? _bodyPart : null,
                        items: _bodyPartOptions.map((opt) {
                          return DropdownMenuItem<String>(
                            value: opt['value'],
                            child: Text(opt['label']!),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _bodyPart = v);
                        },
                        decoration: _inputDecoration('Selectionnez'),
                        validator: (v) => v == null ? 'Zone requise' : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _LabeledField(
                      label: 'Stade',
                      child: DropdownButtonFormField<String>(
                        value: _stage,
                        items: _stageOptions.map((opt) {
                          return DropdownMenuItem<String>(
                            value: opt['value'],
                            child: Text(opt['label']!),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _stage = v);
                        },
                        decoration: _inputDecoration('Selectionnez'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _LabeledField(
                      label: 'Date et heure',
                      child: TextFormField(
                        initialValue: _takenAt,
                        decoration: _inputDecoration(
                            'YYYY-MM-DD HH:MM'),
                        onChanged: (v) => _takenAt = v,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _LabeledField(
                      label: 'Notes cliniques',
                      child: TextFormField(
                        controller: _notesController,
                        decoration: _inputDecoration(
                            'Observations...'),
                        maxLines: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE11D48), Color(0xFFF59E0B)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33E11D48),
                        blurRadius: 16,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.cloud_upload_rounded),
                    label: Text(
                      _submitting ? 'Ajout en cours...' : 'Ajouter la photo',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    final colors = context.appColors;
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: colors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.4),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D111827),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFE4E6), Color(0xFFFFF7ED)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 20),
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
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
