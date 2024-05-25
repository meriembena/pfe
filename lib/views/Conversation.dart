import 'package:chat1/views/Widgets/chat_bubble.dart';
import 'package:chat1/Controller/auth_service.dart';
import 'package:chat1/Controller/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Conversation extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;
  final String? selectedGouvernorat;
  final String? selectedDelegation;
  final bool isNight;

  Conversation({
    Key? key,
    required this.receiverEmail,
    required this.receiverID,
    this.selectedGouvernorat,
    this.selectedDelegation,
    this.isNight = false,
  }) : super(key: key);

  @override
  State<Conversation> createState() => _ChatPageState();
}

class _ChatPageState extends State<Conversation> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  FocusNode myFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });
    Future.delayed(
      const Duration(milliseconds: 500),
      () => scrollDown(),
    );
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverID, _messageController.text);
      _messageController.clear();
    }
    scrollDown();
  }

  Future<void> recordReservation(
      String receiverEmail, BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    String? currentUserEmail = user?.email;
    if (currentUserEmail != null) {
      await FirebaseFirestore.instance.collection('réservations').add({
        'to': receiverEmail,
        'notification': {'title': 'Reservation', 'made by': currentUserEmail},
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
      print('Reservation recorded successfully.');
    } else {
      print("Current user email not found.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double cmToPx =
        MediaQuery.of(context).devicePixelRatio * 0.393701; // 1 cm en pixels

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                width: screenWidth,
                height: screenHeight, // Utiliser toute la hauteur de l'écran
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/back.jpg',
                        fit: BoxFit.cover, // L'image couvre toute la surface
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
                                'assets/images/Groupe 27.png', // Remplacez par le chemin de votre image de retour
                                width: screenWidth * 0.09,
                              ),
                            ),
                            Text(
                              widget.receiverEmail,
                              style: TextStyle(
                                fontSize: 12, // Taille de police réduite
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              width:
                                  120.0, // Espacement pour équilibrer la mise en page
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: -0.9, // Position X relative
                      top: screenHeight * 0.2, // Position Y relative
                      child: Image.asset(
                        'assets/images/icons8-bulle-de-conversation-avec-points-96.png',
                        width: screenWidth, // Largeur égale à l'écran
                        height: cmToPx, // Hauteur de 1 cm
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
                            Expanded(
                              child: _buildMessageList(),
                            ),
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
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading...");
        }
        return ListView(
          controller: _scrollController,
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      margin: const EdgeInsets.symmetric(
          vertical: 10.0, horizontal: 10.0), // Ajout des marges
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(
            message: data["message"],
            isCurrentUser: isCurrentUser,
          ),
          if (!isCurrentUser && data["message"].contains("disponible"))
            ElevatedButton(
              child: const Text('Reserver'),
              onPressed: () => recordReservation(widget.receiverEmail, context),
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
                focusNode: myFocusNode,
                decoration: InputDecoration(
                  hintText: 'Entrez un message',
                  border:
                      InputBorder.none, // Remove the default TextField border
                ),
              ),
            ),
          ),
          SizedBox(width: 3), // Espace entre le champ de texte et l'icône
          IconButton(
            icon: Image.asset(
                'assets/images/icons8-envoyé-100.png'), // Remplacez par le chemin de votre image d'envoi
            onPressed: sendMessage,
          ),
        ],
      ),
    );
  }
}
