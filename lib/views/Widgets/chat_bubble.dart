import 'package:flutter/material.dart';

// Définir les couleurs personnalisées
const Color currentUserColor = Color(0xFFFFFFFF);
const Color otherUserColor = Color(0xFF099999);

class ChatBubble extends StatelessWidget {
  final String message;
  //Un booléen indiquant si le message a été envoyé par l'utilisateur actuel.
  final bool isCurrentUser;
  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  @override
  // build est responsable de la création et la mis à jour de l'interface utilisateur
  Widget build(BuildContext context) {
    // Utiliser les couleurs personnalisées pour les bulles de discussion
    Color bubbleColor = isCurrentUser ? currentUserColor : otherUserColor;

    return Container(
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 25),
      child: Text(
        message,
        style: TextStyle(
          color: isCurrentUser ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}
