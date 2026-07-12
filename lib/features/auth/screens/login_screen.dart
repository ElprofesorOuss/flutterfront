import 'dart:ui';

import 'package:burning2026/app/router/app_router.dart';
import 'package:burning2026/core/theme/app_colors.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:burning2026/shared/widgets/app_logo.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'medecin@burn.center');
  final _passwordController = TextEditingController(text: '123456');
  bool _loading = false;
  bool _obscure = true;

  void _login() {
    setState(() => _loading = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF1F2),
              Colors.white,
              Color(0xFFFFF7ED),
            ],
          ),
        ),
        child: Stack(
          children: [
            const _BackgroundOrb(
              size: 260,
              top: -90,
              right: -80,
              colors: [Color(0x66FDA4AF), Color(0x66FCD34D)],
            ),
            const _BackgroundOrb(
              size: 260,
              left: -100,
              bottom: -70,
              colors: [Color(0x6640C4FF), Color(0x665EC7B7)],
            ),
            const _BackgroundOrb(
              size: 320,
              top: 180,
              left: 120,
              colors: [Color(0x33F9A8D4), Color(0x33C084FC)],
            ),
            Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: 18,
                    right: 18,
                    bottom: 10,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE11D48), Color(0xFFF59E0B)],
                    ),
                  ),
                  child: const Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    runSpacing: 6,
                    spacing: 12,
                    children: [
                      _BannerItem(
                        icon: Icons.local_hospital_outlined,
                        label: 'Urgences Brulures 24/7',
                      ),
                      _BannerItem(
                        icon: Icons.verified_user_outlined,
                        label: 'Acces medical securise',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SafeArea(
                    top: false,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 980;

                        return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 24,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight - 24,
                            ),
                            child: IntrinsicHeight(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 1180,
                                  ),
                                  child: Flex(
                                    direction:
                                        wide ? Axis.horizontal : Axis.vertical,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      if (wide)
                                        const Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(right: 24),
                                            child: _BrandPanel(),
                                          ),
                                        ),
                                      Expanded(
                                        child: Center(
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth: 520,
                                            ),
                                            child: _LoginCard(
                                              theme: theme,
                                              emailController:
                                                  _emailController,
                                              passwordController:
                                                  _passwordController,
                                              obscure: _obscure,
                                              loading: _loading,
                                              onToggleObscure: () {
                                                setState(() {
                                                  _obscure = !_obscure;
                                                });
                                              },
                                              onLogin: _login,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.theme,
    required this.emailController,
    required this.passwordController,
    required this.obscure,
    required this.loading,
    required this.onToggleObscure,
    required this.onLogin,
  });

  final ThemeData theme;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscure;
  final bool loading;
  final VoidCallback onToggleObscure;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Stack(
      children: [
        Positioned.fill(
          child: Transform.scale(
            scale: 1.04,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0x33E11D48), Color(0x33F59E0B)],
                ),
                borderRadius: BorderRadius.circular(34),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22111827),
                blurRadius: 40,
                offset: Offset(0, 22),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 5,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFE11D48),
                      Color(0xFFF59E0B),
                      Color(0xFF10B981),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              const AppLogo(),
              const SizedBox(height: 24),
              _FieldLabel('Email professionnel'),
              const SizedBox(height: 8),
              _InputShell(
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'medecin@hopital.fr',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _FieldLabel('Mot de passe'),
              const SizedBox(height: 8),
              _InputShell(
                child: TextField(
                  controller: passwordController,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: onToggleObscure,
                      icon: Icon(
                        obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Checkbox(
                    value: true,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (_) {},
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Se souvenir de moi',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Mot de passe oublie ?',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE11D48), Color(0xFFF59E0B)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x44E11D48),
                        blurRadius: 18,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: loading ? null : onLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.3,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Acceder a l\'espace medical',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFBEB), Color(0xFFFFF7ED)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFFD97706),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Acces strictement reserve',
                            style: TextStyle(
                              color: Color(0xFFB45309),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Aux professionnels de sante autorises. Connexion chiffree et usage conforme aux normes hospitalieres.',
                            style: TextStyle(
                              color: Color(0xFFB45309),
                              fontSize: 12.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  'medecin@burn.center / 123456',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    return Stack(
      children: [
        Positioned(
          top: 10,
          left: 10,
          child: _FloatingIconCard(
            size: 104,
            rotation: -0.18,
            colors: const [Color(0xFFE11D48), Color(0xFFF59E0B)],
            icon: Icons.local_fire_department_rounded,
          ),
        ),
        Positioned(
          top: 160,
          right: 18,
          child: _FloatingIconCard(
            size: 76,
            rotation: 0.16,
            colors: const [Color(0xFF0EA5E9), Color(0xFF22D3EE)],
            icon: Icons.water_drop_rounded,
          ),
        ),
        Positioned(
          bottom: 80,
          left: 80,
          child: _FloatingIconCard(
            size: 64,
            rotation: 0.28,
            colors: const [Color(0xFF10B981), Color(0xFF34D399)],
            icon: Icons.eco_rounded,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 50, left: 50, right: 30),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.52),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x140F172A),
                blurRadius: 34,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFE4E6), Color(0xFFFFF7ED)],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFFDA4AF)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      color: AppTheme.primaryColor,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Centre specialise dans le traitement des brulures',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFE11D48),
                    Color(0xFFF59E0B),
                    Color(0xFF10B981),
                  ],
                ).createShader(bounds),
                child: Text(
                  'Brulure Care',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Plateforme mobile dediee au suivi clinique, aux photos de plaies et a la priorisation des patients brules.',
                style: theme.textTheme.titleMedium?.copyWith(
                  height: 1.55,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),
              const Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _FeatureChip(
                    icon: Icons.monitor_heart_outlined,
                    label: 'Suivi en temps reel',
                    tint: Color(0xFFFCE7F3),
                    iconColor: Color(0xFFDB2777),
                  ),
                  _FeatureChip(
                    icon: Icons.thermostat_outlined,
                    label: 'Protocoles avances',
                    tint: Color(0xFFDBEAFE),
                    iconColor: Color(0xFF2563EB),
                  ),
                  _FeatureChip(
                    icon: Icons.shield_outlined,
                    label: 'Donnees securisees',
                    tint: Color(0xFFD1FAE5),
                    iconColor: Color(0xFF059669),
                  ),
                  _FeatureChip(
                    icon: Icons.medical_information_outlined,
                    label: 'Coordination des soins',
                    tint: Color(0xFFFFEDD5),
                    iconColor: Color(0xFFEA580C),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Row(
                children: [
                  Expanded(
                    child: _StatBlock(
                      value: '2500+',
                      label: 'Patients traites',
                      colors: [Color(0xFFE11D48), Color(0xFFF59E0B)],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _StatBlock(
                      value: '98%',
                      label: 'Satisfaction',
                      colors: [Color(0xFF2563EB), Color(0xFF22D3EE)],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _StatBlock(
                      value: '15+',
                      label: 'Centres partenaires',
                      colors: [Color(0xFF059669), Color(0xFF34D399)],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.tint,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color tint;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.value,
    required this.label,
    required this.colors,
  });

  final String value;
  final String label;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) =>
              LinearGradient(colors: colors).createShader(bounds),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: appColors.textLight,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}

class _FloatingIconCard extends StatelessWidget {
  const _FloatingIconCard({
    required this.size,
    required this.rotation,
    required this.colors,
    required this.icon,
  });

  final double size;
  final double rotation;
  final List<Color> colors;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(size * 0.25),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.32),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.42),
      ),
    );
  }
}

class _InputShell extends StatelessWidget {
  const _InputShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D111827),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: colors.textSecondary,
      ),
    );
  }
}

class _BannerItem extends StatelessWidget {
  const _BannerItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _BackgroundOrb extends StatelessWidget {
  const _BackgroundOrb({
    required this.size,
    required this.colors,
    this.top,
    this.right,
    this.bottom,
    this.left,
  });

  final double size;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 42, sigmaY: 42),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
