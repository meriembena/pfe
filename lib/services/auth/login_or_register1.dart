import 'package:chat1/services/pages/login_page1.dart';
import 'package:chat1/services/pages/register_page1.dart';
import 'package:flutter/material.dart';

class LoginOrRegister1 extends StatefulWidget {
  const LoginOrRegister1({super.key});

  @override
  State<LoginOrRegister1> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister1> {
  bool showLoginPage = true;
  void togglePages1() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage1(
        onTap: togglePages1,
      );
    } else {
      return RegisterPage1(
        onTap: togglePages1,
      );
    }
  }
}
