import 'package:Saydaliati/Controller/auth_service.dart';
import 'package:Saydaliati/views/Profile.dart';
import 'package:flutter/material.dart';
import 'package:Saydaliati/views/reservation.dart';

// statique et ne change pas
class MyDrawer extends StatelessWidget {
  //permet de passer une clé au widget, ce qui est utile pour maintenir l'état dans l'arbre des widgets
  const MyDrawer({super.key});

  void logout() {
    //crée une nouvelle instance de AuthService
    final auth = AuthService();
//Firebase fournit une méthode signOut() dans son API d'authentification qui gère
//la déconnexion de l'utilisateur de l'application
    auth.signOut();
  }

  @override
  // build est responsable de la création et la mis à jour de l'interface utilisateur
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                child: Center(
                  child: Image.asset(
                    'assets/images/icone1.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  title: const Text("D I S C U S S I O N S"),
                  leading: Image.asset(
                    'assets/images/icone2.png',
                    width: 24,
                    height: 24,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  title: const Text("R É S E R V A T I O N S"),
                  leading: Image.asset(
                    'assets/images/icone4.png',
                    width: 24,
                    height: 24,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ReservationsPage()),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  title: const Text("P R O F I L"),
                  leading: Image.asset(
                    'assets/images/icone5.png',
                    width: 24,
                    height: 24,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25),
            child: ListTile(
              title: const Text("D É C O N N E X I O N"),
              leading: const Icon(Icons.logout),
              onTap: logout,
            ),
          ),
        ],
      ),
    );
  }
}
