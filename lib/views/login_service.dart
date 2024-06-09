import 'package:Saydaliati/views/Categories.dart';
import 'package:flutter/material.dart';
import 'package:Saydaliati/views/Widgets/my_button.dart';
import 'package:Saydaliati/views/Widgets/my_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Saydaliati/Controller/auth_service.dart';

// cette classe est dynamique change d'etat
class LoginPage extends StatefulWidget {
  final String role;
  final void Function()? onTap;
// maintenir l'état des widgets et d'optimiser les performances lors de modifications
  LoginPage({Key? key, required this.role, required this.onTap})
      : super(key: key);

  @override
  //construire le widget LoginPageState, il appelle
//createState(). Cette méthode retourne une instance de _LoginPageState,
//qui contient tout l'état nécessaire
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final AuthService authService = AuthService();

  @override
  //C'est l'endroit où vous pouvez insérer le code d'initialisation qui doit s'exécuter une seule fois
  void initState() {
    super.initState();
  }

  void login(BuildContext context) async {
    try {
      UserCredential userCredential = await authService.signInWithEmailPassword(
        _emailController.text,
        _pwController.text,
      );

      FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid)
          .get()
          .then((doc) {
        if (doc.exists) {
          Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
          if (userData['role'] == widget.role && widget.role == 'chercheur') {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => categories()));
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Accès refusé pour le rôle non autorisé."),
              ),
            );
          }
        }
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Erreur de connexion: ${e.toString()}"),
        ),
      );
    }
  }

  @override
  // build est responsable de la création et la mis à jour de l'interface utilisateur
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
// Scaffold widget est prédéfini par Flutter.
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Permet de fermer le clavier lorsque l'utilisateur appuie n'importe où en dehors des champs de texte
          FocusScope.of(context).unfocus();
        },
        //permet de faire défiler un seul widget enfant qui pourrait dépasser les dimensions de l'écran
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
                                margin: EdgeInsets.only(bottom: 10.0),
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
                              SizedBox(height: 20),
                              MyButton(
                                text: "Connecter",
                                onTap: () => login(context),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 20.0),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 10.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            "Pas un membre ?",
                                            style:
                                                TextStyle(color: Colors.black),
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
                                    )
                                  ],
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
}
