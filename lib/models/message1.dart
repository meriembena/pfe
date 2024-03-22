import 'package:cloud_firestore/cloud_firestore.dart';

class Message1 {
  final String senderID1;
  final String senderEmail1;
  final String receiverID1;
  final String message1;
  final Timestamp timestamp1;
  Message1({
    required this.senderID1,
    required this.senderEmail1,
    required this.receiverID1,
    required this.message1,
    required this.timestamp1,
  });
  Map<String, dynamic> toMap() {
    return {
      'senderID1': senderID1,
      'senderEmail1': senderEmail1,
      'receiverID1': receiverID1,
      'message1': message1,
      'timestamp1': timestamp1,
    };
  }
}
