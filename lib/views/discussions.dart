import 'package:chat1/views/my_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat1/Controller/chat_service.dart';
import 'package:chat1/views/Conversation.dart';
import 'dart:convert';

class discussions extends StatelessWidget {
  discussions({super.key});

  final ChatService _chatService = ChatService();

  // Clé globale pour accéder à l'état du Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<void> envoyerMessageAUnUtilisateur(
      String userEmail, BuildContext context) async {
    try {
      String receiverId =
          await getIdByUserEmail(userEmail); // Obtenir l'ID par l'email
      String dernierMessageBot = await _chatService.obtenirDernierMessageBot();
      await _chatService.sendMessage(receiverId,
          dernierMessageBot); // Utiliser l'ID pour envoyer le message
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Conversation(
                    receiverEmail: userEmail,
                    receiverID: receiverId,
                  )));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de l\'envoi du message : $e')));
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<String> getIdByUserEmail(String email) async {
    var usersSnapshot = await _firestore
        .collection('Users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (usersSnapshot.docs.isNotEmpty) {
      return usersSnapshot.docs.first.id; // Retourner l'ID de l'utilisateur
    } else {
      throw 'Utilisateur avec cet email non trouvé';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey, // Utiliser la clé globale
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/back.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: screenHeight * 0.03,
            left: screenWidth * 0.03,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _scaffoldKey.currentState?.openDrawer(); // Ouvrir le Drawer
                  },
                  child: Image.asset(
                    'assets/images/groupe 26.webp',
                    width: screenWidth * 0.08,
                    height: screenHeight * 0.08,
                  ),
                ),
                SizedBox(width: 10), // Espace entre l'image et le texte
                Text(
                  'Discussions',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                      height:
                          90), // Espace entre le haut de la page et la liste
                  Expanded(child: _buildUserList()),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: const MyDrawer(),
    );
  }

  Future<String> _getUserRole() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userData = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();
      return userData.data()?['role'] ?? '';
    }
    return '';
  }

  Widget _buildUserList() {
    return FutureBuilder<String>(
      future: _getUserRole(), // Récupère le rôle de l'utilisateur courant
      builder: (context, roleSnapshot) {
        if (roleSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final userRole = roleSnapshot.data ?? '';

        return StreamBuilder(
          stream: _chatService.getUsersStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text("error");
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading..");
            }

            final users = snapshot.data!.where((userData) {
              final role = userData['role'] ?? '';
              return userRole == 'admin' ||
                  role !=
                      'admin'; // Exemple: Ne montre pas les admins aux utilisateurs non-admin
            }).toList();

            return ListView(
              padding: EdgeInsets.all(8.0),
              children: users
                  .map<Widget>(
                      (userData) => _buildUserListItem(userData, context))
                  .toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    final imageBase64 = userData["image"];
    final image = imageBase64 != null
        ? Image.memory(base64Decode(imageBase64))
        : Image.asset('assets/default_avatar.png'); // Default image

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: image.image,
          radius: 25,
        ),
        title: Text(
          userData["email"],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey, // Nom des utilisateurs en gris
          ),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Conversation(
                        receiverEmail: userData["email"],
                        receiverID: userData["uid"],
                      )));
        },
      ),
    );
  }
}
