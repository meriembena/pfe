import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Saydaliati/views/discussions.dart';
import 'package:Saydaliati/models/UserModel.dart';
import 'package:Saydaliati/views/Categories.dart';

class AuthService {
//initialiser d'une instance pour accéder aux fonctionalités de firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //initialiser d'une instance pour accéder aux fonctionalités d'authentification de firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;

//getCurrentUser() est conçue pour récupérer l'utilisateur
//actuellement connecté dans notre application utilisant Firebase Auth.
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Ajout d'une méthode pour obtenir l'adresse email de l'utilisateur actuel.
  String? currentUserEmail() {
    return _auth.currentUser?.email;
  }

  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    try {
//Cette méthode renvoie un objet UserCredential qui contient les informations de l'utilisateur authentifié.
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Supprimez ou commentez cette partie pour éviter la mise à jour de Firestore
      /*
    _firestore.collection("Users").doc(userCredential.user!.uid).set({
      'uid': userCredential.user!.uid,
      'email': email,
    }, SetOptions(merge: true));
    */

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<UserCredential> signUpWithEmailPassword(String email, String password,
      String name, String role, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        role: role,
      );
      await _firestore
          .collection("Users")
          .doc(userCredential.user!.uid)
          .set(newUser.toMap());

      // Redirection en fonction du rôle
      if (role == 'chercheur') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => categories()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => discussions()),
        );
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> changePassword(String newPassword) async {
//récuperer l'utilisateur actuellement connecté
    User? currentUser = _auth.currentUser;
    try {
      //mettre à jour le mot de passe de l'utilisateur
      await currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }
}
