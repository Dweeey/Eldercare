import 'package:flutter/material.dart';
import 'Login.dart';  // <-- import your Login page

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // required for native splash
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),   // <-- your Login screen class
    );
  }
}
