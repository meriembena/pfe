import 'package:Saydaliati/views/Widgets/chat_bubble.dart';
import 'package:Saydaliati/Controller/auth_service.dart';
import 'package:Saydaliati/Controller/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// cette classe est dynamique change d'etat
class conversation extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;
  final String? selectedGouvernorat;
  final String? selectedDelegation;
  final bool isNight;
// maintenir l'état des widgets et d'optimiser les performances lors de modifications
  conversation({
    Key? key,
    required this.receiverEmail,
    required this.receiverID,
    this.selectedGouvernorat,
    this.selectedDelegation,
    this.isNight = false,
  }) : super(key: key);

  @override
  //construire le widget ChatbotScreenState, il appelle
//createState(). Cette méthode retourne une instance de _conversationState,
//qui contient tout l'état nécessaire
  State<conversation> createState() => _conversationState();
}

class _conversationState extends State<conversation> {
  //utilisé dans Flutter pour gérer le contenu d'un champ de texte
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();

  void scrollDown() {
    //Cette méthode anime le défilement jusqu'à une position spécifique
    _scrollController.animateTo(
      //Cette propriété donne la position maximale de défilement(la fin de la liste.)
      _scrollController.position.maxScrollExtent,
      //La durée de l'animation est de 1 seconde
      duration: const Duration(seconds: 1),
      //utilisée pour rendre le défilement plus fluide
      curve: Curves.fastOutSlowIn,
    );
  }

  void sendMessage() async {
    //vérifie si le champ de texte n'est pas vide avant d'envoyer le message
    if (_messageController.text.isNotEmpty) {
      //une méthode qui envoie le message
      await _chatService.sendMessage(
          widget.receiverID, _messageController.text);
      //efface le contenu du champ de texte après que le message a été envoyé
      _messageController.clear();
    }
    //appelle la méthode pour faire défiler la liste des messages vers le bas
    scrollDown();
  }

  Future<void> recordReservation(
      String receiverEmail, BuildContext context) async {
    //obtient l'utilisateur actuellement connecté.
    User? user = FirebaseAuth.instance.currentUser;
    //extrait l'email de l'utilisateur, si disponible.
    String? currentUserEmail = user?.email;
    if (currentUserEmail != null) {
      await FirebaseFirestore.instance.collection('réservations').add({
        'to': receiverEmail,
        'title': 'Reservation',
        'made by': currentUserEmail,
        'timestamp': FieldValue.serverTimestamp(),
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirmation"),
            content: const Text(
                "Votre réservation sera confirmée en appelant la pharmacie."),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      print('Réservation enregistrée avec succès');
    } else {
      print("Adresse e-mail de l'utilisateur actuel introuvable");
    }
  }

  @override
  // build est responsable de la création et la mis à jour de l'interface utilisateur
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
// Scaffold widget est prédéfini par Flutter.
    return Scaffold(
      //garantir que le contenu de l'application est toujours visible et accessible.
      body: SafeArea(
        //permet de faire défiler un seul widget enfant qui pourrait dépasser les dimensions de l'écran
        child: SingleChildScrollView(
          //le widget Stack permet de superposer plusieurs widgets les uns sur les autres.
          child: Stack(
            children: [
              Container(
                width: screenWidth,
                height: screenHeight,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/back.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      left: screenWidth * 0,
                      top: screenHeight * -0.04,
                      child: Container(
                        width: screenWidth * 1,
                        height: screenHeight * 0.1,
                        margin: EdgeInsets.symmetric(vertical: 20.0),
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Image.asset(
                                'assets/images/Groupe 27.png',
                                width: screenWidth * 0.09,
                              ),
                            ),
                            Text(
                              widget.receiverEmail,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              width: 120.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: -0.9,
                      top: screenHeight * 0.2,
                      child: Image.asset(
                        'assets/images/icons8-bulle-de-conversation-avec-points-96.png',
                        width: screenWidth,
                        height: 1,
                      ),
                    ),
                    Positioned(
                      left: screenWidth * -0.09,
                      top: screenHeight * 0.12,
                      child: Container(
                        width: screenWidth * 1.2,
                        height: screenHeight * 0.83,
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            //utilisé pour occuper tout l'espace disponible
                            Expanded(
                              child: _buildMessageList(),
                            ),
                            //retourne le widget qui permet à l'utilisateur de saisir des messages.
                            _buildUserInput(screenWidth, screenHeight),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    //obtient l'ID de l'utilisateur actuellement connecté à partir _authService
    String senderID = _authService.getCurrentUser()!.uid;
    //écoute un flux de données
    return StreamBuilder<QuerySnapshot>(
      //les messages échangés entre l'utilisateur actuel et le destinataire
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading...");
        }
        //construire un ListView pour afficher les messages
        return ListView(
          controller: _scrollController,
          //Transforme chaque document en un widget de message
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    //convertit les données du document Firestore en un map
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    //Cette ligne vérifie si senderID correspond à l'ID de l'utilisateur actuellement connecté.
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;
    //Cette ligne détermine l'alignement du message (droite pour l'utilisateur actuel, gauche pour les autres).
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      margin: const EdgeInsets.symmetric(
          vertical: 10.0, horizontal: 10.0), // Ajout des marges
      child: Column(
        //Aligne les éléments à gauche ou à droite en fonction de l'expéditeur du message.
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          //Affiche le message à l'intérieur d'une bulle de chat
          ChatBubble(
            message: data["message"],
            isCurrentUser: isCurrentUser,
          ),
          if (!isCurrentUser && data["message"].contains("disponible"))
            ElevatedButton(
              onPressed: () => recordReservation(widget.receiverEmail, context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.grey,
                backgroundColor: Colors.white,
              ),
              child: const Text('Reserver'),
            ),
        ],
      ),
    );
  }

  Widget _buildUserInput(double screenWidth, double screenHeight) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              width: screenWidth * 0.2,
              height: screenHeight * 0.06,
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Entrez un message',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 3),
          IconButton(
            icon: Image.asset('assets/images/icons8-envoyé-100.png'),
            onPressed: sendMessage,
          ),
        ],
      ),
    );
  }
}
