import 'package:flutter/material.dart';
import 'package:mithc_koko_chat_app/pages/auth/login_page.dart';
import 'package:mithc_koko_chat_app/pages/auth/register_page.dart';

class LoginOrRegister extends StatefulWidget {
  LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  // initially show login page
  bool showLoginPage=true;
  // toggle between pages
  void togglePages(){
  setState(() {
    showLoginPage=!showLoginPage;
  });
  }

  @override
  Widget build(BuildContext context) {
    return showLoginPage ? LoginPage() : RegisterPage();
  }
}
