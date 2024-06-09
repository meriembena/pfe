import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  //une déclaration d'une propriété dans une classe Dart
  final void Function()? onTap;
  final String text;
  const MyButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  // build est responsable de la création et la mis à jour de l'interface utilisateur
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
        ),
        padding: EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        child: Center(
          child: Text(text),
        ),
      ),
    );
  }
}
