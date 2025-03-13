import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mithc_koko_chat_app/components/profile_components/profile_info.dart';
import 'package:mithc_koko_chat_app/components/profile_components/profile_picture.dart';
import 'package:mithc_koko_chat_app/components/profile_components/profile_post.dart';
import 'package:mithc_koko_chat_app/components/profile_components/bio_box.dart';
import 'package:mithc_koko_chat_app/controllers/navigation_controller.dart';
import 'package:mithc_koko_chat_app/pages/profile/show_bookmarks.dart';
import 'package:mithc_koko_chat_app/pages/settings/setting_page.dart';
import 'package:mithc_koko_chat_app/services/auth_services/auth_services.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_right_page_transition.dart';
import 'package:mithc_koko_chat_app/pages/chat/chat_page.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_up_page_transition.dart';
import '../../controllers/profile_controller.dart';
import '../../main.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with RouteAware {
  final ProfileController profileController = Get.put(ProfileController());
  final NavigationController navigationController =
      Get.find<NavigationController>();

  @override
  void initState() {
    super.initState();
    profileController.fetchUserDetails(widget.userId);
    profileController.fetchUserPosts(widget.userId);
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
    routeObserver.unsubscribe(this); //  Unsubscribe from RouteObserver
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
          Padding(
            padding: const EdgeInsets.only(
                right: 16.0), // Adjust the right padding for alignment
            child: SpeedDial(
              backgroundColor: Colors.transparent,
              elevation: 0,
              direction: SpeedDialDirection.down,
              animatedIcon: AnimatedIcons.menu_close,
              foregroundColor: Theme.of(context).colorScheme.inversePrimary,
              buttonSize: Size(50, 50),
              children: [
                // Settings button with smaller icon
                SpeedDialChild(
                  child: Icon(
                    FlutterRemix.settings_5_line,
                    size: 24,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    SlideUpNavigationAnimation(child: SettingPage()),
                  ),
                ),
                // Edit Profile button, only visible for the current user
                if (widget.userId == FirebaseAuth.instance.currentUser!.uid)
                  SpeedDialChild(
                    child: Icon(
                      FlutterRemix.user_settings_line,
                      size: 24,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      SlideUpNavigationAnimation(child: EditProfilePage()),
                    ),
                  ),

                if (widget.userId == FirebaseAuth.instance.currentUser!.uid)
                  SpeedDialChild(
                    child: Icon(
                      FlutterRemix.bookmark_3_line,
                      size: 24,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      SlideUpNavigationAnimation(child: ShowBookmarks()),
                    ),
                  ),
                if (widget.userId == FirebaseAuth.instance.currentUser!.uid)
                  SpeedDialChild(
                      child: Icon(
                        FlutterRemix.logout_circle_line,
                        color: Colors.red,
                        size: 24,
                      ),
                      onTap: () {
                        AuthService().logout(context);
                        navigationController.currentIndex.value = 0;
                      }),
              ],
            ),
          ),
        ],
        title: const Text(
          'P R O F I L E',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0, // Remove the shadow for a clean look
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
                  //const SizedBox(height: 25),
                  /*Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Profile Image
                      ProfileImageWithPreview(
                          profilePicUrl: userDetails['profilePic'] ?? ''),
                      // old code is present in the profile_image.dart file as a comment
                    ],
                  ),*/
                  Obx(
                        () => UserProfileStats(
                          email: userDetails['email'],
                          profileImageUrl: userDetails['profilePic'],
                          userId: userDetails['uid'],
                          name: userDetails['name'],
                          followers: profileController.followers,
                          following: profileController.following,
                          postsCount: profileController.posts.length),
                  ),

                  const SizedBox(height: 15),
                  FirebaseAuth.instance.currentUser!.uid !=
                      widget.userId
                      ? Row(
                    children: [
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
                  )
                      :SizedBox.shrink(),
                  userDetails['bio'].toString().isNotEmpty? const SizedBox(height: 15):SizedBox.shrink(),
                  userDetails['bio'].toString().isNotEmpty
                      ? Padding(
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
                  )
                      : SizedBox.shrink(),
                  const SizedBox(height: 10),
                  userDetails['bio'].toString().isNotEmpty
                      ? BioBox(
                    bioText: userDetails['bio'] ?? "No bio available",
                  )
                      : SizedBox.shrink(),
                  SizedBox(
                    height: 2,
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 10),
          // Posts
          Padding(
            padding: const EdgeInsets.only(left: 14.0, top: 0),
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
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Lottie.asset('lib/assets/no-post.json', height: 150),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      "No posts yet!!",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                );
              }
              // old code is present in the profile_post.dart file as a comment
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: PostsGridView(
                  posts: posts,
                  userId: profileController.userDetails['uid'],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
