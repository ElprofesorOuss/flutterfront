import 'package:flutter/material.dart';
import 'package:burning2026/app/router/app_router.dart';
import 'package:burning2026/core/theme/app_theme.dart';

class BurnCenterApp extends StatelessWidget {
  const BurnCenterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Burn Center 2026',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}