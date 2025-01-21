import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mithc_koko_chat_app/pages/profile_page.dart';

class FollowersList extends StatelessWidget {
  List<String> followers;
  List<String> following;

  FollowersList({super.key, required this.following, required this.followers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(text: "Following"),
                Tab(text: "Followers"),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildUserList(following, "No followers yet", context),
              _buildUserList(followers, "No following yet", context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserList(List<String> uIds, String emptyMessage, BuildContext context) {
    if (uIds.isEmpty) {
      return Center(
        child: Text(emptyMessage),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: uIds)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          // Extract user data
          final users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(userData['profilePic']),
                ),
                title: Text(userData['name']),
                subtitle: Text(userData['email']),
                //this is causing a bug
                onTap: ()
                {
                  print(userData['uid']);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfilePage(userId: userData['uid']),
                      )
                  );
                },
              );
            },
          );
        } else {
          return Center(
            child: Text(emptyMessage),
          );
        }
      },
    );
  }
}
