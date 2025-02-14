import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mithc_koko_chat_app/pages/main_home.dart';
import 'package:mithc_koko_chat_app/services/auth_services/auth_services.dart';
import 'package:mithc_koko_chat_app/components/widgets_components/my_button.dart';
import 'package:mithc_koko_chat_app/components/widgets_components/my_textfield.dart';
import 'package:mithc_koko_chat_app/pages/home_page.dart';
import 'package:mithc_koko_chat_app/pages/auth/register_page.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Form key for validation

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Form(
              key: _formKey, // Assign the form key
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'lib/assets/telegram.png',
                    width: 110,
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
                      color: colorScheme.onBackground,
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
                    hintStyle: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.5)),
                    fillColor: Theme.of(context).colorScheme.surfaceVariant,
                    textColor: Theme.of(context).colorScheme.onBackground,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // Password text field
                  MyTextfield(
                    hintText: 'Enter your password',
                    obscureText: true,
                    controller: _passwordController,
                    focusNode: null,
                    hintStyle: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.5)),
                    fillColor: Theme.of(context).colorScheme.surfaceVariant,
                    textColor: Theme.of(context).colorScheme.onBackground,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
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
                            color: colorScheme.inversePrimary,
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
      ),
    );
  }

  // Login Function
  Future<void> _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      // Only proceed if the form is valid
      try {
        await AuthService().signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        Get.snackbar("Login", "Login successful!",
            snackPosition: SnackPosition.BOTTOM,
            colorText: Colors.white,
            backgroundColor: Colors.green);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainHome()),
        );
      } on Exception catch (e) {
        Get.snackbar("Login", "Login failed, icorrect id or password",
            colorText: Colors.red, snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
  }
}
