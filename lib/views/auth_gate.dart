import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Saydaliati/views/discussions.dart';
import 'package:Saydaliati/views/loginorregister_page.dart';

//c'est a dire authgate est statique et ne change pas
// une classe parmis les class de l'interface messagerie
class AuthGate extends StatelessWidget {
  //declaration de role
  final String role;
// maintenir l'état des widgets et d'optimiser les performances lors de modifications
  const AuthGate({Key? key, required this.role}) : super(key: key);

  @override
  // build est responsable de la création et la mis à jour de l'interface utilisateur
  Widget build(BuildContext context) {
    //utilise StreamBuilder pour créer une interface utilisateur qui réagit en temps
    // réel aux changements de l'état de connexion de l'utilisateur grâce à Firebase
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      //La fonction builder utilise snapshot.hasData pour décider quelle interface utilisateur afficher
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
                // verifier si les données sont non null
                if (userSnapshot.data != null &&
                    userSnapshot.data!.data() != null) {
                  Map<String, dynamic> userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  if (userData['role'] == role) {
                    // Si le rôle correspond, aller à discussions
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
