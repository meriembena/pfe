import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Saydaliati/models/message.dart';

class ChatService {
  // instance pour accéder aux fonctionnalités de firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // instance pour accéder aux fonctionnalités d'authentfication de firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //crée un flux qui surveille la collection "Users"
  //dans Firestore et les tranforme les documents de la collection en une liste de cartes .
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> sendMessage(String receiverID, String message) async {
    //récupérer l'id de l'utilisateur actuellement connecté s'il n'est pas connecté l'id est une chaine vide.
    final String currentUserID = _auth.currentUser?.uid ?? '';
    final String currentUserEmail = _auth.currentUser?.email ?? '';
    final Timestamp timestamp = Timestamp.now();

    if (currentUserID.isEmpty || currentUserEmail.isEmpty) {
      throw Exception('ID utilisateur actuel ou email est nul.');
    }

    Message1 newMessage = Message1(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );
//Cette ligne crée une liste contenant les ID de l'utilisateur actuel et de l'utilisateur destinataire
    List<String> ids = [currentUserID, receiverID];
    //Cette instruction trie les ID dans la liste qui ont le même id de chatroom
    ids.sort();
    //les ID sont joints ensemble avec(_) pour former un identifiant unique pour la chatroom.
    String chatRoomID = ids.join('_');
    //
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

//getMessages est conçue pour récupérer un flux continu de messages entre deux utilisateurs spécifiques
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

  Future<String> obtenirDernierMessageBot() async {
    try {
      final QuerySnapshot messagesBot = await _firestore
          .collection('messages')
          //récupérer uniquement le message est envoyé par un chatbot, et non par un utilisateur.
          .where('isUserMessage', isEqualTo: false)
          //Trie les messages pour que le message le plus récent sera le premier.
          .orderBy('timestamp', descending: true)
          //recupère le message le plus récent
          .limit(1)
          .get();
//Ce code vérifie la disponibilité des messages de chatbot, retourne le texte du premier message.
      if (messagesBot.docs.isNotEmpty) {
        final data = messagesBot.docs.first.data() as Map<String, dynamic>;
        return data['text'] as String? ?? 'Aucun message trouvé';
      }
      //lance une exception s'il n'y a aucun message
      else {
        throw Exception('Aucun message de bot trouvé');
      }
    } catch (e) {
      print("Error fetching bot message: $e");
      return 'Erreur lors de la récupération du message de bot';
    }
  }
}
