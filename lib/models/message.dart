import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class Message1 {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  final Timestamp timestamp;
  //le mot required indiquant que ces paramètres sont obligatoires lors de la
  //création d'une instance de Message1.
  Message1({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.timestamp,
  });
  //La méthode toMap() permet de convertir une instance de Message1 en un
  //objet Map<String, dynamic>,pour envoyer des données à une base de données
  //qui attend des données sous forme de dictionnaire ou de JSON.
  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp,
    };
  }
}

class Message {
  final bool isUserMessage;
  final String text;
  final File? imageFile;
  final Timestamp timestamp;

  Message(
      {required this.isUserMessage,
      required this.text,
      this.imageFile,
      required this.timestamp});

  Map<String, dynamic> toJson() {
    return {
      'isUserMessage': isUserMessage,
      'text': text,
      'timestamp': timestamp,
      'imageFile': imageFile?.path
    };
  }
}
