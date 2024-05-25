import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat1/views/login_service.dart';
import 'package:chat1/views/register_service.dart';

class LoginOrRegister extends StatefulWidget {
  final String role;
  const LoginOrRegister({super.key, required this.role});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool showLoginPage = true;
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    //showLoginPage est Un booléen qui détermine quel type de page afficher.
    if (showLoginPage) {
      return LoginPage(
        role: widget.role,
        //Cette méthode inverse la valeur de showLoginPage chaque fois qu'elle est appelée
        onTap: togglePages,
      );
    } else {
      return RegisterPage(
        role: widget.role,
        onTap: togglePages,
      );
    }
  }
}
