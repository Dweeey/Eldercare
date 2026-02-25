class AppConfig {
  // Firebase configuration for web
  static const String firebaseApiKey = 'AIzaSyAU2sccq4OX9Gsx3GIlAAJSCnC9nPwR3Yo';
  static const String firebaseProjectId = 'eldercareplus-7bed9';
  static const String firebaseMessagingSenderId = '909778576380';
  static const String firebaseAppId = '1:909778576380:web:';
  static const String firebaseAuthDomain = 'eldercareplus-7bed9.firebaseapp.com';

  const AppConfig();

  static AppConfig fromEnvironment() {
    return const AppConfig();
  }
}
