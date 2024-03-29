import 'package:cloud_firestore/cloud_firestore.dart';

class Message1 {
  final String senderIDi;
  final String senderEmaili;
  final String receiverIDi;
  final String messagei;
  final Timestamp timestampi;
  Message1({
    required this.senderIDi,
    required this.senderEmaili,
    required this.receiverIDi,
    required this.messagei,
    required this.timestampi,
  });
  Map<String, dynamic> toMap() {
    return {
      'senderID': senderIDi,
      'senderEmail': senderEmaili,
      'receiverID': receiverIDi,
      'message': messagei,
      'timestamp': timestampi,
    };
  }
}
