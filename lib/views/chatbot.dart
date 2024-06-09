import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:Saydaliati/models/message.dart';
import 'package:Saydaliati/views/discussions.dart';

//c'est a dire chatbotApp est statique et ne change pas
class ChatbotScreen extends StatefulWidget {
  final String nomPharmacie;

  const ChatbotScreen(this.nomPharmacie);

  @override
  //construire le widget ChatbotScreenState, il appelle
//createState(). Cette méthode retourne une instance de _ChatbotScreenState,
//qui contient tout l'état nécessaire
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

////Contient et gère l'état dynamique du widget,
///construire l'interface utilisateur en réponse aux interactions de l'utilisateur.
class _ChatbotScreenState extends State<ChatbotScreen> {
  //utilisé dans Flutter pour gérer le contenu d'un champ de texte
  TextEditingController _textController = TextEditingController();
  //initialise une liste vide "Message"
  List<Message> _messages = [];
  String? userAge;
  String? userAllergies;
  String? userMedications;
  String? extractedText;

  @override
  //C'est l'endroit où vous pouvez insérer le code d'initialisation qui doit s'exécuter une seule fois
  void initState() {
    super.initState();
    //instance de la classe 'Message' qui représente un message qui sera affiché par le chatbot
    Message welcomeMessage = Message(
      //le message ne provient pas de l'utilisateur mais du chatbot
      isUserMessage: false,
      text:
          "Bonjour! Bienvenue chez pharmacie ${widget.nomPharmacie}, s'il vous plaît entrer l'ordonnance",
      timestamp: Timestamp.now(),
    );
    _addMessage(welcomeMessage);
  }

// ajouter un message dans l'interface
  void _addMessage(Message message) {
    // utilisé notifie Flutter que l'état interne de l'objet a changé
    setState(() {
      _messages.add(message);
    });
    FirebaseFirestore.instance.collection('messages').add(message.toJson());
    print("Message ajouté : ${message.text}");
  }

  Future<void> _sendMessage(String messageText) async {
    if (messageText.isEmpty) return;

    print("Envoi du message : $messageText");
// le message envoyé par le chercheur
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
    //ajouter le message du bot à la liste des messages affichés
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
      //lit le fichier d'image situé à imagePath en tant que liste d'octets de manière asynchrone.
      List<int> imageBytes = await File(imagePath).readAsBytes();
      //encode les octets de l'image en une chaîne de caractères au format Base64
      String base64Image = base64Encode(imageBytes);
//envoie une requête POST asynchrone à l'URL spécifiée
      final response = await http.post(
        Uri.parse('https://4037-197-244-199-235.ngrok-free.app/upload_image'),
        body: {'image': base64Image},
      );

      if (response.statusCode == 200) {
        //stocke le texte extrait de l'image
        extractedText = response.body;
        //création d'un objet File représentant l'image à partir du chemin d'accès.
        File imageFile = File(imagePath);
//création d'une instance de la classe Message représentant
// le message du bot contenant l'image et le texte extrait
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

//sélectionner des images à partir de différentes sources, comme la galerie ou l'appareil photo.
  void _openImagePicker(ImageSource source) async {
    final picker = ImagePicker();
    //retourne un PickedFile représentant l'image sélectionnée.
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      // envoie l'image au serveur et ajoute l'image et le
      // texte extrait à la liste des messages affichés par le chatbot.
      _sendImage(pickedFile.path);
    }
  }

  @override
  // build est responsable de la création et la mis à jour de l'interface utilisateur
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Scaffold widget est prédéfini par Flutter.
    return Scaffold(
      ////garantir que le contenu de l'application est toujours visible et accessible.
      body: SafeArea(
        //permet de faire défiler un seul widget enfant qui pourrait dépasser les dimensions de l'écran
        child: SingleChildScrollView(
          child: Container(
            height: screenHeight,
            //le widget Stack permet de superposer plusieurs widgets les uns sur les autres.
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
                    height: 1,
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
                          //permet de construire une liste d'éléments à la demande
                          child: ListView.builder(
                            //définit le nombre d'éléments dans la liste
                            itemCount: _messages.length,
                            // construire chaque élément de la liste
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
                                      //décoration du message de chatbot
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
                                      //décoration du message de l'utilisateur
                                      if (message.isUserMessage)
                                        Flexible(
                                          child: Container(
                                            width: screenWidth * 0.5,
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              message.text,
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (isLastMessage &&
                                          !message.isUserMessage)
                                        GestureDetector(
                                          onTap: () async {
                                            final String
                                                //supprime les espaces de début
                                                //et de fin du nom de la pharmacie et le stocke dans une variable normalizedPharmacyName.
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
