import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Saydaliati/views/loginorregister_page.dart';
import 'package:Saydaliati/views/auth_gate.dart';

// signifie que Racine est statique ne change pas
class Racine extends StatelessWidget {
  // maintenir l'état des widgets et d'optimiser les performances lors de modifications
  Racine({Key? key}) : super(key: key);

  @override
  // build est responsable de la création et la mis à jour de l'interface utilisateur
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
// Scaffold widget est prédéfini par Flutter.
    return Scaffold(
      //le widget Stack permet de superposer plusieurs widgets les uns sur les autres.
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/back.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: screenHeight * 0.03,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/Groupe 77.png',
                  width: screenWidth * 0.8,
                  height: screenHeight * 0.3,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(screenWidth * 0.6, 50),
                    foregroundColor: Colors.grey,
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    shadowColor: Colors.grey.withOpacity(0.3),
                    elevation: 5,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginOrRegister(role: 'chercheur'),
                    ),
                  ),
                  child: Text('Je suis un chercheur'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(screenWidth * 0.6, 50), // Taille minimale
                    foregroundColor: Colors.grey,
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    shadowColor: Colors.grey.withOpacity(0.3),
                    elevation: 5,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AuthGate(role: 'pharmacien'),
                    ),
                  ),
                  child: Text('Je suis un pharmacien'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
