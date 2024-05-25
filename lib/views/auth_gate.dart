import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat1/views/discussions.dart';
import 'package:chat1/views/loginorregister_page.dart';

// une classe parmis les class de l'interface messagerie
class AuthGate extends StatelessWidget {
  final String role;

  const AuthGate({Key? key, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Un utilisateur veux connecter, on va obtenir ses données pour vérifier son rôle
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('Users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.done) {
                // Modification ici pour éviter le cast direct
                if (userSnapshot.data != null &&
                    userSnapshot.data!.data() != null) {
                  Map<String, dynamic> userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  if (userData['role'] == role) {
                    // Si le rôle correspond, aller à HomePage
                    return discussions();
                  } else {
                    // Si le rôle ne correspond pas, déconnecter et aller à LoginOrRegister
                    FirebaseAuth.instance.signOut();
                    return LoginOrRegister(role: role);
                  }
                } else {
                  // Les données utilisateur ne sont pas trouvées, aller à LoginOrRegister
                  return LoginOrRegister(role: role);
                }
              } else if (userSnapshot.connectionState ==
                  ConnectionState.waiting) {
                // En attente des données utilisateur
                return Center(child: CircularProgressIndicator());
              } else {
                // Erreur lors de la récupération des données utilisateur, aller à LoginOrRegister
                return LoginOrRegister(role: role);
              }
            },
          );
        } else {
          // Aucun utilisateur connecté, aller à LoginOrRegister
          return LoginOrRegister(role: role);
        }
      },
    );
  }
}
