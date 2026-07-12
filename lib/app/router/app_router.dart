import 'package:flutter/material.dart';
import 'package:burning2026/features/auth/screens/login_screen.dart';
import 'package:burning2026/features/burn_anamnesis/screens/anamnesis_screen.dart';
import 'package:burning2026/features/burn_classification/screens/classification_screen.dart';
import 'package:burning2026/features/burn_mapping/screens/burn_map_screen.dart';
import 'package:burning2026/features/dashboard/screens/dashboard_screen.dart';
import 'package:burning2026/features/patients/screens/patient_create_screen.dart';
import 'package:burning2026/features/patients/screens/patient_list_screen.dart';
import 'package:burning2026/features/patients/screens/patient_detail_screen.dart';
import 'package:burning2026/features/hospitalisations/screens/hospitalisation_create_screen.dart';
import 'package:burning2026/features/hospitalisations/screens/hospitalisation_list_screen.dart';
import 'package:burning2026/features/hospitalisations/screens/hospitalisation_detail_screen.dart';
import 'package:burning2026/features/wounds_photos/screens/photo_add_screen.dart';
import 'package:burning2026/features/wounds_photos/screens/photo_gallery_screen.dart';
import 'package:burning2026/features/wounds_photos/screens/photo_detail_screen.dart';
import 'package:burning2026/features/alerts/screens/alerts_screen.dart';
import 'package:burning2026/features/trajectory/screens/trajectory_screen.dart';
import 'package:burning2026/features/nutrition/screens/nutrition_screen.dart';
import 'package:burning2026/features/observations/screens/observations_screen.dart';
import 'package:burning2026/features/notifications/screens/notifications_screen.dart';
import 'package:burning2026/features/initial_assessment/screens/initial_assessment_screen.dart';
import 'package:burning2026/features/respiratory_evaluation/screens/respiratory_evaluation_screen.dart';
import 'package:burning2026/features/profile/screens/profile_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String patientList = '/patients';
  static const String patientCreate = '/patients/create';
  static const String patientDetail = '/patients/detail';
  static const String hospitalisationList = '/hospitalisations';
  static const String hospitalisationCreate = '/hospitalisations/create';
  static const String hospitalisationDetail = '/hospitalisations/detail';
  static const String photoGallery = '/photos';
  static const String photoDetail = '/photos/detail';
  static const String photoAdd = '/photos/add';
  static const String alerts = '/alerts';
  static const String trajectory = '/trajectory';
  static const String nutrition = '/nutrition';
  static const String observations = '/observations';
  static const String notifications = '/notifications';
  static const String initialAssessment = '/initial-assessment';
  static const String respiratoryEvaluation = '/respiratory-evaluation';
  static const String anamnesis = '/anamnesis';
  static const String classification = '/classification';
  static const String burnMap = '/burn-map';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case patientList:
        return MaterialPageRoute(builder: (_) => const PatientListScreen());
      case patientCreate:
        return MaterialPageRoute(builder: (_) => const PatientCreateScreen());
      case patientDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => PatientDetailScreen(patientId: args?['patientId'] ?? ''),
        );
      case hospitalisationList:
        return MaterialPageRoute(
          builder: (_) => const HospitalisationListScreen(),
        );
      case hospitalisationCreate:
        return MaterialPageRoute(
          builder: (_) => const HospitalisationCreateScreen(),
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
          builder: (_) => PhotoGalleryScreen(admissionId: args?['admissionId'] ?? ''),
        );
      case photoDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => PhotoDetailScreen(photoId: args?['photoId'] ?? ''),
        );
      case photoAdd:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => PhotoAddScreen(admissionId: args?['admissionId'] ?? ''),
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
          builder: (_) => NutritionScreen(admissionId: args?['admissionId'] ?? ''),
        );
      case observations:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ObservationsScreen(admissionId: args?['hospitalisationId'] ?? ''),
        );
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case initialAssessment:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => InitialAssessmentScreen(
            admissionId: args?['admissionId'] ?? '',
            existingAssessment: args?['existingAssessment'],
          ),
        );
      case respiratoryEvaluation:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => RespiratoryEvaluationScreen(
            admissionId: args?['admissionId'] ?? '',
          ),
        );
      case anamnesis:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AnamnesisScreen(admissionId: args?['admissionId'] ?? ''),
        );
      case classification:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ClassificationScreen(admissionId: args?['admissionId'] ?? ''),
        );
      case burnMap:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => BurnMapScreen(admissionId: args?['admissionId'] ?? ''),
        );
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
