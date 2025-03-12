import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:lottie/lottie.dart';
import 'package:mithc_koko_chat_app/components/features_components/post_tile.dart';
import 'package:mithc_koko_chat_app/components/widgets_components/user_grid.dart';
import 'package:mithc_koko_chat_app/model/post_model.dart';
import 'package:mithc_koko_chat_app/services/chat_services/chat_services.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_up_page_transition.dart';
import 'features/create_post_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _buildAppBar(context),
      body: _buildAllPosts(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        "O P E N L Y",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  Future<List<String>> _getFollowingList(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        return List<String>.from(
            (snapshot.data() as Map<String, dynamic>)['following'] ?? []);
      }
    } catch (e) {
      debugPrint("Error fetching following list: $e");
    }
    return [];
  }

  Widget _buildAllPosts() {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<List<String>>(
      future: _getFollowingList(currentUserId),
      builder: (context, followingSnapshot) {
        if (followingSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (followingSnapshot.hasError) {
          return Center(child: Text('Error: ${followingSnapshot.error}'));
        }

        final followingList = followingSnapshot.data ?? [];
        if (followingList.isEmpty) return _buildUserGrid(context);

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .orderBy('timeStamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final posts = snapshot.data?.docs
                    .map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return (followingList.contains(data['userId']) ||
                              data['userId'] == currentUserId)
                          ? PostModel.fromJson(data)
                          : null;
                    })
                    .where((post) => post != null)
                    .toList() ??
                [];

            if (posts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset('lib/assets/new-post.json'),
                    const SizedBox(height: 20),
                    Text(
                      "No posts from followed users.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: 10,),
                    ShaderMask(
                      shaderCallback: (bounds) {
                        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                        return LinearGradient(
                          colors: isDarkMode
                              ? [Colors.white, Colors.grey.shade500]
                              : [Colors.black, Colors.grey.shade600],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(bounds);
                      },
                      child: const Text(
                        'Be the first to post something!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // This is masked by the gradient
                        ),
                      ),
                    ),

                    // const SizedBox(height: 10), // Spacing
                    const SizedBox(height: 30), // Spacing
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, SlideUpNavigationAnimation(child: CreatePostPage()));
                      },
                      icon: const Icon(FlutterRemix.add_circle_line, color: Colors.black),
                      label: Text(
                        'Create a Post',
                        style: TextStyle(color:Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) => PostCard(post: posts[index]!),
            );
          },
        );
      },
    );
  }

    Widget _buildUserGrid(BuildContext context) {
      return StreamBuilder<List<Map<String, dynamic>>>(
        stream:  ChatServices().getUserStreamExcludingBlockedWithAllUsers(),
        // stream: FirebaseFirestore.instance
        //     .collection('users')
        //     .where('uid', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
        //     .snapshots()
        //     .map((snapshot) => snapshot.docs
        //         .map((doc) => doc.data() as Map<String, dynamic>)
        //         .toList()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.inversePrimary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: const Text(
                      'New Faces to Discover!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 3,
                            color: Colors.black38,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 500, // Adjust this height based on screen size
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final userData = users[index];
                      return UserGrid(
                        userId: userData['uid'],
                        userName: userData['name'],
                        userImage: userData['profilePic'],
                      );
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                )
              ],
            ),
          );

        },
      );
    }

  /*
  ======> buildUserList() and _buildUserListItem() in comments below if needed👍🏻
  */

  // Widget _buildUsersList() {
  //   return StreamBuilder<List<Map<String, dynamic>>>(
  //     stream: ChatServices().getUserStreamExcludingBlocked(),
  //     builder: (context, snapshot) {
  //       if (snapshot.hasError) {
  //         return Center(
  //           child: Text("Error: ${snapshot.error}"),
  //         );
  //       }
  //
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const Center(
  //           child: CircularProgressIndicator(), // Improved loading indicator
  //         );
  //       }
  //
  //       // Check if snapshot has data
  //       if (!snapshot.hasData || snapshot.data!.isEmpty) {
  //         return const Center(
  //           child: Text("No users found."),
  //         );
  //       }
  //
  //       // Build the user list
  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // Add a title
  //           Padding(
  //             padding: const EdgeInsets.all(18.0), // Adjust padding as needed
  //             child: Text(
  //               '''"Openly: Discover, Connect, Share."''',
  //               style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //                 fontWeight: FontWeight.bold,
  //               ), // Use your desired style
  //             ),
  //           ),
  //
  //           // Add the ListView
  //           Expanded( // Make sure ListView takes the available space
  //             child: ListView(
  //               children: snapshot.data!
  //                   .map((userData) => _buildUsersListItem(userData, context))
  //                   .toList(),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Widget _buildUsersListItem(Map<String, dynamic> userData, BuildContext context) {
  //   return UserTile(
  //     userId: userData['uid'],
  //     text: userData['email'],
  //     imgUrl: userData['profilePic'],
  //     onTap: () {
  //       Navigator.push(
  //         context,
  //           SlideUpNavigationAnimation(child: ProfilePage(userId: userData['uid']))
  //       );
  //     },
  //   );
  // }
}
