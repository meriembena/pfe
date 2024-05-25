import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  File? _selectedImage;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfileImage() async {
    if (_selectedImage == null || _currentUser == null) return;

    final bytes = await _selectedImage!.readAsBytes();
    final imageBase64 = base64Encode(bytes);

    await _firestore
        .collection('Users')
        .doc(_currentUser!.uid)
        .update({'image': imageBase64});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Photo de profil mise à jour avec succès')),
    );

    setState(() {
      _selectedImage = null;
    });

    _loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _updateProfileImage,
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
