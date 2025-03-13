import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mithc_koko_chat_app/pages/auth/login_or_register.dart';
import '../main_home.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          Future.delayed(Duration.zero, () {
            if (snapshot.hasData) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>  MainHome()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginOrRegister()),
              );
            }
          });

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
