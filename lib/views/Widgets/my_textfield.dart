import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  // pouvoir configurer le clavier affiché (numérique, email, etc.) pour optimiser l'entrée de l'utilisateur.
  final TextInputType keyboardType;
//un constructeur nommé permettant d'initialiser des instances de la classe avec des paramètres spécifique.
  const MyTextField({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  // build est responsable de la création et la mis à jour de l'interface utilisateur
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        keyboardType: keyboardType,
        obscureText: obscureText,
        controller: controller,
        decoration: InputDecoration(
          enabledBorder: InputBorder.none, // Suppression des bordures internes
          focusedBorder: InputBorder.none,
          fillColor: Colors.transparent, // Couleur de fond transparente
          //Indique que le champ doit être rempli avec la couleur de fond spécifiée.
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          contentPadding:
              EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        ),
      ),
    );
  }
}
