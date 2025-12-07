import 'package:flutter/material.dart';
import 'Privacy_page.dart'; // Privacy Policy page
import 'Login.dart'; // Login screen
import 'Terms_page.dart'; // Terms of Service page
import 'database_helper.dart'; // Database helper for SQLite
import 'Home.dart'; // Home page for guest login

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Controllers for text fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State variables
  bool _isChecked = false; // Terms & Privacy checkbox
  bool _isPasswordVisible = false; // Toggle password visibility
  bool _isLoading = false; // Show loading indicator

  // Sign up function
  Future<void> _signUp() async {
    // Validate terms agreement
    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to Terms and Privacy Policy')),
      );
      return;
    }

    // Validate fields
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Validate email format
    if (!_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    // Validate password length
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Insert user into database
      final db = DatabaseHelper.instance;
      await db.createUser({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text, // Consider hashing
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        _showSuccessDialog(); // Show success dialog
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email already exists or error occurred')),
        );
      }
    }
  }

  // Success dialog after registration
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.blue, size: 60),
            const SizedBox(height: 20),
            const Text(
              'Success',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your account has been successfully registered',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MyLoginApp()), // Navigate to login
                );
              },
              child: const Text("Go to Login", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // Custom text field builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword && !_isPasswordVisible,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
          if (isPassword)
            IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible; // Toggle password
                });
              },
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: () => Navigator.pop(context), // Back button
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Sign Up', // Page title
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildTextField(
                    controller: _nameController,
                    hint: "Enter your name",
                    icon: Icons.person_outline),
                const SizedBox(height: 15),
                _buildTextField(
                    controller: _emailController,
                    hint: "Enter your email",
                    icon: Icons.email_outlined),
                const SizedBox(height: 15),
                _buildTextField(
                    controller: _passwordController,
                    hint: "Enter your password",
                    icon: Icons.lock_outline,
                    isPassword: true),
                const SizedBox(height: 15),

                // Terms & Privacy checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _isChecked,
                      onChanged: (val) {
                        setState(() {
                          _isChecked = val ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Wrap(
                        children: [
                          const Text("I agree to the "),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const TermsPage()), // Terms page
                              );
                            },
                            child: const Text(
                              "Terms of Service",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Text(" and "),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const PrivacyPage()), // Privacy page
                              );
                            },
                            child: const Text(
                              "Privacy Policy",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),
                // Sign Up button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          "Sign Up",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
                const SizedBox(height: 12),
                // Guest button
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Continue as Guest",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Login redirect
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyLoginApp(),
                            ),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
