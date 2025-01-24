import 'package:flutter/material.dart';
import '../../services/auth_services/auth_services.dart';
import '../../components/widgets_components/my_button.dart';
import '../../components/widgets_components/my_textfield.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController = TextEditingController();

  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or illustration
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'lib/assets/chat_logo3.png',
                    width: 90,
                  ),
                ),
                const SizedBox(height: 20),

                // Welcome message
                Text(
                  "Create Your Account",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Join us and explore the amazing features!",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Email text field
                MyTextfield(
                  hintText: 'Enter your email',
                  obscureText: false,
                  controller: _emailController,
                  focusNode: null,
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5)),
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  textColor: Theme.of(context).colorScheme.onBackground,
                ),
                const SizedBox(height: 15),

                // Password text field
        MyTextfield(
          hintText: 'Enter your Password',
          obscureText: true,
          controller: _passwordController,
          focusNode: null,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5)),
          fillColor: Theme.of(context).colorScheme.surfaceVariant,
          textColor: Theme.of(context).colorScheme.onBackground,
        ),
                const SizedBox(height: 15),

                // Confirm password text field
                MyTextfield(
                  hintText: 're enter your password',
                  obscureText: true,
                  controller: _confirmpasswordController,
                  focusNode: null,
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5)),
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  textColor: Theme.of(context).colorScheme.onBackground,
                ),
                const SizedBox(height: 30),

                // Register button
                MyButton(
                  buttonText: 'Register',
                  onTap: () => _register(context),
                ),
                const SizedBox(height: 20),

                Divider(
                  thickness: 1,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 20),

                // Already have an account? Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        ' Login now',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _register(BuildContext context) async {
    if (_passwordController.text != _confirmpasswordController.text) {
      // Show error if passwords do not match
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      // Show loading spinner
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Extract name from email
      String name = _emailController.text.split('@')[0];
      // Perform sign-up
      await AuthService().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: name,
        profilePic: '', // Add logic for profile picture if needed
      );

      // Close loading spinner
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );

      // Navigate to login page
      Navigator.pop(context);
    } catch (e) {
      // Close loading spinner
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
  }
}
