import 'package:chat1/Controller/auth_service.dart';
import 'package:chat1/views/Profile.dart';
import 'package:flutter/material.dart';
import 'package:chat1/views/reservation.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout() {
    final auth = AuthService();
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white, // Définir le fond blanc ici
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                child: Center(
                  child: Image.asset(
                    'assets/images/icone1.png', // Remplacez par le chemin de votre première icône
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  title: const Text("D I S C U T I O N"),
                  leading: Image.asset(
                    'assets/images/icone2.png', // Remplacez par le chemin de votre première icône
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
                  title: const Text("R E S E R V A T I O N S"),
                  leading: Image.asset(
                    'assets/images/icone4.png', // Remplacez par le chemin de votre troisième icône
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
                  title: const Text("P R O F I L E"),
                  leading: Image.asset(
                    'assets/images/icone5.png', // Remplacez par le chemin de votre quatrième icône
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
              title: const Text("L O G O U T"),
              leading: const Icon(
                  Icons.logout), // Garder l'icône de déconnexion telle quelle
              onTap: logout,
            ),
          ),
        ],
      ),
    );
  }
}
