import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:Saydaliati/views/Categories.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
//Flutter a besoin de construire le widget ProfilepageState, il appelle
//createState(). Cette méthode retourne une instance de _ProfilepageState,
//qui contient tout l'état nécessaire
  _ProfilePageState createState() => _ProfilePageState();
}

//Contient et gère l'état dynamique du widget,construire l'interface utilisateur en réponse aux interactions de l'utilisateur.
class _ProfilePageState extends State<ProfilePage> {
//permettant l'accès aux fonctionnalités d'authentification
  final FirebaseAuth _auth = FirebaseAuth.instance;
//utilisée pour interagir avec la base de données Firestore de Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// stocker un objet User qui représente l'utilisateur actuellement connecté
  User? _currentUser;
//une variable qui peut contenir un fichier image,sélectionné par l'utilisateur à partir de son appareil
  File? _selectedImage;
//stocker des données supplémentaires liées à l'utilisateur
  Map<String, dynamic>? _userData;
//C'est l'endroit où vous pouvez insérer le code d'initialisation qui doit s'exécuter une seule fois
  @override
  void initState() {
    super.initState();
//récupère l'utilisateur actuellement connecté à partir de l'instance de FirebaseAuth(_auth)
    _currentUser = _auth.currentUser;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (_currentUser != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(_currentUser!.uid).get();
      setState(() {
        _userData = userDoc.data() as Map<String, dynamic>?;
      });
    }
  }

//conçue pour charger les données de profil utilisateur depuis Firestore
  Future<void> _pickImage() async {
//crée une instance de ImagePicker, qui capturer ou sélectionner des images et des vidéos à partir de différentes sources.
    final picker = ImagePicker();
//permet de sélectionner une image depuis la galerie.
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//Si un fichier est sélectionné, il met à jour l'état du widget pour stocker le fichier image sélectionné
    if (pickedFile != null) {
//utilisée pour indiquer à Flutter que l'état de ce widget doit être mis à jour
      setState(() {
//crée un objet fichier à partir du chemin de l'image que l'utilisateur a sélectionnée.
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfileImage() async {
//vérifie si une image a été sélectionnée et si un utilisateur est connecté
    if (_selectedImage == null || _currentUser == null) return;
//L'image sélectionnée est lue comme un tableau de bytes (bytes
    final bytes = await _selectedImage!.readAsBytes();
//ces bytes sont encodés en une chaîne de caractères Base64 pour stocker et transmis facillement
    final imageBase64 = base64Encode(bytes);
//met à jour le document de l'utilisateur dans la collection Users
    await _firestore
        .collection('Users')
        .doc(_currentUser!.uid)
        .update({'image': imageBase64});
//un message est affiché, informant que la photo de profil a été mise à jour avec succès.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Photo de profil mise à jour avec succès')),
    );
//L'état local est mis à jour pour effacer la référence à l'image sélectionnée
    setState(() {
      _selectedImage = null;
    });
//appelée pour recharger les données du profil
    _loadUserProfile();
  }

  @override
  // build est responsable de la création et la mis à jour de l'interface utilisateur
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => categories()));
        return false;
      },
      // Scaffold widget est prédéfini par Flutter.
      child: Scaffold(
        //le widget Stack permet de superposer plusieurs widgets les uns sur les autres.
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/back.jpg', fit: BoxFit.cover),
            ),
            Positioned(
              top: screenHeight * 0.03,
              left: screenWidth * 0.03,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                  'assets/images/Groupe 27.png',
                  width: screenWidth * 0.08,
                  height: screenHeight * 0.08,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _userData == null
                    ? CircularProgressIndicator()
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: screenHeight * 0.09),
                            _buildProfileContainer(screenWidth, screenHeight),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContainer(double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 90,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : _userData!['image'] != null
                            ? MemoryImage(
                                base64Decode(_userData!['image']),
                              )
                            : AssetImage('assets/images/avatar.png')
                                as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: FloatingActionButton(
                      onPressed: _pickImage,
                      child: Icon(Icons.camera_alt),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _updateProfileImage,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.grey,
                  backgroundColor: Colors.white,
                ),
                child: Text('Enregistrer la photo'),
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Nom:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 5),
            Text(
              _userData!['name'] ?? 'Nom inconnu',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            Text(
              'Adresse Email:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 5),
            Text(
              _userData!['email'] ?? 'Email inconnu',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () => showChangePasswordDialog(context),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.grey,
                  backgroundColor: Colors.white,
                ),
                child: Text('Changer Mot de Passe'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      //le dialogue ou l'overlay ne peut pas être fermé par l'utilisateur en tapant en dehors de la zone
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final newPasswordController = TextEditingController();
        final confirmPasswordController = TextEditingController();

        return AlertDialog(
          title: Text('Changer Mot de Passe'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(labelText: 'Nouveau mot de passe'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              TextField(
                controller: confirmPasswordController,
                decoration:
                    InputDecoration(labelText: 'Confirmer mot de passe'),
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text('Confirmer'),
              onPressed: () {
                if (newPasswordController.text ==
                    confirmPasswordController.text) {
                  Navigator.of(dialogContext).pop();
                  updatePassword(newPasswordController.text);
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Les mots de passe ne correspondent pas'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void updatePassword(String newPassword) {
    _currentUser!.updatePassword(newPassword).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Mot de passe mis à jour avec succès."),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Erreur lors de la mise à jour du mot de passe: $error"),
        ),
      );
    });
  }
}
