import 'package:chat1/models/message1.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService1 {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();

        return user;
      }).toList();
    });
  }

  Future<void> sendMessage(String receiverID1, message1) async {
    final String currentUserID1 = _auth.currentUser!.uid;
    final String currentUserEmail1 = _auth.currentUser!.email!;
    final Timestamp timestamp1 = Timestamp.now();
    Message1 newMessage = Message1(
      senderID1: currentUserID1,
      senderEmail1: currentUserID1,
      receiverID1: receiverID1,
      message1: message1,
      timestamp1: timestamp1,
    );
    List<String> ids = [currentUserID1, receiverID1];
    ids.sort();
    String chatRoomID = ids.join('_');
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userID1, otherUserID1) {
    List<String> ids = [userID1, otherUserID1];
    ids.sort();
    String chatRoomID = ids.join('_');
    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
