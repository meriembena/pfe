import 'package:chat1/services/auth/login_or_register1.dart';
import 'package:chat1/services/pages/home_page1.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate1 extends StatelessWidget {
  const AuthGate1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              return HomePage1();
            }));
  }
}
