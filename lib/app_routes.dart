import 'package:eldercareapp/features/account/presentation/account_page.dart';
import 'package:eldercareapp/features/account/presentation/emergency_contacts_page.dart';
import 'package:eldercareapp/features/account/presentation/help_support_page.dart';
import 'package:eldercareapp/features/account/presentation/medical_history_page.dart';
import 'package:eldercareapp/features/account/presentation/medications_page.dart';
import 'package:eldercareapp/features/account/presentation/notification_settings_page.dart';
import 'package:eldercareapp/features/account/presentation/privacy_policy_page.dart';
import 'package:eldercareapp/features/alerts/presentation/alerts_page.dart';
import 'package:eldercareapp/features/auth/presentation/auth_gate.dart';
import 'package:eldercareapp/features/auth/presentation/login_page.dart';
import 'package:eldercareapp/features/auth/presentation/sign_up_page.dart';
import 'package:eldercareapp/features/home/presentation/history_page.dart';
import 'package:eldercareapp/features/home/presentation/home_page.dart';
import 'package:eldercareapp/features/home/presentation/location_page.dart';
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
