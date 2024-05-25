import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:chat1/models/message.dart';
import 'package:chat1/views/discussions.dart';

class ChatbotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatbot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatbotScreen('Nom de la pharmacie'),
    );
  }
}

class ChatbotScreen extends StatefulWidget {
  final String nomPharmacie;

  const ChatbotScreen(this.nomPharmacie);

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  TextEditingController _textController = TextEditingController();
  List<Message> _messages = [];
  String? userAge;
  String? userAllergies;
  String? userMedications;
  String? extractedText;

  @override
  void initState() {
    super.initState();
    Message welcomeMessage = Message(
      isUserMessage: false,
      text:
          "Bonjour! Bienvenue chez pharmacie ${widget.nomPharmacie}, s'il vous plaît entrer l'ordonnance",
      timestamp: Timestamp.now(),
    );
    _addMessage(welcomeMessage);
  }

  void _addMessage(Message message) {
    setState(() {
      _messages.add(message);
    });
    FirebaseFirestore.instance.collection('messages').add(message.toJson());
    print("Message ajouté : ${message.text}");
  }

  Future<void> _sendMessage(String messageText) async {
    if (messageText.isEmpty) return;

    print("Envoi du message : $messageText");

    Message userMessage = Message(
      isUserMessage: true,
      text: messageText,
      timestamp: Timestamp.now(),
    );
    _addMessage(userMessage);

    if (_messages.isNotEmpty) {
      String lastBotMessage =
          _messages.where((msg) => !msg.isUserMessage).last.text;

      if (lastBotMessage == "Quelle est votre âge?") {
        userAge = messageText;
        _askAllergies();
      } else if (lastBotMessage ==
          "Avez-vous des allergies ou des maladies chroniques ?") {
        userAllergies = messageText;
        _askMedications();
      } else if (lastBotMessage ==
          "Voulez-vous acheter tous les médicaments ou bien quelques-uns ? Si quelques-uns, indiquez-les.") {
        userMedications = messageText;
        _sendFinalSummary();
      } else {
        // Envoyer le message texte au serveur
        print("Message texte envoyé au serveur : $messageText");
      }
    }
  }

  void _askAllergies() {
    Message allergiesQuery = Message(
      isUserMessage: false,
      text: "Avez-vous des allergies ou des maladies chroniques ?",
      timestamp: Timestamp.now(),
    );
    _addMessage(allergiesQuery);
  }

  void _askMedications() {
    Message medicationsQuery = Message(
      isUserMessage: false,
      text:
          "Voulez-vous acheter tous les médicaments ou bien quelques-uns ? Si quelques-uns, indiquez-les.",
      timestamp: Timestamp.now(),
    );
    _addMessage(medicationsQuery);
  }

  void _sendFinalSummary() {
    String summary = "Texte extrait de l'ordonnance: $extractedText\n\n"
        "Âge: $userAge\n"
        "Allergies et maladies chroniques: $userAllergies\n"
        "Médicaments à acheter: $userMedications";
    Message summaryMessage = Message(
      isUserMessage: false,
      text: summary,
      timestamp: Timestamp.now(),
    );
    _addMessage(summaryMessage);
  }

  void _sendImage(String imagePath) async {
    try {
      List<int> imageBytes = await File(imagePath).readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse('https://269a-197-0-47-29.ngrok-free.app/upload_image'),
        body: {'image': base64Image},
      );

      if (response.statusCode == 200) {
        extractedText = response.body;
        File imageFile = File(imagePath);

        Message imageMessage = Message(
          isUserMessage: false,
          imageFile: imageFile,
          text: extractedText!,
          timestamp: Timestamp.now(),
        );
        _addMessage(imageMessage);

        // Ajouter un message demandant l'âge de l'utilisateur
        Message ageQuery = Message(
          isUserMessage: false,
          text: "Quelle est votre âge?",
          timestamp: Timestamp.now(),
        );
        _addMessage(ageQuery);
      } else {
        print(
            'Erreur lors de l\'envoi de l\'image au serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de l\'envoi de l\'image: $e');
    }
  }

  void _openImagePicker(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      _sendImage(pickedFile.path);
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
          // Englobez tout dans un SingleChildScrollView
          child: Container(
            height:
                screenHeight, // Assurez-vous que le container prend toute la hauteur de l'écran
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
                            width: screenWidth * 0.12,
                            height: screenHeight * 0.15,
                          ),
                        ),
                        Text(
                          'Chat',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          width: 230,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: screenHeight * 0.002,
                  child: Image.asset(
                    'assets/images/icons8-bulle-de-conversation-avec-points-96.png',
                    width: screenWidth,
                    height: cmToPx,
                  ),
                ),
                Positioned(
                  left: screenWidth * 0.032,
                  top: screenHeight * 0.09,
                  child: Container(
                    width: screenWidth * 0.95,
                    height: screenHeight * 0.85,
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              Message message = _messages[index];
                              bool isLastMessage =
                                  index == _messages.length - 1;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                child: Align(
                                  alignment: message.isUserMessage
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (!message.isUserMessage)
                                        Flexible(
                                          child: Container(
                                            width: screenWidth * 0.75,
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Color(0x353c40)
                                                  .withOpacity(0.7),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (message.imageFile != null)
                                                  Container(
                                                    width: 200,
                                                    height: 100,
                                                    child: Image.file(
                                                      message.imageFile!,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                Text(
                                                  message.text,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      if (message.isUserMessage)
                                        Flexible(
                                          child: Container(
                                            width: screenWidth *
                                                0.5, // Réduire la largeur de la boîte de message de l'utilisateur
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors
                                                  .white, // Couleur de fond blanche pour les messages de l'utilisateur
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              message.text,
                                              style: TextStyle(
                                                color: Colors
                                                    .black, // Texte noir pour les messages de l'utilisateur
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (isLastMessage &&
                                          !message.isUserMessage)
                                        GestureDetector(
                                          onTap: () async {
                                            final String
                                                normalizedPharmacyName =
                                                widget.nomPharmacie.trim();

                                            var usersSnapshot =
                                                await FirebaseFirestore.instance
                                                    .collection('Users')
                                                    .get();

                                            for (var doc
                                                in usersSnapshot.docs) {
                                              var userEmail =
                                                  doc.data()['email'] as String;
                                              var emailPrefix =
                                                  userEmail.split('@').first;
                                              if (emailPrefix ==
                                                  normalizedPharmacyName) {
                                                discussions()
                                                    .envoyerMessageAUnUtilisateur(
                                                        userEmail, context);
                                                return;
                                              }
                                            }

                                            print(
                                                "Aucune correspondance d'email trouvée pour la pharmacie");
                                          },
                                          child: Image.asset(
                                            'assets/images/icons8-transférer-60.png',
                                            width: 24,
                                            height: 24,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _textController,
                                  decoration: InputDecoration(
                                    hintText: 'Entrez votre message ici',
                                  ),
                                ),
                              ),
                              SizedBox(width: 1),
                              IconButton(
                                icon: Image.asset(
                                    'assets/images/icons8-photo-100.png'),
                                onPressed: () =>
                                    _openImagePicker(ImageSource.camera),
                              ),
                              SizedBox(width: 1),
                              IconButton(
                                icon: Image.asset(
                                    'assets/images/icons8-photo-64.png'),
                                onPressed: () =>
                                    _openImagePicker(ImageSource.gallery),
                              ),
                              SizedBox(width: 0),
                              IconButton(
                                icon: Image.asset(
                                    'assets/images/icons8-envoyé-100.png'),
                                onPressed: () {
                                  if (_textController.text.isNotEmpty) {
                                    _sendMessage(_textController.text);
                                    _textController.clear();
                                  }
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
