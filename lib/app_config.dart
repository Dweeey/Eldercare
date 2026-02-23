class AppConfig {
  final String supabaseUrl;
  final String supabaseAnonKey;

  const AppConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  });

  static AppConfig fromEnvironment() {
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw const FormatException(
        'Missing SUPABASE_URL or SUPABASE_ANON_KEY. '
        'Pass both using --dart-define.',
      );
    }

    return const AppConfig(
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
    );
  }
}
