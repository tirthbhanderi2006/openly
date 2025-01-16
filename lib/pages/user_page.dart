import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/user_tile.dart';
import '../services/chat_services.dart';
import 'chat_page.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  void initState() {
    ChatServices().getFollowingList(FirebaseAuth.instance.currentUser!.uid);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("C H A T",style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _buildUsersList(),
    );
  }

  Widget _buildUsersList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ChatServices().getUserStreamExcludingBlocked(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}"),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(), // Improved loading indicator
          );
        }

        // Check if snapshot has data
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text("No users found."),
          );
        }

        // Build the user list
        return ListView(
          children: snapshot.data!
              .map((userData) => _buildUsersListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildUsersListItem(Map<String, dynamic> userData, BuildContext context) {
    return UserTile(
      userId: userData['uid'],
      text: userData['email'],
      imgUrl: userData['profilePic'],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(receiverEmail: userData['email'],receiverId: userData['uid'],),
          ),
        );
      },
    );
  }
}
