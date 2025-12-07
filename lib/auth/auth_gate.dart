import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Login.dart'; // Login page
import '../Home.dart'; // Home page after authentication

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      // Listen to auth state changes
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Show loading indicator while waiting for auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Get current session from snapshot
        final session = snapshot.data?.session;

        // Navigate based on authentication state
        if (session != null && session.user != null) {
          // User is authenticated -> go to Home page
          return const HomePage();
        } else {
          // User is not authenticated -> go to Login page
          return const LoginScreen();
        }
      },
    );
  }
}
