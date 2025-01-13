import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mithc_koko_chat_app/components/my_drawer.dart';
import 'package:mithc_koko_chat_app/components/post_tile.dart';
import 'package:mithc_koko_chat_app/pages/user_page.dart';
import 'package:mithc_koko_chat_app/services/chat_services.dart';

import '../components/user_tile.dart';
import '../model/post_model.dart';
import 'chat_page.dart';
import 'create_post_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        actions: [
          IconButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePostPage(),)), icon: Icon(Icons.add_box_outlined)),
          // Padding(
          //   padding: const EdgeInsets.only(top: 6.0),
          //   child: GestureDetector(
          //     onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePostPage())),
          //     child: Image.asset("lib/assets/new-post.gif"),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0,bottom: 5),
            child: IconButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) => UsersPage(),)), icon: Icon(Icons.message)),
              // child: GestureDetector(
              //   onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) => UsersPage())),
              //     child: Image.asset("lib/assets/direct.gif",width: 60,)
              // ),
          )
        ],
        title: const Text("H O M E",style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      // body: _buildUsersList(),
      body: _buildAllPosts(),
      drawer: const MyDrawer(),
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

  Widget _buildAllPosts(){
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts') // Your Firestore collection name
          .orderBy('timeStamp', descending: true) // Optional: order posts by timestamp
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong!'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildUsersList();
        }

        // Map Firestore document data to PostModel
        List<PostModel> posts = snapshot.data!.docs.map((doc) {
          return PostModel.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();
        print(posts);

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            // Display the posts using your PostTile widget
            return PostTile(model: posts[index]);
          },
        );
      },
    );
  }
}
