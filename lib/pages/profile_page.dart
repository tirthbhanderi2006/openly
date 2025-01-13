import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mithc_koko_chat_app/components/bio_box.dart';
import 'package:mithc_koko_chat_app/pages/followers_list.dart';
import 'package:mithc_koko_chat_app/services/post_services.dart';
import '../components/follow_button.dart';
import '../controllers/profile_controller.dart';
import '../model/post_model.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  final String userId;
  final ProfileController profileController = Get.put(ProfileController());

  ProfilePage({super.key, required this.userId}) {
    profileController.fetchUserDetails(userId);
    profileController.fetchUserPosts(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        actions: [
          if (userId == FirebaseAuth.instance.currentUser!.uid)
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              ),
              icon: const Icon(Icons.settings),
            ),
        ],
        title: const Text(
          'P R O F I L E',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Obx(() {
            if (profileController.userDetails.isEmpty) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            }

            final userDetails = profileController.userDetails;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  Text(
                    userDetails['email'] ?? 'No email',
                    style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                  ),

                  const SizedBox(height: 25),
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: userDetails['profilePic'] != null &&
                          userDetails['profilePic']!.isNotEmpty
                          ? DecorationImage(
                        image: NetworkImage(userDetails['profilePic']),
                        fit: BoxFit.cover,
                      )
                          : const DecorationImage(
                        image: NetworkImage(
                            'https://www.gravatar.com/avatar/?d=identicon'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Followers
                        Column(
                          children: [
                            Obx(() => GestureDetector(
                              onTap:() {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => FollowersList(
                                    following:  List<String>.from(userDetails['followers'] ?? []),
                                    followers: List<String>.from(userDetails['following'])??[]),)
                                );
                              },
                              child: Text(
                                "${profileController.followersCount}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            )),
                            const SizedBox(height: 5),
                            Text(
                              "Followers",
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.inversePrimary,
                              ),
                            ),
                          ],
                        ),
                        // Following
                        Column(
                          children: [
                            Obx(() => Text(
                              "${profileController.followingCount}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )),
                            const SizedBox(height: 5),
                            Text(
                              "Following",
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.inversePrimary,
                              ),
                            ),
                          ],
                        ),
                        // Posts
                        Column(
                          children: [
                            Obx(() => Text(
                              "${profileController.posts.length}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )),
                            const SizedBox(height: 5),
                            Text(
                              "Posts",
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.inversePrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      // FollowButton(onPress: (){},text: "Follow",),
                      Expanded(
                        child: FirebaseAuth.instance.currentUser!.uid != userId
                            ? ElevatedButton(
                          onPressed: () {
                            profileController.toggleFollow(
                                FirebaseAuth.instance.currentUser!.uid, userId);
                          },
                          child: Obx(() {
                            final isFollowing = (profileController.userDetails['followers'] ?? [])
                                .contains(FirebaseAuth.instance.currentUser!.uid);
                            return Text(isFollowing ? 'Unfollow' : 'Follow');
                          }),
                        )
                            : Text(""),
                      ),

                    ],
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        Text(
                          'Bio',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  BioBox(
                    bioText: userDetails['bio'] ?? "No bio available",
                  ),
                ],
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 25),
            child: Row(
              children: [
                Text(
                  'Posts',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(() {
              final posts = profileController.posts;
              if (posts.isEmpty) {
                return Center(
                  child: Text(
                    "No posts available",
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                );
              }
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                ),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onLongPress: () => _showPostPreviewDialog(context, index, posts),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        posts[index].imgUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showPostPreviewDialog(BuildContext context, int index, List<PostModel> posts) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          posts[index].imgUrl,
                          fit: BoxFit.cover,
                          height: 300,
                          width: 300,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        posts[index].caption ?? "No caption available.",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (userId == FirebaseAuth.instance.currentUser!.uid)
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                PostServices().deletePost(postId: posts[index].postId);
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "Delete",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                "Close",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
