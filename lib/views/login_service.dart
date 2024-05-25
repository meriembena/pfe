import 'package:chat1/views/Catégories.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat1/views/Widgets/my_button.dart';
import 'package:chat1/views/Widgets/my_textfield.dart';
import 'package:chat1/Controller/auth_service.dart';

class LoginPage extends StatefulWidget {
  final String role;
  final void Function()? onTap;

  LoginPage({Key? key, required this.role, required this.onTap})
      : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final AuthService authService = AuthService();

  void login(BuildContext context) async {
    String email = _emailController.text.trim();
    String password = _pwController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showErrorDialog(context, "Veuillez remplir tous les champs.");
      return;
    }

    try {
      UserCredential userCredential =
          await authService.signInWithEmailPassword(email, password);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Categories()));
    } on FirebaseAuthException catch (e) {
      String errorMessage = _handleFirebaseAuthException(e);
      showErrorDialog(context, errorMessage);
    } catch (e) {
      showErrorDialog(
          context, "Une erreur inattendue est survenue : ${e.toString()}");
    }
  }

  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return "L'email fourni est incorrect.";
      case 'user-not-found':
      case 'wrong-password':
        return "L'email ou le mot de passe est incorrect.";
      default:
        return "Une erreur est survenue. Veuillez réessayer plus tard.";
    }
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Erreur de connexion"),
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeight,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/back.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        left: screenWidth * 0.08,
                        top: screenHeight * 0.2,
                        child: Container(
                          width: screenWidth * 0.84,
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/Groupe 77.png',
                                width: screenWidth * 0.15,
                                height: screenHeight * 0.15,
                              ),
                              SizedBox(height: 20),
                              Container(
                                width: screenWidth * 0.8,
                                height: screenHeight * 0.07,
                                margin: EdgeInsets.only(bottom: 20.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: MyTextField(
                                  hintText: "Adresse mail",
                                  obscureText: false,
                                  controller: _emailController,
                                ),
                              ),
                              Container(
                                width: screenWidth * 0.8,
                                height: screenHeight * 0.07,
                                margin: EdgeInsets.only(bottom: 20.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: MyTextField(
                                  hintText: "Mot de passe",
                                  obscureText: true,
                                  controller: _pwController,
                                ),
                              ),
                              MyButton(
                                text: "Connecter",
                                onTap: () => login(context),
                              ),
                              GestureDetector(
                                onTap: widget.onTap,
                                child: Text(
                                  "Inscrivez-vous maintenant",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pwController.dispose();
    super.dispose();
  }
}
