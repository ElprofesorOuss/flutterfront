import 'package:flutter/material.dart';
import 'package:burning2026/app/router/app_router.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:burning2026/core/theme/theme_controller.dart';

class BurnCenterApp extends StatefulWidget {
  const BurnCenterApp({super.key});

  static ThemeController themeControllerOf(BuildContext context) {
    final state = context.findAncestorStateOfType<_BurnCenterAppState>();
    assert(state != null, 'BurnCenterApp state not found in context');
    return state!.themeController;
  }

  @override
  State<BurnCenterApp> createState() => _BurnCenterAppState();
}

class _BurnCenterAppState extends State<BurnCenterApp> {
  late final ThemeController _themeController;

  ThemeController get themeController => _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = ThemeController()..load();
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Burn Center 2026',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeController.themeMode,
          initialRoute: AppRoutes.login,
          onGenerateRoute: AppRoutes.generateRoute,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
