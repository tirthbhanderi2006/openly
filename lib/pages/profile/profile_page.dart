import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:get/get.dart';
import 'package:mithc_koko_chat_app/components/pofile/profile_info.dart';
import 'package:mithc_koko_chat_app/components/pofile/profile_picture.dart';
import 'package:mithc_koko_chat_app/components/pofile/profile_post.dart';
import 'package:mithc_koko_chat_app/components/widgets_components/bio_box.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_left_page_transition.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_right_page_transition.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_up_page_transition.dart';
import 'package:mithc_koko_chat_app/pages/chat/chat_page.dart';
import 'package:mithc_koko_chat_app/pages/profile/followers_list.dart';
import 'package:mithc_koko_chat_app/services/features_services/post_services.dart';
import '../../controllers/profile_controller.dart';
import '../../main.dart';
import '../../model/post_model.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with RouteAware {
  final ProfileController profileController = Get.put(ProfileController());

  @override
  void initState() {
    profileController.fetchUserDetails(widget.userId);
    profileController.fetchUserPosts(widget.userId);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute? modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(
          this, modalRoute); // Subscribe to the RouteObserver
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this); // Unsubscribe from RouteObserver
    super.dispose();
  }

  @override
  void didPopNext() {
    profileController.fetchUserDetails(widget.userId);
    profileController.fetchUserPosts(widget.userId);
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        actions: [
          if (widget.userId == FirebaseAuth.instance.currentUser!.uid)
            IconButton(
              onPressed: () => Navigator.push(
                context,
                SlideLeftPageTransition(child: EditProfilePage()),
              ),
              icon: const Icon(FlutterRemix.user_settings_line),
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
                  // Text(
                  //   userDetails['email'] ?? 'No email',
                  //   style: TextStyle(fontSize:10,color: Theme.of(context).colorScheme.inversePrimary),
                  // ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      // Profile Image
                      ProfileImageWithPreview(
                          profilePicUrl: userDetails['profilePic'] ?? ''),

                      // old code is pressent in the profile_image.dart file as a comment
                      Obx(
                        () => UserProfileStats(
                            name: userDetails['name'],
                            followers: userDetails['followers'],
                            following: userDetails['following']),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      // FollowButton(onPress: (){},text: "Follow",),
                      Expanded(
                        child: FirebaseAuth.instance.currentUser!.uid !=
                                widget.userId
                            ? Obx(() {
                                final isFollowing = (profileController
                                            .userDetails['followers'] ??
                                        [])
                                    .contains(
                                        FirebaseAuth.instance.currentUser!.uid);
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Follow/Unfollow Button
                                    ConstrainedBox(
                                      constraints: BoxConstraints.tightFor(
                                          width: 120, height: 50),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          profileController.toggleFollow(
                                            FirebaseAuth
                                                .instance.currentUser!.uid,
                                            widget.userId,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          backgroundColor: Colors.blue,
                                        ),
                                        child: Text(
                                          isFollowing ? 'Unfollow' : 'Follow',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    if (isFollowing) ...[
                                      SizedBox(
                                          width: 10), // Spacing between buttons
                                      // Message Button
                                      ConstrainedBox(
                                        constraints: BoxConstraints.tightFor(
                                            width: 120, height: 50),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Navigate to the chat screen or message functionality
                                            Navigator.push(
                                                context,
                                                SlideRightPageTransition(
                                                    child: ChatPage(
                                                        receiverEmail:
                                                            userDetails[
                                                                'email'],
                                                        receiverId: userDetails[
                                                            'uid'])));
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                          child: Text(
                                            'Message',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              })
                            : Text(""),
                      ),
                    ],
                  ),
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
          const SizedBox(height: 10),
          // Posts
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
          // Posts
          Expanded(
            child: Obx(() {
              final posts = profileController.posts;
              if (posts.isEmpty) {
                return Center(
                  child: Text(
                    "No posts available",
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                );
              }
              // old code is pressent in the profile_post.dart file as a comment
              return PostsGridView(
                posts: posts,
                userId: profileController.userDetails['uid'],
              );
            }),
          ),
        ],
      ),
    );
  }
}
