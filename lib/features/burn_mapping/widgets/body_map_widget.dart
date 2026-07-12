import 'package:flutter/material.dart';

class BodyZone {
  final String key;
  final String label;
  final String? degree;
  final VoidCallback onTap;

  BodyZone({
    required this.key,
    required this.label,
    this.degree,
    required this.onTap,
  });
}

class BodyMapWidget extends StatelessWidget {
  final List<BodyZone> zones;
  final bool showBack;

  const BodyMapWidget({
    super.key,
    required this.zones,
    this.showBack = false,
  });

  Color _degreeFill(String? degree) {
    switch (degree) {
      case '1st':
        return const Color(0xFFF59E0B).withValues(alpha: 0.24);
      case '2nd_superficial':
        return const Color(0xFFEF4444).withValues(alpha: 0.30);
      case '2nd_deep':
        return const Color(0xFFDC2626).withValues(alpha: 0.40);
      case '3rd':
        return const Color(0xFF7F1D1D).withValues(alpha: 0.55);
      default:
        return Colors.transparent;
    }
  }

  Color _degreeBorder(String? degree) {
    switch (degree) {
      case '1st':
        return const Color(0xFFF59E0B);
      case '2nd_superficial':
        return const Color(0xFFEF4444);
      case '2nd_deep':
        return const Color(0xFFDC2626);
      case '3rd':
        return const Color(0xFF7F1D1D);
      default:
        return const Color(0xFFCBD5E1);
    }
  }

  String? _degreeFor(String key) {
    for (final zone in zones) {
      if (zone.key == key) return zone.degree;
    }
    return null;
  }

  BodyZone _zoneFor(String key) {
    for (final zone in zones) {
      if (zone.key == key) return zone;
    }
    return BodyZone(key: key, label: key, onTap: () {});
  }

  Widget _part(
    String key,
    String shortLabel,
    double widthFactor,
    double heightFactor, {
    EdgeInsets margin = EdgeInsets.zero,
    double borderRadius = 10,
  }) {
    final zone = _zoneFor(key);
    final degree = _degreeFor(key);
    final fill = _degreeFill(degree);
    final border = _degreeBorder(degree);

    return Expanded(
      flex: (widthFactor * 100).round(),
      child: Padding(
        padding: margin,
        child: AspectRatio(
          aspectRatio: widthFactor / heightFactor,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(borderRadius),
              onTap: zone.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: border,
                    width: degree == null ? 1.2 : 2,
                  ),
                  boxShadow: degree == null
                      ? null
                      : [
                          BoxShadow(
                            color: border.withValues(alpha: 0.16),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    shortLabel,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      height: 1.05,
                      fontWeight: FontWeight.w700,
                      color: degree == null
                          ? const Color(0xFF64748B)
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(List<Widget> children) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final front = !showBack;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        final totalWidth = constraints.maxWidth;

        return SingleChildScrollView(
          child: SizedBox(
            width: totalWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: maxHeight * 0.10,
                  child: _part(
                    front ? 'head_front' : 'head_back',
                    front ? 'Tete\nface' : 'Tete\ndos',
                    0.24,
                    0.10,
                    margin: EdgeInsets.symmetric(horizontal: totalWidth * 0.38),
                    borderRadius: 18,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: maxHeight * 0.24,
                  child: _row([
                    _part(
                      front ? 'left_arm_front_upper' : 'left_arm_back_upper',
                      'Bras G',
                      0.15,
                      0.24,
                      margin: const EdgeInsets.only(right: 4),
                    ),
                    _part(
                      front ? 'torso_front' : 'torso_back',
                      front ? 'Tronc' : 'Dos',
                      0.32,
                      0.24,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      borderRadius: 16,
                    ),
                    _part(
                      front ? 'right_arm_front_upper' : 'right_arm_back_upper',
                      'Bras D',
                      0.15,
                      0.24,
                      margin: const EdgeInsets.only(left: 4),
                    ),
                  ]),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: maxHeight * 0.17,
                  child: _row([
                    _part(
                      front ? 'left_arm_front_forearm' : 'left_arm_back_forearm',
                      'Av-Bras G',
                      0.13,
                      0.17,
                      margin: const EdgeInsets.only(right: 4),
                    ),
                    _part(
                      'perineum',
                      'Perinee',
                      0.12,
                      0.17,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      borderRadius: 14,
                    ),
                    _part(
                      front
                          ? 'right_arm_front_forearm'
                          : 'right_arm_back_forearm',
                      'Av-Bras D',
                      0.13,
                      0.17,
                      margin: const EdgeInsets.only(left: 4),
                    ),
                  ]),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: maxHeight * 0.08,
                  child: _row([
                    _part(
                      front ? 'left_hand_front' : 'left_hand_back',
                      'Main G',
                      0.11,
                      0.08,
                      margin: const EdgeInsets.only(right: 6),
                    ),
                    _part(
                      front ? 'right_hand_front' : 'right_hand_back',
                      'Main D',
                      0.11,
                      0.08,
                      margin: const EdgeInsets.only(left: 6),
                    ),
                  ]),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: maxHeight * 0.18,
                  child: _row([
                    _part(
                      front ? 'left_thigh_front' : 'left_thigh_back',
                      'Cuisse G',
                      0.19,
                      0.18,
                      margin: const EdgeInsets.only(right: 4),
                    ),
                    _part(
                      front ? 'right_thigh_front' : 'right_thigh_back',
                      'Cuisse D',
                      0.19,
                      0.18,
                      margin: const EdgeInsets.only(left: 4),
                    ),
                  ]),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: maxHeight * 0.18,
                  child: _row([
                    _part(
                      front ? 'left_leg_front_lower' : 'left_leg_back_lower',
                      'Jambe G',
                      0.16,
                      0.18,
                      margin: const EdgeInsets.only(right: 4),
                    ),
                    _part(
                      front ? 'right_leg_front_lower' : 'right_leg_back_lower',
                      'Jambe D',
                      0.16,
                      0.18,
                      margin: const EdgeInsets.only(left: 4),
                    ),
                  ]),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: maxHeight * 0.08,
                  child: _row([
                    _part(
                      front ? 'left_foot_front' : 'left_foot_back',
                      'Pied G',
                      0.16,
                      0.08,
                      margin: const EdgeInsets.only(right: 6),
                    ),
                    _part(
                      front ? 'right_foot_front' : 'right_foot_back',
                      'Pied D',
                      0.16,
                      0.08,
                      margin: const EdgeInsets.only(left: 6),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
