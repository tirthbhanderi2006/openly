import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mithc_koko_chat_app/pages/auth/login_page.dart';
import '../../services/auth_services/auth_services.dart';
import '../../components/widgets_components/my_button.dart';
import '../../components/widgets_components/my_textfield.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Form(
              // ✅ Wrap with Form for validation
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'lib/assets/chat_logo3.png',
                    width: 90,
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

                  // Email field with validation
                  MyTextfield(
                    hintText: 'Enter your email',
                    obscureText: false,
                    controller: _emailController,
                    focusNode: null,
                    textColor: Theme.of(context).colorScheme.onBackground,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email cannot be empty";
                      }
                      if (!GetUtils.isEmail(value)) {
                        return "Enter a valid email address";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // Password field with validation
                  MyTextfield(
                    hintText: 'Enter your password',
                    obscureText: true,
                    controller: _passwordController,
                    focusNode: null,
                    textColor: Theme.of(context).colorScheme.onBackground,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password cannot be empty";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // Confirm password field with validation
                  MyTextfield(
                    hintText: 'Re-enter your password',
                    obscureText: true,
                    controller: _confirmpasswordController,
                    focusNode: null,
                    textColor: Theme.of(context).colorScheme.onBackground,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please confirm your password";
                      }
                      if (value != _passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Register button with validation
                  MyButton(
                    buttonText: 'Register',
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        _register(context);
                      }
                    },
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
      ),
    );
  }

  Future<void> _register(BuildContext context) async {
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
        profilePic: '',
      );

      // Close loading spinner
      Navigator.pop(context);

      // Show success message
      Get.snackbar("Register", "Registration successful!",
          colorText: Colors.white,
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.BOTTOM);

      // Navigate to login page
      // Navigator.pop(context);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ));
    } catch (e) {
      // Close loading spinner
      Navigator.pop(context);

      // Show error message
      Get.snackbar(
        "Register",
        "Registration failed: may be Email is alredy taken by other user!",
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.redAccent,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    super.dispose();
  }
}
