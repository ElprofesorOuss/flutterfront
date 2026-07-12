import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:burning2026/core/theme/app_colors.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:burning2026/core/constants/api_constants.dart';
import 'package:burning2026/core/constants/severity_colors.dart';
import 'package:burning2026/core/models/burn_classification.dart';
import 'package:burning2026/app/router/app_router.dart';

class ClassificationScreen extends StatefulWidget {
  final String admissionId;

  const ClassificationScreen({super.key, required this.admissionId});

  @override
  State<ClassificationScreen> createState() => _ClassificationScreenState();
}

class _ClassificationScreenState extends State<ClassificationScreen> {
  BurnClassification? _classification;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClassification();
  }

  Future<void> _loadClassification() async {
    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse(
          '${ApiConstants.baseUrl}/admissions/${widget.admissionId}/classification');
      final response = await http.get(uri).timeout(ApiConstants.timeout);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>?;
        if (data != null) {
          setState(() {
            _classification = BurnClassification.fromMap(data);
            _isLoading = false;
          });
        } else {
          setState(() => _error = 'Format de réponse inattendu');
        }
      } else {
        setState(() => _error = 'Erreur serveur (${response.statusCode})');
      }
    } catch (e) {
      if (mounted) {
        setState(
            () => _error = 'Erreur réseau : impossible de charger la classification');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final sevColor = _classification != null
        ? SeverityColors.fromLevel(_classification!.severityLevel)
        : SeverityColors.moderate;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          title: const Text('Classification'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          title: const Text('Classification'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded, size: 64, color: colors.textLight),
                const SizedBox(height: 16),
                Text(_error!,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: colors.textSecondary, fontSize: 15)),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _loadClassification,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_classification == null) {
      return Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          title: const Text('Classification'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, size: 64, color: colors.textLight),
              const SizedBox(height: 16),
              Text('Aucune classification disponible',
                  style: TextStyle(color: colors.textSecondary, fontSize: 15)),
            ],
          ),
        ),
      );
    }

    final c = _classification!;
    return Scaffold(
      backgroundColor: colors.surface,
      body: RefreshIndicator(
        onRefresh: _loadClassification,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 280,
              collapsedHeight: 112,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: AppTheme.primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        sevColor,
                        sevColor.withValues(alpha: 0.7),
                        sevColor.withValues(alpha: 0.4),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          20,
                          MediaQuery.of(context).padding.top + 16,
                          20,
                          0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.arrow_back_rounded,
                                      color: Colors.white, size: 22),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Score $c.severityScore/6',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.severityLabel,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 34,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.analytics_rounded,
                                              color: Colors.white, size: 16),
                                          const SizedBox(width: 6),
                                          const Text('Classification clinique',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildScoreRing(c.severityScore),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(
                  children: [
                    _statBlock(colors,
                        '${c.tbsaPercentage.toStringAsFixed(1)}%', 'TBSA',
                        color: _tbsaColor(c.tbsaPercentage)),
                    const SizedBox(width: 10),
                    _statBlock(colors, c.burnDepthSummary, 'Profondeur max',
                        color: _depthColor(c.highestDegree)),
                    const SizedBox(width: 10),
                    _statBlock(colors, '${c.criticalAreas.length}', 'Zones critiques',
                        color: c.criticalAreas.isNotEmpty
                            ? SeverityColors.severe
                            : SeverityColors.low),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildTbsaBar(colors, c),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Text('Profondeur des lésions',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary)),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildDepthSection(colors, c),
            ),
            if (c.criticalAreas.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Text('Zones critiques',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary)),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildCriticalAreasSection(colors, c),
              ),
            ],
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(
                  children: [
                    Text('Inhalation',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: c.inhalationInjury
                            ? SeverityColors.severe.withValues(alpha: 0.12)
                            : SeverityColors.low.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            c.inhalationInjury
                                ? Icons.error_outline
                                : Icons.check_circle_outline,
                            size: 16,
                            color: c.inhalationInjury
                                ? SeverityColors.severe
                                : SeverityColors.low,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            c.inhalationInjury ? 'Présente' : 'Non détectée',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: c.inhalationInjury
                                  ? SeverityColors.severe
                                  : SeverityColors.low,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildInhalationDetail(colors, c),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Text('Détail du score',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary)),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildRulesBreakdown(colors, c),
            ),
            SliverToBoxAdapter(
              child: _buildNotesCard(colors, c),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.burnMap,
                      arguments: {'admissionId': widget.admissionId},
                    ),
                    icon: const Icon(Icons.edit_rounded, size: 20),
                    label: const Text('Modifier la cartographie',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRing(int score) {
    final pct = score / 6.0;
    return SizedBox(
      width: 72,
      height: 72,
      child: CustomPaint(
        painter: _ScoreRingPainter(progress: pct, score: score),
        child: Center(
          child: Text(
            '$score',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _statBlock(AppColors colors, String value, String label,
      {required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: color.withValues(alpha: 0.15), width: 1.5),
        ),
        child: Column(
          children: [
            Text(value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: color,
                )),
            const SizedBox(height: 3),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildTbsaBar(AppColors colors, BurnClassification c) {
    final barColor = _tbsaColor(c.tbsaPercentage);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Surface corporelle brûlée (TBSA)',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary)),
                Text('${c.tbsaPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: barColor)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 10,
                child: Row(
                  children: [
                    Expanded(
                      flex: (c.tbsaPercentage * 10).round().clamp(0, 1000),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              SeverityColors.low,
                              SeverityColors.moderate,
                              SeverityColors.severe,
                              SeverityColors.critical,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: (1000 - (c.tbsaPercentage * 10).round()).clamp(0, 1000),
                      child: Container(
                        color: Colors.grey.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _tbsaMarker(colors, 'Faible', '<10%', c.tbsaPercentage < 10),
                _tbsaMarker(colors, 'Modérée', '10-19%',
                    c.tbsaPercentage >= 10 && c.tbsaPercentage < 20),
                _tbsaMarker(colors, 'Sévère', '20-39%',
                    c.tbsaPercentage >= 20 && c.tbsaPercentage < 40),
                _tbsaMarker(colors, 'Critique', '≥40%', c.tbsaPercentage >= 40),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tbsaMarker(AppColors colors, String label, String range, bool active) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppTheme.primaryColor : Colors.grey.withValues(alpha: 0.25),
          ),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              color: active ? colors.textPrimary : Colors.grey,
            )),
      ],
    );
  }

  Widget _buildDepthSection(AppColors colors, BurnClassification c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _depthChip(colors, '1er degré', c.highestDegree == '1st',
                    const Color(0xFFF59E0B)),
                const SizedBox(width: 8),
                _depthChip(colors, '2e superficiel', c.highestDegree == '2nd_superficial',
                    const Color(0xFFEF4444)),
                const SizedBox(width: 8),
                _depthChip(colors, '2e profond', c.highestDegree == '2nd_deep',
                    const Color(0xFFDC2626)),
                const SizedBox(width: 8),
                _depthChip(colors, '3e degré', c.highestDegree == '3rd',
                    const Color(0xFF7F1D1D)),
              ],
            ),
            if (c.deepBurnPresent) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: SeverityColors.severe.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: SeverityColors.severe.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: SeverityColors.severe, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Brûlure profonde détectée — risque de complications accru',
                        style: TextStyle(
                          fontSize: 12,
                          color: SeverityColors.severe,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _depthChip(AppColors colors, String label, bool active, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.15) : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? color : Colors.grey.withValues(alpha: 0.15),
            width: active ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: active ? color : Colors.grey.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  color: active ? color : Colors.grey,
                  height: 1.1,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildCriticalAreasSection(
      AppColors colors, BurnClassification c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: c.criticalAreas.map((area) {
            final color = _criticalZoneColor(area.key);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_criticalZoneIcon(area.key), color: color, size: 20),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(area.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          )),
                      Text(area.maxDegreeLabel,
                          style: TextStyle(
                              fontSize: 11, color: colors.textSecondary)),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInhalationDetail(AppColors colors, BurnClassification c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: c.inhalationInjury
                    ? SeverityColors.severe.withValues(alpha: 0.12)
                    : SeverityColors.low.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                c.inhalationInjury
                    ? Icons.air_rounded
                    : Icons.check_circle_rounded,
                color: c.inhalationInjury
                    ? SeverityColors.severe
                    : SeverityColors.low,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.inhalationInjury
                        ? 'Brûlure par inhalation détectée'
                        : 'Aucun signe d\'inhalation',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    c.inhalationInjury
                        ? 'Surveillance respiratoire renforcée requise'
                        : 'Voies aériennes préservées',
                    style: TextStyle(
                        fontSize: 12, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesBreakdown(AppColors colors, BurnClassification c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            ...c.triggeredRules.asMap().entries.map((entry) {
              final idx = entry.key;
              final rule = entry.value;
              final isLast = idx == c.triggeredRules.length - 1;
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: rule.points > 0
                              ? _ruleColor(rule.rule).withValues(alpha: 0.15)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '+${rule.points}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: rule.points > 0
                                  ? _ruleColor(rule.rule)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rule.rule,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                )),
                            const SizedBox(height: 2),
                            Text(rule.detail,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: colors.textSecondary)),
                          ],
                        ),
                      ),
                      Text(
                        '${rule.points} pt${rule.points > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _ruleColor(rule.rule),
                        ),
                      ),
                    ],
                  ),
                  if (!isLast) ...[
                    const SizedBox(height: 12),
                    Container(
                      height: 1,
                      color: colors.textLight.withValues(alpha: 0.15),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            }),
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: colors.textLight.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score total',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    )),
                Text('${c.severityScore} / 6',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: SeverityColors.fromLevel(c.severityLevel),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(AppColors colors, BurnClassification c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFF6366F1).withValues(alpha: 0.12)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.note_alt_rounded,
                  color: Color(0xFF6366F1), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Note clinique',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      )),
                  const SizedBox(height: 6),
                  Text(c.classificationNotes,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                        height: 1.5,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _tbsaColor(double tbsa) {
    if (tbsa >= 40) return SeverityColors.critical;
    if (tbsa >= 20) return SeverityColors.severe;
    if (tbsa >= 10) return SeverityColors.moderate;
    return SeverityColors.low;
  }

  Color _depthColor(String? degree) {
    switch (degree) {
      case '3rd':
        return SeverityColors.critical;
      case '2nd_deep':
        return SeverityColors.severe;
      case '2nd_superficial':
        return SeverityColors.moderate;
      case '1st':
        return SeverityColors.low;
      default:
        return Colors.grey;
    }
  }

  Color _criticalZoneColor(String key) {
    switch (key) {
      case 'face':
        return const Color(0xFF3B82F6);
      case 'mains':
        return const Color(0xFF8B5CF6);
      case 'perinee':
        return const Color(0xFFEC4899);
      case 'thorax':
        return const Color(0xFFF59E0B);
      case 'pieds':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  IconData _criticalZoneIcon(String key) {
    switch (key) {
      case 'face':
        return Icons.face_rounded;
      case 'mains':
        return Icons.pan_tool_rounded;
      case 'perinee':
        return Icons.accessibility_new_rounded;
      case 'thorax':
        return Icons.accessibility_rounded;
      case 'pieds':
        return Icons.directions_walk_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  Color _ruleColor(String rule) {
    if (rule.contains('TBSA')) return const Color(0xFF3B82F6);
    if (rule.contains('profonde')) return const Color(0xFFDC2626);
    if (rule.contains('critique')) return const Color(0xFFF59E0B);
    if (rule.contains('Inhalation')) return const Color(0xFF8B5CF6);
    return const Color(0xFF10B981);
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final int score;

  _ScoreRingPainter({required this.progress, required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.score != score;
}
