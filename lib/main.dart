import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Login.dart';  // <-- import your Login page
import 'user_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // required for native splash
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const LoginScreen(),   // <-- your Login screen class
      ),
    );
  }
}
