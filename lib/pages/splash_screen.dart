import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:async';
import 'package:mithc_koko_chat_app/pages/auth/auth_gate.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize Animation Controller
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    // Define Fade Animation
    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    // Start Animation
    _controller.forward();

    // Navigate to the home screen after a delay
    Timer(Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthGate()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF3A3A3A), // Medium-dark grey start
              Color(0xFF5A5A5A), // Softer grey end
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lottie Animation
                Lottie.asset(
                  'lib/assets/splash-screen.json',
                  width: 220,
                  height: 220,
                ),

                SizedBox(height: 20),

                // App Name with Typing Animation
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      "Openly",
                      textStyle: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      speed: Duration(milliseconds: 250),
                    ),
                  ],
                  totalRepeatCount: 1,
                  pause: Duration(milliseconds: 800),
                  displayFullTextOnTap: true,
                  stopPauseOnTap: true,
                ),

                SizedBox(height: 10),

                // Tagline with Fade Animation
                AnimatedTextKit(
                  animatedTexts: [
                    TyperAnimatedText(
                      "Connect. Share. Be Heard.",
                      textStyle: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                  totalRepeatCount: 1,
                  pause: Duration(milliseconds: 500),
                  displayFullTextOnTap: true,
                  stopPauseOnTap: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
