import 'package:eldercareapp/features/account/presentation/presentation.dart';
import 'package:eldercareapp/features/alerts/presentation/presentation.dart';
import 'package:eldercareapp/features/auth/presentation/presentation.dart';
import 'package:eldercareapp/features/home/presentation/presentation.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const authGate = '/';
  static const login = '/login';
  static const signUp = '/sign-up';
  static const home = '/home';
  static const alerts = '/alerts';
  static const history = '/history';
  static const account = '/account';
  static const location = '/location';
  static const emergencyContacts = '/emergency-contacts';
  static const medicalHistory = '/medical-history';
  static const medications = '/medications';
  static const notificationSettings = '/notification-settings';
  static const helpSupport = '/help-support';
  static const privacyPolicy = '/privacy-policy';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case authGate:
        return MaterialPageRoute(builder: (_) => const AuthGate());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case alerts:
        return MaterialPageRoute(builder: (_) => const AlertsPage());
      case history:
        return MaterialPageRoute(builder: (_) => const HistoryPage());
      case account:
        return MaterialPageRoute(builder: (_) => const AccountPage());
      case location:
        return MaterialPageRoute(builder: (_) => const LocationPage());
      case emergencyContacts:
        return MaterialPageRoute(builder: (_) => const EmergencyContactsPage());
      case medicalHistory:
        return MaterialPageRoute(builder: (_) => const MedicalHistoryPage());
      case medications:
        return MaterialPageRoute(builder: (_) => const MedicationsPage());
      case notificationSettings:
        return MaterialPageRoute(
          builder: (_) => const NotificationSettingsPage(),
        );
      case helpSupport:
        return MaterialPageRoute(builder: (_) => const HelpSupportPage());
      case privacyPolicy:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyPage());
      default:
        return MaterialPageRoute(builder: (_) => const AuthGate());
    }
  }
}
