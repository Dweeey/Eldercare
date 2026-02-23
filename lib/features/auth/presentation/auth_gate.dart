import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:eldercareapp/core/providers/user_provider.dart';
import 'package:eldercareapp/features/auth/presentation/login_page.dart';
import 'package:eldercareapp/features/home/presentation/home_page.dart';

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
        final user = session?.user;

        // Update UserProvider with user data
        if (user != null) {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.setUser(
            user.id,
            user.userMetadata?['full_name'] ?? user.email?.split('@').first ?? 'User',
            user.email ?? '',
          );
        } else {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.clearUser();
        }

        // Navigate based on authentication state
        if (session != null && user != null) {
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
