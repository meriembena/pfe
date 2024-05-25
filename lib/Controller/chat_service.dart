import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> sendMessage(String receiverID, String message) async {
    final String currentUserID = _auth.currentUser?.uid ?? '';
    final String currentUserEmail = _auth.currentUser?.email ?? '';
    final Timestamp timestamp = Timestamp.now();

    if (currentUserID.isEmpty || currentUserEmail.isEmpty) {
      throw Exception('Current user ID or email is null');
    }

    Map<String, dynamic> newMessage = {
      'senderID': currentUserID,
      'senderEmail': currentUserEmail,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp,
    };

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage);
  }

  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');
    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  Future<String?> getDeviceTokenForUser(String userID) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(userID).get();
      return (userDoc.data() as Map<String, dynamic>?)?['token'] as String?;
    } catch (e) {
      print("Failed to fetch user token: $e");
      return null;
    }
  }

  Future<String> obtenirDernierMessageBot() async {
    try {
      final QuerySnapshot messagesBot = await _firestore
          .collection('messages')
          .where('isUserMessage', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (messagesBot.docs.isNotEmpty) {
        final data = messagesBot.docs.first.data() as Map<String, dynamic>;
        return data['text'] as String? ?? 'Aucun message trouvé';
      } else {
        throw Exception('Aucun message de bot trouvé');
      }
    } catch (e) {
      print("Error fetching bot message: $e");
      return 'Erreur lors de la récupération du message de bot';
    }
  }
}
