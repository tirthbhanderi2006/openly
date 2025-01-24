import 'package:flutter/material.dart';
import 'package:mithc_koko_chat_app/services/auth_services/auth_services.dart';
import 'package:mithc_koko_chat_app/components/widgets_components/my_button.dart';
import 'package:mithc_koko_chat_app/components/widgets_components/my_textfield.dart';
import 'package:mithc_koko_chat_app/pages/home_page.dart';
import 'package:mithc_koko_chat_app/pages/auth/register_page.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme; // Get the current theme's color scheme

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'lib/assets/telegram.png',
                    width: 110,
                  ),
                ),
                const SizedBox(height: 20),

                // Welcome back message
                Text(
                  "Welcome Back",
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Log in to your account to continue.",
                  style: TextStyle(
                    color: colorScheme.onBackground, // Adjust text color based on theme
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

                MyTextfield(
                  hintText: 'Enter your password',
                  obscureText: true,
                  controller: _passwordController,
                  focusNode: null,
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5)),
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  textColor: Theme.of(context).colorScheme.onBackground,
                ),
                // Password text field
                // MyTextfield(
                //   hintText: 'Enter your password',
                //   obscureText: true,
                //   controller: _passwordController,
                //   focusNode: null,
                // ),
                const SizedBox(height: 30),

                // Login button
                MyButton(
                  buttonText: 'Login',
                  onTap: () => _login(context),
                ),
                const SizedBox(height: 25),

                // Not a member? Register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Not a member?",
                      style: TextStyle(
                        color: colorScheme.primary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterPage(),
                        ),
                      ),
                      child: Text(
                        ' Register now',
                        style: TextStyle(
                          color: colorScheme.inversePrimary, // Use secondary color for emphasis
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

  // Login Function
  Future<void> _login(BuildContext context) async {
    try {
      await AuthService().signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
  }
}
