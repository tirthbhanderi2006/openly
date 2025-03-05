import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mithc_koko_chat_app/pages/auth/login_or_register.dart';
import '../main_home.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(stream:
      FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
        // show loader if waiting to prevent any lag
        if(snapshot.connectionState==ConnectionState.waiting){
          return Center(child: CircularProgressIndicator(),);
        }
        // user loin or not?
        if(snapshot.hasData){
          return MainHome();//if user login then return HomePage
            // return HomePage();
        }else{
          return LoginOrRegister(); //if user not login then return LoginPage
        }
      },),
    );
  }
}
