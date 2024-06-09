import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? uid;
  String? email;
  String? name;
  String? role;

  UserModel({this.uid, this.email, this.name, this.role});

  // Méthode pour créer un UserModel à partir d'un document Firebase
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String?,
      name: data['name'] as String?,
      role: data['role'] as String?,
    );
  }

  // Méthode pour convertir le UserModel en Map pour l'envoi à Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
    };
  }
}
