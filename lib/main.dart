import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:eldercareapp/app_routes.dart';
import 'package:eldercareapp/core/providers/theme_provider.dart';
import 'package:eldercareapp/core/providers/user_provider.dart';
import 'package:eldercareapp/core/providers/call_provider.dart';
import 'package:eldercareapp/services/zegocloud_voip_service.dart';
import 'package:eldercareapp/services/zegocloud_incoming_call_handler.dart';

// --- NEW IMPORTS FOR BACKGROUND ALERTS ---
import 'package:eldercareapp/services/notification_service.dart';
import 'package:eldercareapp/services/vital_monitor_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? startupError;
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    
    // 1. Initialize the Notification System (Asks caregiver for permission)
    await NotificationService.initialize();

    // 2. Start listening to the smartwatch's vitals & battery!
    // Note: We use 'patient_001' here for your thesis demo. 
    await VitalMonitorService.initializeBackgroundService();

    // 3. Set navigator key once; actual Zego user login happens after Firebase auth.
    ZegocloudVoipService.setupIncomingCallHandler(
      navigatorKey: MyApp.navigatorKey,
      onIncomingCall: (callerId, callerName, isVideo) {
        // Zego's UI handles everything; this callback is optional for custom logic
      },
    );
  } catch (e) {
    startupError = e.toString();
  }

  runApp(MyApp(startupError: startupError));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.startupError});

  final String? startupError;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    if (startupError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _StartupErrorScreen(errorMessage: startupError!),
      );
    }

    return MultiProvider(
      // If you add more global providers later, put them in this list.
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CallProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            navigatorKey: MyApp.navigatorKey,
            debugShowCheckedModeBanner: false,
            // LIGHT THEME
            theme: ThemeData(
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: false,
            ),
            // DARK THEME
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              useMaterial3: false,
            ),
            // Theme mode is controlled by ThemeProvider.
            themeMode: themeProvider.themeMode,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            initialRoute: AppRoutes.authGate,
          );
        },
      ),
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  const _StartupErrorScreen({required this.errorMessage});

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Firebase Initialization Error',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}