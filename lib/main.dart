import 'package:chat1/services/auth/auth_gate.dart';
import 'package:chat1/services/auth/auth_gate1.dart';
import 'package:chat1/services/auth/login_or_register1.dart';
import 'package:chat1/services/pages/login_page1.dart';
import 'package:chat1/themes/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => Racine(),
        '/myapp1': (context) => MyApp1(),
      },
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}

class Racine extends StatelessWidget {
  String errorMessage = '';

  Future<void> signIn(BuildContext context) async {
    try {
      // Votre logique de connexion ici
    } catch (error) {
      // Gestion des erreurs de connexion
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black, // Fond noir
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20), // Ajustez la taille selon vos besoins
                Image.asset('images/8.jpg'), // Ajout de l'image '8.jpg'
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // Naviguer vers la page d'authentification
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginOrRegister1()),
                    );
                  },
                  child: Text('Je suis un chercheur'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // Naviguer vers la page d'authentification
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AuthGate()),
                    );
                  },
                  child: Text('Je suis un pharmacien'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp1 extends StatefulWidget {
  @override
  _MyApp1State createState() => _MyApp1State();
}

class _MyApp1State extends State<MyApp1> {
  bool isPharmacieDeGardeSelected = false;
  bool isPharmacieDeNuitSelected = false;
  bool isPharmacieDeJourSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                'MonPharmacie',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            CheckboxListTile(
              title: Text(
                'Pharmacie de garde',
                style: TextStyle(color: Colors.black),
              ),
              value: isPharmacieDeGardeSelected,
              onChanged: (value) {
                setState(() {
                  isPharmacieDeGardeSelected = value!;
                  // Réinitialiser l'état de l'autre option
                  if (value!) {
                    isPharmacieDeNuitSelected = false;
                    isPharmacieDeJourSelected = false;
                  }
                });
              },
            ),
            CheckboxListTile(
              title: Text(
                'Pharmacie de jour',
                style: TextStyle(color: Colors.black),
              ),
              value: isPharmacieDeJourSelected,
              onChanged: (value) {
                setState(() {
                  isPharmacieDeJourSelected = value!;
                  // Réinitialiser l'état de l'autre option
                  if (value!) {
                    isPharmacieDeGardeSelected = false;
                    isPharmacieDeNuitSelected = false;
                  }
                });
              },
            ),
            CheckboxListTile(
              title: Text(
                'Pharmacie de nuit',
                style: TextStyle(color: Colors.black),
              ),
              value: isPharmacieDeNuitSelected,
              onChanged: (value) {
                setState(() {
                  isPharmacieDeNuitSelected = value!;
                  // Réinitialiser l'état de l'autre option
                  if (value!) {
                    isPharmacieDeGardeSelected = false;
                    isPharmacieDeJourSelected = false;
                  }
                });
              },
            ),
            SizedBox(height: 20),
            // Bouton lié à la navigation vers MyApp3
            if (isPharmacieDeGardeSelected ||
                isPharmacieDeNuitSelected ||
                isPharmacieDeJourSelected)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyApp3(
                        isPharmacieDeGardeSelected: isPharmacieDeGardeSelected,
                        isPharmacieDeNuitSelected: isPharmacieDeNuitSelected,
                        isPharmacieDeJourSelected: isPharmacieDeJourSelected,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Préciser votre localisation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MyApplication extends StatefulWidget {
  const MyApplication({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApplication> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
        ),
      ),
    );
  }
}

class MyApp3 extends StatefulWidget {
  final bool isPharmacieDeGardeSelected;
  final bool isPharmacieDeNuitSelected;
  final bool isPharmacieDeJourSelected;

  MyApp3({
    required this.isPharmacieDeGardeSelected,
    required this.isPharmacieDeNuitSelected,
    required this.isPharmacieDeJourSelected,
  });

  @override
  _MyApp3State createState() => _MyApp3State();
}

class _MyApp3State extends State<MyApp3> {
  String? selectedGouvernorat;
  String? selectedDelegation;
  late List<String> gouvernorats = [];
  late Map<String, List<String>> delegations = {};

  @override
  void initState() {
    super.initState();
    chargerDonnees();
  }

  Future<void> chargerDonnees() async {
    String data = await DefaultAssetBundle.of(context)
        .loadString('images/villes_regions.json');
    Map<String, dynamic> jsonData = json.decode(data);

    setState(() {
      gouvernorats =
          List<String>.from(jsonData['gouvernorats'].map((g) => g['nom']));
      for (var gouvernorat in jsonData['gouvernorats']) {
        delegations[gouvernorat['nom']] =
            List<String>.from(gouvernorat['délégations']);
      }
      selectedGouvernorat = gouvernorats.isNotEmpty ? gouvernorats.first : null;
      selectedDelegation = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sélectionnez'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
              isExpanded: true,
              value: selectedGouvernorat,
              onChanged: (newValue) {
                setState(() {
                  selectedGouvernorat = newValue;
                  selectedDelegation = null;
                });
              },
              items: gouvernorats.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(fontSize: 18.0),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            if (selectedGouvernorat != null)
              DropdownButton<String>(
                isExpanded: true,
                value: selectedDelegation,
                onChanged: (newValue) {
                  setState(() {
                    selectedDelegation = newValue;
                  });
                },
                items: delegations[selectedGouvernorat!]!
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 18.0),
                    ),
                  );
                }).toList(),
              ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                _openGoogleMaps();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.black), // Couleur de fond noire
                foregroundColor: MaterialStateProperty.all<Color>(
                    Colors.white), // Couleur du texte blanc
              ),
              child: Text('Ouvrir la localisation'),
            ),
            SizedBox(height: 20),
            if (widget.isPharmacieDeGardeSelected ||
                widget.isPharmacieDeJourSelected)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListeScreen(
                        selectedGouvernorat: selectedGouvernorat,
                        selectedDelegation: selectedDelegation,
                      ),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.black), // Couleur de fond noire
                  foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white), // Couleur du texte blanc
                ),
                child: Text('Accéder à la liste'),
              ),
            if (!widget.isPharmacieDeGardeSelected &&
                !widget.isPharmacieDeJourSelected)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListeScreenn(
                        selectedGouvernorat: selectedGouvernorat,
                        selectedDelegation: selectedDelegation,
                      ),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.black), // Couleur de fond noire
                  foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white), // Couleur du texte blanc
                ),
                child: Text('Accéder à la Liste'),
              ),
          ],
        ),
      ),
    );
  }

  _openGoogleMaps() async {
    String type = widget.isPharmacieDeGardeSelected
        ? 'pharmacie de garde'
        : 'pharmacie de nuit';
    String query = '$type +${selectedGouvernorat}+${selectedDelegation}';
    query = query.replaceAll(' ', '+');
    final url = 'https://www.google.com/maps/search/?api=1&query=$query';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Impossible de lancer $url';
    }
  }
}

class CameraScreen extends StatefulWidget {
  final Function(String) onImageCaptured;

  const CameraScreen({Key? key, required this.onImageCaptured})
      : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prendre une photo'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (_controller != null && _controller.value.isInitialized) {
              return Stack(
                children: [
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width *
                          _controller.value.aspectRatio,
                      child: CameraPreview(_controller),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FloatingActionButton(
                        onPressed: () async {
                          try {
                            await _initializeControllerFuture;
                            final XFile file = await _controller.takePicture();
                            widget.onImageCaptured(file.path);
                          } catch (e) {
                            print('Error taking picture: $e');
                          }
                        },
                        child: Icon(Icons.camera),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Center(child: Text('Camera not available'));
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class DisplayImageScreen extends StatelessWidget {
  final String imagePath;

  DisplayImageScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Capturée'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.file(File(imagePath)),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle image sending
            },
            child: Text('Envoyer au Chatbot'),
          ),
        ],
      ),
    );
  }
}

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

  @override
  void initState() {
    super.initState();
    _addMessage(Message(
        isUserMessage: false,
        text:
            "Bonjour! Bienvenue chez pharmacie ${widget.nomPharmacie}, s'il vous plaît entrer l'ordonnance"));
  }

  Future<void> _sendMessage(String message) async {
    if (message.endsWith('.jpg') ||
        message.endsWith('.jpeg') ||
        message.endsWith('.png')) {
      _addMessage(Message(isUserMessage: true, text: message));
      _sendImage(message);
    } else {
      _addMessage(Message(isUserMessage: true, text: message));
      final response = await http.post(
        Uri.parse('https://ca83-102-158-254-248.ngrok-free.app/upload_image'),
        body: {'image': message},
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse is String) {
          // Split the jsonResponse into medication names and following words
          List<String> splitResponse = jsonResponse.split('|');
          String medicationNames = splitResponse[0];
          String followingWords = splitResponse[1];

          _addMessage(Message(
            isUserMessage: false,
            text:
                'Médicaments : $medicationNames\nMots suivant "Dr" ou "Docteur" : $followingWords',
          ));
        } else {
          _addMessage(Message(
            isUserMessage: false,
            text: 'Réponse invalide du serveur.',
          ));
        }
      } else {
        _addMessage(Message(
          isUserMessage: false,
          text: 'Erreur de communication avec le chatbot',
        ));
      }
    }
  }

  void _addMessage(Message message) {
    setState(() {
      _messages.add(message);
    });
  }

  void _sendImage(String imagePath) async {
    // Convertir l'image en bytes
    List<int> imageBytes = File(imagePath).readAsBytesSync();

    // Convertir les bytes en base64
    String base64Image = base64Encode(imageBytes);

    // Envoyer l'image au serveur
    final response = await http.post(
      Uri.parse('https://ca83-102-158-254-248.ngrok-free.app/upload_image'),
      body: {'image': base64Image},
    );

    if (response.statusCode == 200) {
      // Extraire le texte de la réponse du serveur
      String extractedText = response.body;

      // Charger l'image à partir du chemin
      File imageFile = File(imagePath);

      // Afficher l'image et le texte extrait dans l'interface utilisateur
      _addMessage(Message(isUserMessage: false, imageFile: imageFile));
      _addMessage(Message(isUserMessage: false, text: extractedText));
    } else {
      print('Erreur lors de l\'envoi de l\'image au serveur');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                Message message = _messages[index];
                return ListTile(
                  title: Align(
                    alignment: message.isUserMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            message.isUserMessage ? Colors.white : Colors.black,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (message.imageFile != null)
                            Image.file(
                              message.imageFile!,
                              width: 400,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          Text(
                            message.text,
                            style: TextStyle(
                              color: message.isUserMessage
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_messages.isNotEmpty && !_messages.last.isUserMessage)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.transfer_within_a_station,
                          color: Colors.black), // Icône de transfert
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AuthGate()), // Remplacez AuthGate par la classe que vous souhaitez naviguer
                        );
                      },
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.transfer_within_a_station,
                          color: Colors.black), // Icône de transfert
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AuthGate1()), // Remplacez AuthGate par la classe que vous souhaitez naviguer
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Entrez votre message ici',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.camera_alt, color: Colors.black),
                  onPressed: () {
                    _openImagePicker(ImageSource.camera);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.image, color: Colors.black),
                  onPressed: () {
                    _openImagePicker(ImageSource.gallery);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.black),
                  onPressed: () {
                    _sendMessage(_textController.text);
                    _textController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fonction pour ouvrir la galerie de photos et sélectionner une image
  void _openImagePicker(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: source);
    if (pickedFile != null) {
      _sendImage(pickedFile.path);
    }
  }
}

class Message {
  final bool isUserMessage;
  final String text;
  final File? imageFile;

  Message({required this.isUserMessage, this.text = '', this.imageFile});
}

// liste des pharmacies
//
//
class ListeScreen extends StatefulWidget {
  final String? selectedGouvernorat;
  final String? selectedDelegation;

  const ListeScreen(
      {Key? key, this.selectedGouvernorat, this.selectedDelegation})
      : super(key: key);

  @override
  State<ListeScreen> createState() => _ListeScreenState();
}

class _ListeScreenState extends State<ListeScreen> {
  late List<QueryDocumentSnapshot<Map<String, dynamic>>> data = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void didUpdateWidget(covariant ListeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    getData();
  }

  Future<void> getData() async {
    if (widget.selectedDelegation != null) {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection(widget.selectedDelegation!)
              .get();
      setState(() {
        data = querySnapshot.docs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des pharmacies'),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, i) {
          var pharmacieData = data[i].data();
          String phoneNumber = pharmacieData['tel'];
          return Card(
            child: ListTile(
              title: Text(
                "${pharmacieData['nomF']}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text("Adresse: ${pharmacieData['adresse']}"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _launchPhoneCall(phoneNumber);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        child: Text(
                          phoneNumber,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _openChatbot(context, pharmacieData['nomF']);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        child: Text(
                          "Chatbot",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openChatbot(BuildContext context, String nomPharmacie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatbotScreen(nomPharmacie),
      ),
    );
  }

// Méthode pour lancer un appel téléphonique
  void _launchPhoneCall(String phoneNumber) async {
    String telScheme = 'tel:$phoneNumber';
    if (await canLaunch(telScheme)) {
      await launch(telScheme);
    } else {
      throw 'Impossible de lancer l\'appel pour le numéro $phoneNumber';
    }
  }
}

class ListeScreenn extends StatefulWidget {
  final String? selectedGouvernorat;
  final String? selectedDelegation;

  const ListeScreenn(
      {Key? key, this.selectedGouvernorat, this.selectedDelegation})
      : super(key: key);

  @override
  _ListeScreennState createState() => _ListeScreennState();
}

class _ListeScreennState extends State<ListeScreenn> {
  late List<QueryDocumentSnapshot<Map<String, dynamic>>> data = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void didUpdateWidget(covariant ListeScreenn oldWidget) {
    super.didUpdateWidget(oldWidget);
    getData();
  }

  Future<void> getData() async {
    if (widget.selectedDelegation != null) {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('${widget.selectedDelegation!}_nuit')
              .get();
      setState(() {
        data = querySnapshot.docs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des pharmacies'),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, i) {
          var pharmacieData = data[i].data()!;
          String phoneNumber = pharmacieData['tel'] ?? '';

          return Card(
            child: ListTile(
              title: Text(
                "${pharmacieData['nomF'] ?? 'Nom inconnu'}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text(
                      "Adresse: ${pharmacieData['adresse'] ?? 'Adresse inconnue'}"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _launchPhoneCall(phoneNumber);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        child: Text(
                          phoneNumber.isNotEmpty
                              ? phoneNumber
                              : 'Numéro non disponible',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _openChatbot(context, pharmacieData['nomF'] ?? '');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        child: Text(
                          "Chatbot",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openChatbot(BuildContext context, String nomPharmacie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatbotScreen(nomPharmacie),
      ),
    );
  }

  // Méthode pour lancer un appel téléphonique
  void _launchPhoneCall(String phoneNumber) async {
    if (phoneNumber.isNotEmpty) {
      String telScheme = 'tel:$phoneNumber';
      if (await canLaunch(telScheme)) {
        await launch(telScheme);
      } else {
        throw 'Impossible de lancer l\'appel pour le numéro $phoneNumber';
      }
    } else {
      // Affichez un message ou une alerte pour indiquer que le numéro n'est pas disponible.
      print('Le numéro de téléphone n\'est pas disponible.');
    }
  }
}
