import 'package:flutter/material.dart';
import 'package:chat1/views/loginorregister_page.dart';
import 'package:chat1/views/auth_gate.dart';

class Racine extends StatelessWidget {
  Racine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/back.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: screenHeight *
                0.03, // Ajuster cette valeur pour positionner les éléments plus haut
            left: 0,
            right: 0,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/Groupe 77.png', // Remplacer par l'image "Groupe 77"
                  width:
                      screenWidth * 0.8, // Ajuster la taille selon les besoins
                  height: screenHeight * 0.3,
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
