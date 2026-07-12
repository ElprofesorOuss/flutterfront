import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final double subtitleSize;
  final bool showSubtitle;

  const AppLogo({
    super.key,
    this.iconSize = 48,
    this.fontSize = 26,
    this.subtitleSize = 12,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize * 1.6,
          height: iconSize * 1.6,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE11D48), Color(0xFFF59E0B)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(iconSize * 0.46)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE11D48).withValues(alpha: 0.3),
                blurRadius: iconSize * 0.4,
                offset: Offset(0, iconSize * 0.25),
              ),
            ],
          ),
          child: Icon(
            Icons.local_fire_department_rounded,
            color: Colors.white,
            size: iconSize,
          ),
        ),
        SizedBox(height: iconSize * 0.3),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE11D48), Color(0xFFF59E0B)],
          ).createShader(bounds),
          child: Text(
            'BRULURE CARE',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
        if (showSubtitle) ...[
          SizedBox(height: fontSize * 0.25),
          Text(
            'Centre de Traitement des Brûlés',
            style: TextStyle(
              fontSize: subtitleSize,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}
