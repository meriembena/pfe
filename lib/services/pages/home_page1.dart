import 'package:chat1/components/my_drawer1.dart';
import 'package:chat1/services/auth/auth_service1.dart';

import 'package:chat1/services/chat/chat_service1.dart';
import 'package:chat1/services/pages/chat_page1.dart';
import 'package:flutter/material.dart';

import '../../components/user_tile.dart';
import 'chat_page.dart';

class HomePage1 extends StatelessWidget {
  HomePage1({super.key});
  final ChatService1 _chatService1 = ChatService1();
  final AuthService1 _authService1 = AuthService1();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      drawer: const MyDrawer1(),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService1.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading..");
        }
        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    if (userData["email"] != _authService1.getCurrentUser()!.email) {
      return UserTile(
        text: userData["email"],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage1(
                receiverEmail1: userData["email"],
                receiverID1: userData["uid"],
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
