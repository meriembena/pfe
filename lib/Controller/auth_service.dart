import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat1/views/discussions.dart';
import 'package:chat1/views/Catégories.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Adding method to get current user's email
  String? currentUserEmail() {
    return _auth.currentUser?.email;
  }

  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _firestore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      }, SetOptions(merge: true));
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
      await _firestore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'role': role,
      });
      // Vérifier le rôle avant de décider où rediriger l'utilisateur
      if (role == 'chercheur') {
        // Si le rôle est chercheur, rediriger vers MyApp1
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Categories()),
        );
      } else {
        // Si le rôle est autre, rediriger vers HomePage ou une autre page appropriée
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
    User? currentUser = _auth.currentUser;
    try {
      await currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }
}
