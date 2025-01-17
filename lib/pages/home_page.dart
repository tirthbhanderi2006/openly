import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mithc_koko_chat_app/components/my_drawer.dart';
import 'package:mithc_koko_chat_app/components/post_tile.dart';
import 'package:mithc_koko_chat_app/pages/profile_page.dart';
import 'package:mithc_koko_chat_app/pages/user_page.dart';
import 'package:mithc_koko_chat_app/services/chat_services.dart';

import '../components/user_tile.dart';
import '../model/post_model.dart';
import '../page_transition/slide_left_page_transition.dart';
import '../page_transition/slide_up_page_transition.dart';
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
          IconButton(onPressed: ()=>Navigator.push(context, SlideLeftPageTransition(child: CreatePostPage())), icon: Icon(Icons.add_box_outlined)),
          // Padding(
          //   padding: const EdgeInsets.only(top: 6.0),
          //   child: GestureDetector(
          //     onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePostPage())),
          //     child: Image.asset("lib/assets/new-post.gif"),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0,bottom: 5),
            child: IconButton(onPressed: ()=>Navigator.push(context, SlideLeftPageTransition(child: UsersPage())), icon: Icon(Icons.message)),
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add a title
            Padding(
              padding: const EdgeInsets.all(18.0), // Adjust padding as needed
              child: Text(
                '''"Openly: Discover, Connect, Share."''',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ), // Use your desired style
              ),
            ),

            // Add the ListView
            Expanded( // Make sure ListView takes the available space
              child: ListView(
                children: snapshot.data!
                    .map((userData) => _buildUsersListItem(userData, context))
                    .toList(),
              ),
            ),
          ],
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
            SlideUpNavigationAnimation(child: ProfilePage(userId: userData['uid']))
        );
      },
    );
  }

  Stream<List<DocumentSnapshot>> getFilteredPostsStream(String currentUserId) async* {
    // Fetch the following list
    List<dynamic> followingList = await getFollowingList(currentUserId);

    // Listen to the posts collection
    await for (var snapshot in FirebaseFirestore.instance
        .collection('posts')
        .orderBy('timeStamp', descending: true)
        .snapshots()) {
      // Filter the posts where the userId is in the following list
      var filteredPosts = snapshot.docs.where((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return followingList.contains(data['userId']); // Adjust 'userId' key if different
      }).toList();

      yield filteredPosts;
    }
  }
  Future<List<dynamic>> getFollowingList(String userId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (snapshot.exists) {
        var userDetails = snapshot.data() as Map<String, dynamic>;
        return userDetails["following"] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  Widget _buildAllPosts(){
    return FutureBuilder<List<dynamic>>(
      future: getFollowingList(FirebaseAuth.instance.currentUser!.uid), // Replace with your method to get the current user ID
      builder: (context, followingSnapshot) {
        if (followingSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (followingSnapshot.hasError) {
          return Center(child: Text('Error loading following list!'));
        }

        if (!followingSnapshot.hasData || followingSnapshot.data!.isEmpty) {
          return Center(child: Text('You are not following anyone.'));
        }

        List<dynamic> followingList = followingSnapshot.data!;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .orderBy('timeStamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Something went wrong!'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No posts found.'));
            }

            // Filter posts based on the following list
            List<PostModel> posts = snapshot.data!.docs
              .where((doc) {
              var data = doc.data() as Map<String, dynamic>;
              return followingList.contains(data['userId']) || data['userId'] == FirebaseAuth.instance.currentUser!.uid; // Ensure userId matches your Firestore field
            })
              .map((doc) => PostModel.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
            if (posts.isEmpty) {
              return Center(child: Text('No posts from followed users.'));
            }

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostTile(model: posts[index]);
              },
            );
          },
        );
      },
    );

  }
}
