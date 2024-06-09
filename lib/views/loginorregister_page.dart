import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Saydaliati/views/login_service.dart';
import 'package:Saydaliati/views/register_service.dart';

// signifie que LoginOrRegister est dynamique et change d'etat
//LoginOrRegister Définit les paramètres fixes du widget et sait comment créer son état.
class LoginOrRegister extends StatefulWidget {
  final String role;
  // maintenir l'état des widgets et d'optimiser les performances lors de modifications
  const LoginOrRegister({super.key, required this.role});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

//_LoginOrRegisterState Contient et gère l'état dynamique du widget,
//y compris la logique pour construire l'interface utilisateur en réponse aux interactions de l'utilisateur.
class _LoginOrRegisterState extends State<LoginOrRegister> {
  //initalisation de l'affichage de la page de connexion
  bool showLoginPage = true;
  //togglePages méthode pour basculer entre la page de connexion et la page d'inscription
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  // build est responsable de la création et la mis à jour de l'interface utilisateur
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
