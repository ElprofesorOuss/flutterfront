import 'package:flutter/material.dart';
import 'package:burning2026/features/auth/screens/login_screen.dart';
import 'package:burning2026/features/dashboard/screens/dashboard_screen.dart';
import 'package:burning2026/features/patients/screens/patient_list_screen.dart';
import 'package:burning2026/features/patients/screens/patient_detail_screen.dart';
import 'package:burning2026/features/hospitalisations/screens/hospitalisation_detail_screen.dart';
import 'package:burning2026/features/wounds_photos/screens/photo_gallery_screen.dart';
import 'package:burning2026/features/wounds_photos/screens/photo_detail_screen.dart';
import 'package:burning2026/features/alerts/screens/alerts_screen.dart';
import 'package:burning2026/features/trajectory/screens/trajectory_screen.dart';
import 'package:burning2026/features/nutrition/screens/nutrition_screen.dart';
import 'package:burning2026/features/observations/screens/observations_screen.dart';
import 'package:burning2026/features/notifications/screens/notifications_screen.dart';
import 'package:burning2026/features/profile/screens/profile_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String patientList = '/patients';
  static const String patientDetail = '/patients/detail';
  static const String hospitalisationDetail = '/hospitalisations/detail';
  static const String photoGallery = '/photos';
  static const String photoDetail = '/photos/detail';
  static const String alerts = '/alerts';
  static const String trajectory = '/trajectory';
  static const String nutrition = '/nutrition';
  static const String observations = '/observations';
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case patientList:
        return MaterialPageRoute(builder: (_) => const PatientListScreen());
      case patientDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => PatientDetailScreen(patientId: args?['patientId'] ?? ''),
        );
      case hospitalisationDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => HospitalisationDetailScreen(
            hospitalisationId: args?['hospitalisationId'] ?? '',
          ),
        );
      case photoGallery:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => PhotoGalleryScreen(patientId: args?['patientId'] ?? ''),
        );
      case photoDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => PhotoDetailScreen(photoId: args?['photoId'] ?? ''),
        );
      case alerts:
        return MaterialPageRoute(builder: (_) => const AlertsScreen());
      case trajectory:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => TrajectoryScreen(patientId: args?['patientId'] ?? ''),
        );
      case nutrition:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => NutritionScreen(patientId: args?['patientId'] ?? ''),
        );
      case observations:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ObservationsScreen(patientId: args?['patientId'] ?? ''),
        );
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
          body: Center(child: Text('Route not found')),
        ));
    }
  }
}