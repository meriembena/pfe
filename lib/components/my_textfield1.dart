import 'package:flutter/material.dart';

class MyTextField1 extends StatelessWidget {
  final String hintTexti;
  final bool obscureTexti;
  final TextEditingController controlleri;
  final FocusNode? focusNode;
  const MyTextField1(
      {super.key,
      required this.hintTexti,
      required this.obscureTexti,
      required this.controlleri,
      this.focusNode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        obscureText: obscureTexti,
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.tertiary),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          fillColor: Theme.of(context).colorScheme.secondary,
          filled: true,
          hintText: hintTexti,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}
