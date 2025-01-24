import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mithc_koko_chat_app/services/chat_services/chat_services.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_up_page_transition.dart';
import 'package:mithc_koko_chat_app/pages/chat/chat_page.dart';
import 'package:mithc_koko_chat_app/pages/profile/profile_page.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../components/features_components/search_user_tile.dart';

class FollowersList extends StatelessWidget {
  final List<String> followers;
  final List<String> following;
  List<dynamic> followingList = [];
  bool isFollowing = false;
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
              _buildUserList(following, "No following yet", context),
              _buildUserList(followers, "No followers yet", context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserList(
      List<String> uIds, String emptyMessage, BuildContext context) {
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
          // Show skeleton loader while waiting for data from the stream
          return _buildSkeletonLoader();
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          return FutureBuilder(
            future: Future.delayed(
                const Duration(milliseconds: 1000), () => snapshot.data!.docs),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                // Show skeleton loader during delay
                return _buildSkeletonLoader();
              }

              // Extract user data after the delay
              final users = futureSnapshot.data!;
              return SlidableAutoCloseBehavior(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final userData =
                        users[index].data() as Map<String, dynamic>;
                    return Slidable(
                      startActionPane: ActionPane(
                        motion: const StretchMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              Navigator.push(
                                  context,
                                  SlideUpNavigationAnimation(
                                      child: ProfilePage(
                                          userId: userData['uid'])));
                            },
                            label: "Profile",
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                          SlidableAction(
                            onPressed: (context) async {
                              final isFollowing = await checkIfFollowing(
                                context: context,
                                receiverId: userData['uid'],
                              );

                              if (isFollowing) {
                                // Navigate to ChatPage if the user is following
                                Navigator.push(
                                  context,
                                  SlideUpNavigationAnimation(
                                    child: ChatPage(
                                      receiverEmail: userData['email'],
                                      receiverId: userData['uid'],
                                    ),
                                  ),
                                );
                              } else {
                                // Show a Snackbar if the user is not following
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'You are not following ${userData['name']}'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },
                            label: "Chat",
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(16),
                                bottomRight: Radius.circular(16)),
                          )
                        ],
                      ),
                      child: SearchUserTile(
                          userName: userData['name'] ?? 'Unknown',
                          userId: userData['userId'] ?? '',
                          imgUrl: userData['profilePic'],
                          email: userData['email'] ?? '',
                          onTap: () {}),
                    );
                  },
                ),
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

  // Skeleton Loader
  Widget _buildSkeletonLoader() {
    return ListView.builder(
      itemCount: 5, // Number of skeleton tiles to show
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Skeletonizer(
            enabled: true,
            child: SearchUserTile(
                userName: "userName",
                userId: "userId",
                imgUrl: "https://www.gravatar.com/avatar/?d=identicon",
                email: "email",
                onTap: () {}),
          ),
        );
      },
    );
  }

  // check checkIfFollowing
  checkIfFollowing(
      {required BuildContext context, required String receiverId}) async {
    // Fetch the current user's following list
    followingList = await ChatServices()
        .getFollowingList(FirebaseAuth.instance.currentUser!.uid);

    if (followingList.contains(receiverId)) {
      return true; // User is following the receiver
    } else {
      return false; // User is not following the receiver
    }
  }
}
