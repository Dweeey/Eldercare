import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Login.dart'; // Login screen entry
import 'user_provider.dart';
import 'theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase setup
  await Supabase.initialize(
    url: 'https://qfrpqgbgspfgqpqnlsat.supabase.co',
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFmcnBxZ2Jnc3BmZ3FwcW5sc2F0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUwNzExNTMsImV4cCI6MjA4MDY0NzE1M30.i7GcE-aPI-gZqBiBTVxKtcp04JaKooxp1jzLj3jIzeM"
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // If you add more global providers later, put them in this list.
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
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
            // Theme mode controlled by ThemeProvider (see theme_provider.dart)
            themeMode: themeProvider.themeMode,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
