import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:eldercareapp/core/providers/user_provider.dart';
import 'package:eldercareapp/features/auth/presentation/login_page.dart';
import 'package:eldercareapp/features/home/presentation/home_page.dart';
import 'package:eldercareapp/services/zegocloud_voip_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Listen to auth state changes
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while waiting for auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Get current user from snapshot
        final user = snapshot.data;

        // Update UserProvider with user data
        if (user != null) {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          final userName = user.displayName ?? user.email?.split('@').first ?? 'User';
          userProvider.setUser(user.uid, userName, user.email ?? '');
          unawaited(
            ZegocloudVoipService.initForUser(
              userId: user.uid,
              userName: userName,
            ),
          );
        } else {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.clearUser();
          unawaited(ZegocloudVoipService.dispose());
        }

        // Navigate based on authentication state
        if (user != null) {
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
