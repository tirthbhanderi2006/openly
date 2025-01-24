import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mithc_koko_chat_app/pages/auth/login_or_register.dart';

import '../home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(stream:
      FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
        // user loin or not?
        if(snapshot.hasData){
            return HomePage();
        }else{
          return LoginOrRegister();
        }
      },),
    );
  }
}
