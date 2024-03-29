import 'package:flutter/material.dart';

class MyButton1 extends StatelessWidget {
  final void Function()? onTap;
  final String texti;
  const MyButton1({
    super.key,
    required this.texti,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        child: Center(
          child: Text(texti),
        ),
      ),
    );
  }
}
