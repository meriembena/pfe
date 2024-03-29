import 'package:chat1/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatBubble1 extends StatelessWidget {
  final String messagei;
  final bool isCurrentUseri;
  const ChatBubble1(
      {super.key, required this.messagei, required this.isCurrentUseri});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Container(
      decoration: BoxDecoration(
        color: isCurrentUseri
            ? (isDarkMode ? Colors.green.shade600 : Colors.green.shade500)
            : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 25),
      child: Text(
        messagei,
        style: TextStyle(
            color: isCurrentUseri
                ? Colors.white
                : (isDarkMode ? Colors.white : Colors.black)),
      ),
    );
  }
}
