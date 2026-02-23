import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // Supabase client instance
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmailPassword(String email, String password) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );
    return response;
  }

  // Sign out the current user
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get current user email (if logged in)
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
}
